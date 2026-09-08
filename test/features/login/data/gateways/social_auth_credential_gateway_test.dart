import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const deviceChannel = MethodChannel('com.plant.common/social_auth');
  const kakaoChannel = MethodChannel('kakao_flutter_sdk_method_channel');
  setUp(() {
    messenger.setMockMethodCallHandler(deviceChannel, (call) async => true);
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(deviceChannel, null);
    messenger.setMockMethodCallHandler(kakaoChannel, null);
  });

  test('iOS 브라우저에서는 네이티브 판별과 Apple SDK를 호출하지 않는다', () async {
    messenger.setMockMethodCallHandler(
      deviceChannel,
      (_) async => fail('native call'),
    );
    expect(
      await isAppleLoginSupported(
        targetPlatform: TargetPlatform.iOS,
        isWeb: true,
      ),
      isFalse,
    );
    final gateway = SdkSocialAuthCredentialGateway(
      kakaoNativeAppKey: '',
      googleServerClientId: '',
      googleIosClientId: '',
      targetPlatform: TargetPlatform.iOS,
      isWeb: true,
      appleSupportChecker: () async => fail('device call'),
      appleTokenLoader: () async => fail('SDK call'),
    );
    await expectLater(
      gateway.authorize(SocialAuthProvider.apple),
      throwsUnsupportedError,
    );
  });

  for (final platform in TargetPlatform.values.where(
    (p) => p != TargetPlatform.iOS,
  )) {
    test('$platform에서는 네이티브 판별·Apple SDK를 호출하지 않는다', () async {
      messenger.setMockMethodCallHandler(
        deviceChannel,
        (_) async => fail('native call'),
      );
      expect(await isAppleLoginSupported(targetPlatform: platform), isFalse);
      final gateway = SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: '',
        googleServerClientId: '',
        googleIosClientId: '',
        targetPlatform: platform,
        appleTokenLoader: () async => fail('SDK call'),
      );
      await expectLater(
        gateway.authorize(SocialAuthProvider.apple),
        throwsUnsupportedError,
      );
    });
  }

  for (final deviceResult in <Object?>[
    false,
    null,
    PlatformException(code: 'unavailable'),
    MissingPluginException(),
  ]) {
    test(
      'Apple 비활성 빌드·iPad·지원 판별 실패 $deviceResult 환경에서는 Apple SDK 접근을 차단한다',
      () async {
        messenger.setMockMethodCallHandler(deviceChannel, (call) async {
          expect(call.method, 'isAppleLoginSupported');
          if (deviceResult is Exception) throw deviceResult;
          return deviceResult;
        });
        final gateway = SdkSocialAuthCredentialGateway(
          kakaoNativeAppKey: '',
          googleServerClientId: '',
          googleIosClientId: '',
          targetPlatform: TargetPlatform.iOS,
          appleTokenLoader: () async => fail('SDK call'),
        );
        await expectLater(
          gateway.authorize(SocialAuthProvider.apple),
          throwsUnsupportedError,
        );
      },
    );
  }

  for (final talkInstalled in [true, false]) {
    test(
      'Kakao 네이티브 취소는 오류나 Account fallback 없이 종료한다 (Talk=$talkInstalled)',
      () async {
        final calls = <String>[];
        messenger.setMockMethodCallHandler(kakaoChannel, (call) async {
          calls.add(call.method);
          if (call.method == 'isKakaoTalkInstalled') return talkInstalled;
          if (call.method == 'authorizeWithTalk' ||
              call.method == 'accountLogin') {
            throw PlatformException(code: 'CANCELED');
          }
          return 'test';
        });
        KakaoSdk.init(nativeAppKey: 'test-native-key');
        final gateway = SdkSocialAuthCredentialGateway(
          kakaoNativeAppKey: 'test-native-key',
          googleServerClientId: '',
          googleIosClientId: '',
          targetPlatform: TargetPlatform.android,
        );
        await expectLater(
          gateway.authorize(SocialAuthProvider.kakao),
          throwsA(isA<SocialAuthCanceledException>()),
        );
        expect(
          calls.where((c) => c == 'authorizeWithTalk').length,
          talkInstalled ? 1 : 0,
        );
        expect(
          calls.where((c) => c == 'accountLogin').length,
          talkInstalled ? 0 : 1,
        );
      },
    );
  }

  group('SdkSocialAuthCredentialGateway', () {
    test('provider마다 백엔드가 기대하는 SDK token loader를 사용한다', () async {
      final gateway = SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: 'kakao-key',
        googleServerClientId: 'google-server-client',
        googleIosClientId: 'google-ios-client',
        targetPlatform: TargetPlatform.iOS,
        kakaoTokenLoader: () async => ' kakao-access-token ',
        googleTokenLoader: () async => 'google-id-token',
        appleTokenLoader: () async => 'apple-identity-token',
      );

      expect(
        await gateway.authorize(SocialAuthProvider.kakao),
        isCredential(SocialAuthProvider.kakao, 'kakao-access-token'),
      );
      expect(
        await gateway.authorize(SocialAuthProvider.google),
        isCredential(SocialAuthProvider.google, 'google-id-token'),
      );
      expect(
        await gateway.authorize(SocialAuthProvider.apple),
        isCredential(SocialAuthProvider.apple, 'apple-identity-token'),
      );
    });

    test('Google Android는 iOS client ID 없이 server client ID를 사용한다', () async {
      final gateway = SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: '',
        googleServerClientId: 'google-server-client',
        googleIosClientId: '',
        targetPlatform: TargetPlatform.android,
        googleTokenLoader: () async => 'google-id-token',
      );

      expect(
        await gateway.authorize(SocialAuthProvider.google),
        isCredential(SocialAuthProvider.google, 'google-id-token'),
      );
    });

    test('필수 provider 설정이 없으면 SDK를 호출하지 않는다', () async {
      var loaderCalled = false;
      final gateway = SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: '',
        googleServerClientId: '',
        googleIosClientId: '',
        targetPlatform: TargetPlatform.iOS,
        kakaoTokenLoader: () async {
          loaderCalled = true;
          return 'token';
        },
      );

      await expectLater(
        gateway.authorize(SocialAuthProvider.kakao),
        throwsA(isA<SocialAuthNotConfiguredException>()),
      );
      expect(loaderCalled, isFalse);
    });

    test('iOS가 아닌 환경에서는 Apple SDK를 호출하지 않는다', () async {
      var loaderCalled = false;
      final gateway = SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: '',
        googleServerClientId: '',
        googleIosClientId: '',
        targetPlatform: TargetPlatform.android,
        appleTokenLoader: () async {
          loaderCalled = true;
          return 'token';
        },
      );

      await expectLater(
        gateway.authorize(SocialAuthProvider.apple),
        throwsA(isA<UnsupportedError>()),
      );
      expect(loaderCalled, isFalse);
    });

    test('SDK token이 비어 있으면 API credential을 만들지 않는다', () async {
      final gateway = SdkSocialAuthCredentialGateway(
        kakaoNativeAppKey: 'kakao-key',
        googleServerClientId: '',
        googleIosClientId: '',
        targetPlatform: TargetPlatform.android,
        kakaoTokenLoader: () async => ' ',
      );

      await expectLater(
        gateway.authorize(SocialAuthProvider.kakao),
        throwsStateError,
      );
    });
  });
}

Matcher isCredential(SocialAuthProvider provider, String token) {
  return isA<SocialAuthCredential>()
      .having((credential) => credential.provider, 'provider', provider)
      .having((credential) => credential.token, 'token', token);
}
