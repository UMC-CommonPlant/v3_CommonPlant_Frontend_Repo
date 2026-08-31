import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_place_code_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  group('plantDetailViewProvider', () {
    test('local mode는 fixture 상세를 즉시 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        plantDetailViewProvider((plantId: 'plant-1', placeCode: 'place-1')),
      );

      final detail = state.requireValue;
      expect(detail?.name, '몬테');
      expect(detail?.placeCode, 'place-1');
      expect(detail?.placeName, '스윗홈_거실');
    });

    test('remote mode는 PlantDetail을 원격 전용 ViewData로 변환한다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(
          id: 'remote-plant',
          name: '필로덴드론',
          placeId: 'remote-place',
          placeName: '거실 정원',
          species: 'Philodendron',
          lastWateredDate: '2026-05-25',
          registeredAt: '2026-05-20T10:30:00',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          plantDetailNowProvider.overrideWithValue(() => DateTime(2026, 5, 25)),
        ],
      );
      addTearDown(container.dispose);

      final request = (plantId: 'remote-plant', placeCode: 'fallback-place');
      await container.read(plantRemoteDetailViewProvider(request).future);

      final detail = container
          .read(plantDetailViewProvider(request))
          .requireValue;

      expect(detail?.name, '필로덴드론');
      expect(detail?.placeCode, 'remote-place');
      expect(detail?.placeName, '거실 정원');
      expect(detail?.species, 'Philodendron');
      expect(detail?.lastWateredDate, '2026.05.25');
      expect(detail?.startDate, '2026.05.20');
      expect(detail?.daysTogether, 6);
      expect(detail?.memos, isEmpty);
      expect(detail?.dDayLabel, isNull);
      expect(repository.fetchCalls, 1);
    });

    test('remote mode에서 빈 상세는 null data로 표시한다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(id: 'empty-plant', name: ''),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final request = (plantId: 'empty-plant', placeCode: null);
      await container.read(plantRemoteDetailViewProvider(request).future);

      expect(
        container.read(plantDetailViewProvider(request)).requireValue,
        isNull,
      );
    });

    test('route 장소 code가 있으면 정규화하고 resolver를 호출하지 않는다', () async {
      var resolverCalls = 0;
      final repository = _StaticPlantRepository(
        const PlantDetail(id: 'remote-plant', name: '필로덴드론'),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          remotePlantPlaceCodeProvider('remote-plant').overrideWith((
            ref,
          ) async {
            resolverCalls++;
            return 'resolved-place';
          }),
        ],
      );
      addTearDown(container.dispose);

      const request = (plantId: 'remote-plant', placeCode: ' ROUTE-PLACE ');
      final detail = await container.read(
        plantRemoteDetailViewProvider(request).future,
      );

      expect(detail?.placeCode, 'ROUTE-PLACE');
      expect(resolverCalls, 0);
    });

    test('route와 Plant 응답에 code가 없으면 resolver 결과를 사용한다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(id: 'remote-plant', name: '필로덴드론'),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          remotePlantPlaceCodeProvider(
            'remote-plant',
          ).overrideWith((ref) async => 'resolved-place'),
        ],
      );
      addTearDown(container.dispose);

      const request = (plantId: 'remote-plant', placeCode: null);
      final detail = await container.read(
        plantRemoteDetailViewProvider(request).future,
      );

      expect(detail?.placeCode, 'resolved-place');
    });

    test('resolver가 찾지 못한 code를 첫 장소로 대체하지 않는다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(id: 'remote-plant', name: '필로덴드론'),
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          remotePlantPlaceCodeProvider(
            'remote-plant',
          ).overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      const request = (plantId: 'remote-plant', placeCode: null);
      final detail = await container.read(
        plantRemoteDetailViewProvider(request).future,
      );

      expect(detail?.placeCode, isNull);
    });
  });
}

class _StaticPlantRepository extends Fake implements PlantRepository {
  _StaticPlantRepository(this.detail);

  final PlantDetail detail;
  int fetchCalls = 0;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    fetchCalls++;
    return detail;
  }
}
