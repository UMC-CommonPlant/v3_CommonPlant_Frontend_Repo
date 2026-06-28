import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('remotePlantDetailProvider', () {
    test('식물 상세 조회를 repository에 위임한다', () async {
      final repository = _StaticPlantRepository(
        const PlantDetail(id: 'plant-1', name: '몬스테라'),
      );
      final container = ProviderContainer(
        overrides: [plantRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final detail = await container.read(
        remotePlantDetailProvider('plant-1').future,
      );

      expect(detail.id, 'plant-1');
      expect(detail.name, '몬스테라');
      expect(repository.lastPlantId, 'plant-1');
    });
  });
}

class _StaticPlantRepository extends PlantRepository {
  _StaticPlantRepository(this.detail) : super(PlantRemoteDataSource(Dio()));

  final PlantDetail detail;
  String? lastPlantId;

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    lastPlantId = plantId;
    return detail;
  }
}
