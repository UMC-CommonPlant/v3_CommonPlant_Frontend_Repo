import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
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

    test('remote detail을 적용할 때 없는 값은 fallback을 유지한다', () {
      final detail = plantDetailFixture(placeCode: 'fallback-place')
          .applyRemote(
            const PlantDetail(
              id: 'plant-remote',
              name: '필로덴드론',
              placeName: '거실 정원',
              lastWateredDate: '2026.05.25',
            ),
          );

      expect(detail.placeCode, 'fallback-place');
      expect(detail.placeName, '거실 정원');
      expect(detail.name, '필로덴드론');
      expect(detail.species, 'Monstera deliciosa');
      expect(detail.lastWateredDate, '2026.05.25');
      expect(detail.dDayLabel, 'D-3');
      expect(detail.memos, hasLength(4));
    });
  });
}
