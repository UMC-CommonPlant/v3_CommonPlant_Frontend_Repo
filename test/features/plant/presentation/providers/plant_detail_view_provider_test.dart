import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('remote mode는 PlantDetail을 fixture 상세에 병합한다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(
          id: 'remote-plant',
          name: '필로덴드론',
          placeId: 'remote-place',
          placeName: '거실 정원',
          species: 'Philodendron',
          lastWateredDate: '2026.05.25',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final request = (plantId: 'remote-plant', placeCode: 'fallback-place');
      await container.read(remotePlantDetailViewProvider(request).future);

      final detail = container
          .read(plantDetailViewProvider(request))
          .requireValue;

      expect(detail?.name, '필로덴드론');
      expect(detail?.placeCode, 'remote-place');
      expect(detail?.placeName, '거실 정원');
      expect(detail?.species, 'Philodendron');
      expect(detail?.lastWateredDate, '2026.05.25');
      expect(repository.fetchCalls, 1);
    });

    test('remote mode에서 빈 상세는 null data로 표시한다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(id: 'empty-plant', name: ''),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final request = (plantId: 'empty-plant', placeCode: null);
      await container.read(remotePlantDetailViewProvider(request).future);

      expect(
        container.read(plantDetailViewProvider(request)).requireValue,
        isNull,
      );
    });
  });
}

class _StaticPlantRepository extends PlantRepository {
  _StaticPlantRepository(this.detail) : super(PlantRemoteDataSource(Dio()));

  final PlantDetail detail;
  int fetchCalls = 0;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    fetchCalls++;
    return detail;
  }
}
