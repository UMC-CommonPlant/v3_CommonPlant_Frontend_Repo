import 'package:commonplant_frontend/features/place/data/mappers/place_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
