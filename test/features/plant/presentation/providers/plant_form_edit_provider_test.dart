import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('plantFormEditInfoProvider', () {
    test('local mode는 기본 수정 정보를 즉시 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(plantFormEditInfoProvider('plant-1'));

      final info = state.requireValue;
      expect(info?.name, '몬테');
      expect(info?.lastWateredDate, isNull);
    });

    test('remote mode는 식물 수정 정보를 반환한다', () async {
      final repository = _StaticPlantRepository(
        const PlantEditInfo(name: '필로덴드론', lastWateredDate: '2026.05.25'),
      );
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(
        remotePlantFormEditInfoProvider('remote-plant').future,
      );

      final info = container
          .read(plantFormEditInfoProvider('remote-plant'))
          .requireValue;

      expect(info?.name, '필로덴드론');
      expect(info?.lastWateredDate, '2026.05.25');
      expect(repository.fetchCalls, 1);
    });

    test('수정 정보 remote 조회를 repository에 위임한다', () async {
      final repository = _StaticPlantRepository(
        const PlantEditInfo(name: '필로덴드론', lastWateredDate: '2026.05.25'),
      );
      final container = ProviderContainer(
        overrides: [plantRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final info = await container.read(
        remotePlantEditInfoProvider('remote-plant').future,
      );

      expect(info.name, '필로덴드론');
      expect(repository.lastPlantId, 'remote-plant');
    });

    test('remote mode에서 빈 수정 정보는 null data로 표시한다', () async {
      final repository = _StaticPlantRepository(const PlantEditInfo(name: ''));
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(
        remotePlantFormEditInfoProvider('empty-plant').future,
      );

      expect(
        container.read(plantFormEditInfoProvider('empty-plant')).requireValue,
        isNull,
      );
    });
  });
}

class _StaticPlantRepository extends PlantRepository {
  _StaticPlantRepository(this.editInfo) : super(PlantRemoteDataSource(Dio()));

  final PlantEditInfo editInfo;
  int fetchCalls = 0;
  String? lastPlantId;

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    fetchCalls++;
    lastPlantId = plantId;
    return editInfo;
  }
}
