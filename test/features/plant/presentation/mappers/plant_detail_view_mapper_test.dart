import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/mappers/plant_detail_view_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Swagger 상세 필드와 등록일을 원격 ViewData로 변환한다', () {
    final detail = mapPlantDetailToViewData(
      detail: const PlantDetail(
        id: 'plant-remote',
        name: '필로덴드론',
        species: 'Philodendron erubescens',
        placeName: '거실 정원',
        description: '반양지에서 관리해 주세요.',
        lastWateredDate: '2026-05-25',
        imageUrl: 'https://example.com/plant.jpg',
        memo: '새 잎이 자라고 있어요.',
        registeredAt: '2026-05-12T19:30:00',
      ),
      placeCode: 'fallback-place',
      now: DateTime(2026, 5, 25, 23, 59),
    );

    expect(detail?.placeCode, 'fallback-place');
    expect(detail?.placeName, '거실 정원');
    expect(detail?.name, '필로덴드론');
    expect(detail?.species, 'Philodendron erubescens');
    expect(detail?.imageUrl, 'https://example.com/plant.jpg');
    expect(detail?.startDate, '2026.05.12');
    expect(detail?.daysTogether, 14);
    expect(detail?.lastWateredDate, '2026.05.25');
    expect(detail?.plantInfo, '반양지에서 관리해 주세요.');
    expect(detail?.representativeMemo, '새 잎이 자라고 있어요.');
    expect(detail?.dDayLabel, isNull);
    expect(detail?.wateringCycleLabel, isNull);
    expect(detail?.memos, isEmpty);
    expect(detail?.supportsMemoActions, isFalse);
  });

  test('원격 응답에 없는 값은 fixture 대신 미제공 상태로 둔다', () {
    final detail = mapPlantDetailToViewData(
      detail: const PlantDetail(id: 'plant-remote', name: '알로카시아'),
      placeCode: null,
      now: DateTime(2026, 5, 25),
    );

    expect(detail?.placeName, '장소 정보 없음');
    expect(detail?.species, '학명 정보 없음');
    expect(detail?.imageAsset, isNull);
    expect(detail?.daysTogether, isNull);
    expect(detail?.startDate, isNull);
    expect(detail?.lastWateredDate, isNull);
    expect(detail?.representativeMemo, isNull);
    expect(detail?.memos, isEmpty);
  });

  test('등록 당일은 1일이고 미래·잘못된 등록일은 계산하지 않는다', () {
    final today = mapPlantDetailToViewData(
      detail: const PlantDetail(
        id: 'today',
        name: '오늘 등록',
        registeredAt: '2026-05-25',
      ),
      placeCode: null,
      now: DateTime(2026, 5, 25, 18),
    );
    final future = mapPlantDetailToViewData(
      detail: const PlantDetail(
        id: 'future',
        name: '미래 등록',
        registeredAt: '2026-05-26',
      ),
      placeCode: null,
      now: DateTime(2026, 5, 25),
    );
    final invalid = mapPlantDetailToViewData(
      detail: const PlantDetail(
        id: 'invalid',
        name: '잘못된 등록일',
        registeredAt: '2026-02-31',
      ),
      placeCode: null,
      now: DateTime(2026, 5, 25),
    );

    expect(today?.daysTogether, 1);
    expect(today?.startDate, '2026.05.25');
    expect(future?.daysTogether, isNull);
    expect(invalid?.daysTogether, isNull);
    expect(invalid?.startDate, isNull);
  });
}
