import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('loginAuthResultFromJson', () {
    test('isNewUser=false 실제 응답을 인증 완료 결과로 매핑한다', () {
      final result = loginAuthResultFromJson({
        'success': true,
        'result': {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
          'isNewUser': false,
        },
      });

      expect(result, isA<AuthenticatedResult>());
      final authenticated = result as AuthenticatedResult;
      expect(authenticated.accessToken, 'access-token');
      expect(authenticated.refreshToken, 'refresh-token');
    });

    test('isNewUser=true 실제 응답을 회원가입 필요 결과로 매핑한다', () {
      final result = loginAuthResultFromJson({
        'success': true,
        'result': {
          'signupToken': 'signup-token',
          'suggestedName': '커먼',
          'suggestedImgUrl': 'https://example.com/profile.png',
          'isNewUser': true,
        },
      });

      expect(result, isA<SignupRequiredResult>());
      final signup = result as SignupRequiredResult;
      expect(signup.signupToken, 'signup-token');
      expect(signup.suggestedName, '커먼');
      expect(signup.suggestedImgUrl, 'https://example.com/profile.png');
    });

    test('OpenAPI newUser 필드는 배포 호환 입력으로 허용한다', () {
      final result = loginAuthResultFromJson({
        'result': {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
          'newUser': false,
        },
      });

      expect(result, isA<AuthenticatedResult>());
    });

    test('신규 여부 필드가 없으면 signupToken으로 추론하지 않는다', () {
      expect(
        () => loginAuthResultFromJson({
          'result': {'signupToken': 'signup-token'},
        }),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('registerAuthResultFromJson', () {
    test('isNewUser=true가 있어도 가입 완료 token을 인증 결과로 매핑한다', () {
      final result = registerAuthResultFromJson({
        'result': {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
          'isNewUser': true,
        },
      });

      expect(result.accessToken, 'access-token');
      expect(result.refreshToken, 'refresh-token');
    });
  });
}
