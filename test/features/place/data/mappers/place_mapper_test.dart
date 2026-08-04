import 'package:commonplant_frontend/features/place/data/mappers/place_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('placeSummariesFromResponse', () {
    test('wrapper 응답에서 장소 요약 목록을 만든다', () {
      final summaries = placeSummariesFromResponse({
        'result': {
          'content': {
            'items': [
              {
                'placeCode': 'place-nano-id',
                'placeName': '거실 정원',
                'placeAddress': '서울시 성북구',
              },
            ],
          },
        },
      });

      expect(summaries, hasLength(1));
      expect(summaries.single.id, 'place-nano-id');
      expect(summaries.single.name, '거실 정원');
      expect(summaries.single.address, '서울시 성북구');
    });
  });

  group('placeSummaryFromResponse', () {
    test('wrapper 응답에서 fallbackId를 보존해 장소 요약을 만든다', () {
      final summary = placeSummaryFromResponse({
        'result': {'name': '루프탑'},
      }, fallbackId: 'fallback-place');

      expect(summary.id, 'fallback-place');
      expect(summary.name, '루프탑');
    });
  });

  group('placeSummaryFromJson', () {
    test('Swagger 장소 필드를 화면용 요약 모델로 매핑한다', () {
      final summary = placeSummaryFromJson(const <String, Object?>{
        'placeCode': 'place-nano-id',
        'placeName': '거실 정원',
        'placeAddress': '서울시 성북구',
      });

      expect(summary.id, 'place-nano-id');
      expect(summary.name, '거실 정원');
      expect(summary.address, '서울시 성북구');
    });

    test('id 필드가 없으면 fallbackId를 사용한다', () {
      final summary = placeSummaryFromJson(const <String, Object?>{
        'name': '루프탑',
      }, fallbackId: 'fallback-place');

      expect(summary.id, 'fallback-place');
      expect(summary.name, '루프탑');
    });
  });
}
