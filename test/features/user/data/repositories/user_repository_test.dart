import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('userProfileFromJson', () {
    test('Swagger UserResponse를 사용자 프로필 모델로 매핑한다', () {
      final profile = userProfileFromJson({
        'name': '커먼',
        'id': 'user-nano-id',
        'email': 'common@example.com',
        'provider': 'GOOGLE',
        'imgUrl': 'https://example.com/profile.png',
        'introduction': '몬스테라를 키우는 식집사입니다.',
      });

      expect(profile.id, 'user-nano-id');
      expect(profile.name, '커먼');
      expect(profile.email, 'common@example.com');
      expect(profile.provider, 'GOOGLE');
      expect(profile.imgUrl, 'https://example.com/profile.png');
      expect(profile.introduction, '몬스테라를 키우는 식집사입니다.');
    });
  });

  group('jsonListFromResponse + userProfileFromJson', () {
    test('Swagger UserListJsonResponse에서 사용자 목록을 만든다', () {
      final items = jsonListFromResponse({
        'result': [
          {
            'name': '커먼',
            'id': 'user-nano-id',
            'email': 'common@example.com',
            'provider': 'KAKAO',
          },
        ],
      }, context: '사용자 검색');

      final profiles = [for (final item in items) userProfileFromJson(item)];

      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'user-nano-id');
      expect(profiles.single.name, '커먼');
      expect(profiles.single.provider, 'KAKAO');
    });
  });
}
