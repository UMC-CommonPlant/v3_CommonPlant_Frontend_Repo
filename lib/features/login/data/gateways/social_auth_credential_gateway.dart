import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

typedef SocialAuthTokenLoader = Future<String?> Function();

final appleLoginSupportedProvider = FutureProvider<bool>((ref) {
  return isAppleLoginSupported();
});

Future<bool> isAppleLoginSupported({
  TargetPlatform? targetPlatform,
  bool isWeb = kIsWeb,
}) async {
  if (isWeb ||
      (targetPlatform ?? defaultTargetPlatform) != TargetPlatform.iOS) {
    return false;
  }
  try {
    return await const MethodChannel(
          'com.plant.common/social_auth',
        ).invokeMethod<bool>('isAppleLoginSupported') ??
        false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

void initializeSocialAuthSdks() {
  final kakaoNativeAppKey = AppEnvironment.kakaoNativeAppKey.trim();
  if (kakaoNativeAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  }
}

final _sdkSocialAuthGatewayProvider = Provider<SdkSocialAuthCredentialGateway>(
  (ref) => SdkSocialAuthCredentialGateway(
    kakaoNativeAppKey: AppEnvironment.kakaoNativeAppKey,
    googleServerClientId: AppEnvironment.googleServerClientId,
    googleIosClientId: AppEnvironment.googleIosClientId,
    targetPlatform: defaultTargetPlatform,
    appleSupportChecker: () => ref.read(appleLoginSupportedProvider.future),
  ),
);

final socialAuthCredentialGatewayProvider =
    Provider<SocialAuthCredentialGateway>(
      (ref) => ref.watch(_sdkSocialAuthGatewayProvider),
    );

final socialAuthSessionCleanupProvider = Provider<Future<void> Function()>(
  (ref) => ref.watch(_sdkSocialAuthGatewayProvider).clearLocalSession,
);

class SdkSocialAuthCredentialGateway implements SocialAuthCredentialGateway {
  SdkSocialAuthCredentialGateway({
    required String kakaoNativeAppKey,
    required String googleServerClientId,
    required String googleIosClientId,
    required TargetPlatform targetPlatform,
    bool isWeb = kIsWeb,
    Future<bool> Function()? appleSupportChecker,
    SocialAuthTokenLoader? kakaoTokenLoader,
    SocialAuthTokenLoader? googleTokenLoader,
    SocialAuthTokenLoader? appleTokenLoader,
    Future<void> Function()? kakaoSessionCleanup,
    Future<void> Function()? googleSessionCleanup,
  }) : _kakaoNativeAppKey = kakaoNativeAppKey.trim(),
       _googleServerClientId = googleServerClientId.trim(),
       _googleIosClientId = googleIosClientId.trim(),
       _targetPlatform = targetPlatform,
       _isWeb = isWeb,
       _appleSupportChecker =
           appleSupportChecker ??
           (() => isAppleLoginSupported(
             targetPlatform: targetPlatform,
             isWeb: isWeb,
           )),
       _kakaoTokenLoader = kakaoTokenLoader,
       _googleTokenLoader = googleTokenLoader,
       _appleTokenLoader = appleTokenLoader,
       _kakaoSessionCleanup = kakaoSessionCleanup,
       _googleSessionCleanup = googleSessionCleanup;

  final String _kakaoNativeAppKey;
  final String _googleServerClientId;
  final String _googleIosClientId;
  final TargetPlatform _targetPlatform;
  final bool _isWeb;
  final Future<bool> Function() _appleSupportChecker;
  final SocialAuthTokenLoader? _kakaoTokenLoader;
  final SocialAuthTokenLoader? _googleTokenLoader;
  final SocialAuthTokenLoader? _appleTokenLoader;
  final Future<void> Function()? _kakaoSessionCleanup;
  final Future<void> Function()? _googleSessionCleanup;
  Future<void>? _googleInitialization;

  bool get _isGoogleConfigured =>
      _googleServerClientId.isNotEmpty &&
      (_targetPlatform != TargetPlatform.iOS || _googleIosClientId.isNotEmpty);

  Future<void> clearLocalSession() async {
    if (_isWeb ||
        (_targetPlatform != TargetPlatform.android &&
            _targetPlatform != TargetPlatform.iOS)) {
      return;
    }

    await Future.wait([
      if (_kakaoNativeAppKey.isNotEmpty)
        Future.sync(
          _kakaoSessionCleanup ?? TokenManagerProvider.instance.manager.clear,
        ),
      if (_isGoogleConfigured)
        Future.sync(_googleSessionCleanup ?? _signOutGoogle),
    ]);
  }

  Future<void> _signOutGoogle() async {
    await _initializeGoogle();
    await GoogleSignIn.instance.signOut();
  }

  Future<void> _initializeGoogle() {
    return _googleInitialization ??= GoogleSignIn.instance.initialize(
      clientId: _targetPlatform == TargetPlatform.iOS
          ? _googleIosClientId
          : null,
      serverClientId: _googleServerClientId,
    );
  }

  @override
  Future<SocialAuthCredential> authorize(SocialAuthProvider provider) async {
    final token = await switch (provider) {
      SocialAuthProvider.kakao => _authorizeKakao(),
      SocialAuthProvider.google => _authorizeGoogle(),
      SocialAuthProvider.apple => _authorizeApple(),
    };
    final normalizedToken = token?.trim();

    if (normalizedToken == null || normalizedToken.isEmpty) {
      throw StateError('소셜 인증 token이 비어 있습니다.');
    }

    return SocialAuthCredential(provider: provider, token: normalizedToken);
  }

  Future<String?> _authorizeKakao() async {
    if (_kakaoNativeAppKey.isEmpty) {
      throw const SocialAuthNotConfiguredException();
    }

    if (_kakaoTokenLoader case final loader?) {
      return loader();
    }

    if (await isKakaoTalkInstalled()) {
      try {
        final token = await UserApi.instance.loginWithKakaoTalk();
        return token.accessToken;
      } catch (error) {
        if (_isKakaoCancellation(error)) {
          throw const SocialAuthCanceledException();
        }
      }
    }

    try {
      final token = await UserApi.instance.loginWithKakaoAccount();
      return token.accessToken;
    } catch (error) {
      if (_isKakaoCancellation(error)) {
        throw const SocialAuthCanceledException();
      }
      rethrow;
    }
  }

  Future<String?> _authorizeGoogle() async {
    if (!_isGoogleConfigured) {
      throw const SocialAuthNotConfiguredException();
    }

    if (_googleTokenLoader case final loader?) {
      return loader();
    }

    await _initializeGoogle();

    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthCanceledException();
      }
      rethrow;
    }
  }

  Future<String?> _authorizeApple() async {
    if (_isWeb ||
        _targetPlatform != TargetPlatform.iOS ||
        !await _appleSupportChecker()) {
      throw UnsupportedError('Apple 로그인은 iPhone 앱에서만 지원합니다.');
    }

    if (_appleTokenLoader case final loader?) {
      return loader();
    }

    if (!await SignInWithApple.isAvailable()) {
      throw const SocialAuthNotConfiguredException();
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return credential.identityToken;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthCanceledException();
      }
      rethrow;
    }
  }

  bool _isKakaoCancellation(Object error) {
    return switch (error) {
      PlatformException(:final code) => code == 'CANCELED',
      KakaoClientException(:final reason) =>
        reason == ClientErrorCause.cancelled,
      KakaoAuthException(:final error) => error == AuthErrorCause.accessDenied,
      _ => false,
    };
  }
}
