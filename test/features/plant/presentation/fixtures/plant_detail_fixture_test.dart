import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('plantDetailFixture', () {
    test('local 식물 상세 fallback 데이터를 만든다', () {
      final detail = plantDetailFixture(placeCode: 'place-1');

      expect(detail.placeCode, 'place-1');
      expect(detail.placeName, '스윗홈_거실');
      expect(detail.name, '몬테');
      expect(detail.species, 'Monstera deliciosa');
      expect(detail.dDayLabel, 'D-3');
      expect(detail.wateringCycleLabel, '10 Day');
      expect(detail.memos, hasLength(4));
      expect(detail.memos.first.author, '커먼플랜트');
    });
  });
}
