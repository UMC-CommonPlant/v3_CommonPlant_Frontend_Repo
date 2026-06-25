import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_delete_controller.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantDeleteController', () {
    test('remote 식물 삭제는 repository를 호출하고 홈 이동 결과를 반환한다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(plantDeleteControllerProvider.notifier)
          .delete(plantId: 'plant-1', placeCode: 'place-1');

      expect(result?.destination, PlantDeleteDestination.home);
      expect(repository.deleteCalls, 1);
      expect(repository.latestDeletedPlantId, 'plant-1');
      expect(repository.latestDeletedPlaceCode, 'place-1');
      expect(
        container.read(plantDeleteControllerProvider),
        const FormSubmitState.idle(),
      );
    });

    test('remote 식물 삭제 실패는 사용자 메시지 상태를 남긴다', () async {
      final repository = _FailingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(plantDeleteControllerProvider.notifier)
          .delete(plantId: 'plant-1', placeCode: 'place-1');

      expect(result, isNull);
      expect(repository.deleteCalls, 1);
      expect(
        container.read(plantDeleteControllerProvider),
        const FormSubmitState.failure('식물 삭제에 실패했어요'),
      );
    });

    test('placeCode가 없으면 원격 요청 없이 사용자 메시지 상태를 남긴다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(plantDeleteControllerProvider.notifier)
          .delete(plantId: 'plant-1', placeCode: ' ');

      expect(result, isNull);
      expect(repository.deleteCalls, 0);
      expect(
        container.read(plantDeleteControllerProvider),
        const FormSubmitState.failure('장소 정보를 확인할 수 없어요.'),
      );
    });

    test('local 식물 삭제는 원격 요청 없이 idle 상태를 유지한다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(false),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(plantDeleteControllerProvider.notifier)
          .delete(plantId: 'plant-1', placeCode: 'place-1');

      expect(result, isNull);
      expect(repository.deleteCalls, 0);
      expect(
        container.read(plantDeleteControllerProvider),
        const FormSubmitState.idle(),
      );
    });
  });
}

class _RecordingPlantRepository extends PlantRepository {
  _RecordingPlantRepository() : super(PlantRemoteDataSource(Dio()));

  int deleteCalls = 0;
  String? latestDeletedPlantId;
  String? latestDeletedPlaceCode;

  @override
  Future<void> deletePlant({
    required String plantId,
    required String placeCode,
  }) async {
    deleteCalls++;
    latestDeletedPlantId = plantId;
    latestDeletedPlaceCode = placeCode;
  }
}

class _FailingPlantRepository extends PlantRepository {
  _FailingPlantRepository() : super(PlantRemoteDataSource(Dio()));

  int deleteCalls = 0;

  @override
  Future<void> deletePlant({
    required String plantId,
    required String placeCode,
  }) async {
    deleteCalls++;
    throw StateError('raw failure');
  }
}
