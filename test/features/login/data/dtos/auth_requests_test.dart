import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterRequest', () {
    test('Swagger 회원가입 JSON 필드만 직렬화한다', () {
      const request = RegisterRequest(
        signupToken: 'signup-token',
        name: '커먼',
        introduction: '식물을 함께 키워요.',
      );

      expect(request.toJson(), {
        'signupToken': 'signup-token',
        'name': '커먼',
        'introduction': '식물을 함께 키워요.',
      });
    });

    test('선택값인 introduction이 없으면 JSON에서 생략한다', () {
      const request = RegisterRequest(signupToken: 'signup-token', name: '커먼');

      expect(request.toJson(), {'signupToken': 'signup-token', 'name': '커먼'});
    });
  });
}
