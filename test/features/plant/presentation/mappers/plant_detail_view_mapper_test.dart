import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/mappers/plant_detail_view_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote detail을 ViewData에 적용하고 없는 값은 fallback을 유지한다', () {
    final detail = mapPlantDetailToViewData(
      fallback: plantDetailFixture(placeCode: 'fallback-place'),
      detail: const PlantDetail(
        id: 'plant-remote',
        name: '필로덴드론',
        placeName: '거실 정원',
        lastWateredDate: '2026.05.25',
      ),
    );

    expect(detail?.placeCode, 'fallback-place');
    expect(detail?.placeName, '거실 정원');
    expect(detail?.name, '필로덴드론');
    expect(detail?.species, 'Monstera deliciosa');
    expect(detail?.lastWateredDate, '2026.05.25');
    expect(detail?.dDayLabel, 'D-3');
    expect(detail?.memos, hasLength(4));
  });
}
