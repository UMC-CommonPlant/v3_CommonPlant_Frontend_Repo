import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authResultFromJson', () {
    test('Swagger newUser=false 로그인 응답을 인증 완료 결과로 매핑한다', () {
      final result = authResultFromJson({
        'success': true,
        'result': {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
          'newUser': false,
        },
      });

      expect(result, isA<AuthenticatedResult>());
      final authenticated = result as AuthenticatedResult;
      expect(authenticated.newUser, isFalse);
      expect(authenticated.accessToken, 'access-token');
      expect(authenticated.refreshToken, 'refresh-token');
    });

    test('Swagger newUser=true 로그인 응답을 회원가입 필요 결과로 매핑한다', () {
      final result = authResultFromJson({
        'success': true,
        'result': {
          'signupToken': 'signup-token',
          'suggestedName': '커먼',
          'suggestedImgUrl': 'https://example.com/profile.png',
          'newUser': true,
        },
      });

      expect(result, isA<SignupRequiredResult>());
      final signup = result as SignupRequiredResult;
      expect(signup.newUser, isTrue);
      expect(signup.signupToken, 'signup-token');
      expect(signup.suggestedName, '커먼');
      expect(signup.suggestedImgUrl, 'https://example.com/profile.png');
    });
  });
}
