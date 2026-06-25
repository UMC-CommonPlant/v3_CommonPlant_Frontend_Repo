import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/plant/data/mappers/plant_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('plantSummaryFromJson', () {
    test('Swagger PlantSummary 필드를 화면용 요약 모델로 매핑한다', () {
      final summary = plantSummaryFromJson({
        'plantId': 1,
        'nickname': '거실 몬스테라',
        'representativeImageUrl': 'https://example.com/monstera.png',
      });

      expect(summary.id, '1');
      expect(summary.name, '거실 몬스테라');
      expect(summary.imageUrl, 'https://example.com/monstera.png');
    });
  });

  group('plantDetailFromJson', () {
    test('Swagger DetailResponse를 상세 모델로 매핑한다', () {
      final detail = plantDetailFromJson({
        'plantId': 1,
        'scientificNameKo': '몬스테라',
        'scientificNameEn': 'Monstera deliciosa',
        'registeredAt': '2026-05-12T19:30:00',
        'lastWateredDate': '2026-05-12',
        'imageUrl': 'https://example.com/monstera.png',
        'memo': '새 잎이 올라옴',
        'placeName': '거실 정원',
        'plantInfo': '햇빛이 잘 드는 거실에서 키우는 몬스테라입니다.',
      }, fallbackId: '1');

      expect(detail.id, '1');
      expect(detail.name, '몬스테라');
      expect(detail.species, 'Monstera deliciosa');
      expect(detail.placeName, '거실 정원');
      expect(detail.description, '햇빛이 잘 드는 거실에서 키우는 몬스테라입니다.');
      expect(detail.lastWateredDate, '2026-05-12');
      expect(detail.imageUrl, 'https://example.com/monstera.png');
      expect(detail.memo, '새 잎이 올라옴');
      expect(detail.registeredAt, '2026-05-12T19:30:00');
    });
  });

  group('plantEditInfoFromJson', () {
    test('Swagger EditInfoResponse를 수정 정보 모델로 매핑한다', () {
      final editInfo = plantEditInfoFromJson(const <String, Object?>{
        'imageKey': 'images/user-nano-id/monstera.png',
        'imageUrl': 'https://example.com/monstera.png',
        'nickname': '거실 몬스테라',
        'lastWateredDate': '2026-05-12',
      });

      expect(editInfo.name, '거실 몬스테라');
      expect(editInfo.imageKey, 'images/user-nano-id/monstera.png');
      expect(editInfo.imageUrl, 'https://example.com/monstera.png');
      expect(editInfo.lastWateredDate, '2026-05-12');
    });
  });

  group('jsonListFromResponse + plantSummaryFromJson', () {
    test('Swagger 식물 목록 wrapper에서 요약 모델 목록을 만든다', () {
      final items = jsonListFromResponse({
        'result': {
          'content': {
            'items': [
              {
                'plantId': 1,
                'nickname': '거실 몬스테라',
                'representativeImageUrl': 'https://example.com/monstera.png',
              },
            ],
            'totalCount': 1,
            'page': 0,
            'size': 20,
          },
        },
      }, context: '식물 목록 조회');

      final summaries = [for (final item in items) plantSummaryFromJson(item)];

      expect(summaries, hasLength(1));
      expect(summaries.single.id, '1');
      expect(summaries.single.name, '거실 몬스테라');
      expect(summaries.single.imageUrl, 'https://example.com/monstera.png');
    });
  });
}
