import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateUserRequest', () {
    test('Swagger UserUpdateRequest 필드만 JSON으로 직렬화한다', () {
      const request = UpdateUserRequest(
        name: '커먼',
        introduction: '몬스테라를 키우는 식집사입니다.',
      );

      expect(request.toJson(), {
        'name': '커먼',
        'introduction': '몬스테라를 키우는 식집사입니다.',
      });
    });
  });
}
