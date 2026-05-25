import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatePlantRequest', () {
    test('Swagger의 placeCode 필드로 식물 생성 요청을 직렬화한다', () {
      final request = CreatePlantRequest(
        placeCode: 'Abc123',
        nickname: '거실 몬스테라',
        scientificNameKo: '몬스테라',
        scientificNameEn: 'Monstera deliciosa',
        lastWateredDate: '2026-05-12',
        description: '햇빛이 잘 드는 거실에서 키우는 몬스테라입니다.',
      );

      final json = request.toJson();

      expect(json['placeCode'], 'Abc123');
      expect(json.containsKey('placeId'), isFalse);
      expect(json['nickname'], '거실 몬스테라');
      expect(json['lastWateredDate'], '2026-05-12');
    });
  });
}
