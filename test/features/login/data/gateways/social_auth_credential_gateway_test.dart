import 'package:commonplant_frontend/features/login/data/gateways/social_auth_credential_gateway.dart';
import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
