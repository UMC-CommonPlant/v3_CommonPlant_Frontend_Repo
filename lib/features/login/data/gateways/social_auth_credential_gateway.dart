import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

typedef SocialAuthTokenLoader = Future<String?> Function();

void initializeSocialAuthSdks() {
  final kakaoNativeAppKey = AppEnvironment.kakaoNativeAppKey.trim();
  if (kakaoNativeAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  }
}

final socialAuthCredentialGatewayProvider =
    Provider<SocialAuthCredentialGateway>(
      (ref) => SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: AppEnvironment.kakaoNativeAppKey,
        googleServerClientId: AppEnvironment.googleServerClientId,
        googleIosClientId: AppEnvironment.googleIosClientId,
        targetPlatform: defaultTargetPlatform,
      ),
    );

class SdkSocialAuthCredentialGateway implements SocialAuthCredentialGateway {
  SdkSocialAuthCredentialGateway({
    required String kakaoNativeAppKey,
    required String googleServerClientId,
    required String googleIosClientId,
    required TargetPlatform targetPlatform,
    SocialAuthTokenLoader? kakaoTokenLoader,
    SocialAuthTokenLoader? googleTokenLoader,
    SocialAuthTokenLoader? appleTokenLoader,
  }) : _kakaoNativeAppKey = kakaoNativeAppKey.trim(),
       _googleServerClientId = googleServerClientId.trim(),
       _googleIosClientId = googleIosClientId.trim(),
       _targetPlatform = targetPlatform,
       _kakaoTokenLoader = kakaoTokenLoader,
       _googleTokenLoader = googleTokenLoader,
       _appleTokenLoader = appleTokenLoader;

  final String _kakaoNativeAppKey;
  final String _googleServerClientId;
  final String _googleIosClientId;
  final TargetPlatform _targetPlatform;
  final SocialAuthTokenLoader? _kakaoTokenLoader;
  final SocialAuthTokenLoader? _googleTokenLoader;
  final SocialAuthTokenLoader? _appleTokenLoader;
  Future<void>? _googleInitialization;

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
    final requiresIosClientId = _targetPlatform == TargetPlatform.iOS;
    if (_googleServerClientId.isEmpty ||
        (requiresIosClientId && _googleIosClientId.isEmpty)) {
      throw const SocialAuthNotConfiguredException();
    }

    if (_googleTokenLoader case final loader?) {
      return loader();
    }

    final googleSignIn = GoogleSignIn.instance;
    _googleInitialization ??= googleSignIn.initialize(
      clientId: requiresIosClientId ? _googleIosClientId : null,
      serverClientId: _googleServerClientId,
    );
    await _googleInitialization;

    try {
      final account = await googleSignIn.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthCanceledException();
      }
      rethrow;
    }
  }

  Future<String?> _authorizeApple() async {
    if (_targetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError('Apple 로그인은 iOS에서만 지원합니다.');
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
      KakaoClientException(:final reason) =>
        reason == ClientErrorCause.cancelled,
      KakaoAuthException(:final error) => error == AuthErrorCause.accessDenied,
      _ => false,
    };
  }
}
