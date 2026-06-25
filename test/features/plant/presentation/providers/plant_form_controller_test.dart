import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantFormController', () {
    test('local 식물 생성은 목록에 추가하고 홈 이동 결과를 반환한다', () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final result = await container
          .read(plantFormControllerProvider.notifier)
          .submit(
            const PlantFormSubmitInput.create(
              plantName: '  몬스테라  ',
              placeId: 'place-1',
              placeName: '거실',
            ),
          );
      final plants = container.read(plantListProvider);

      expect(result?.destination, PlantFormSubmitDestination.home);
      expect(
        container.read(plantFormControllerProvider),
        const FormSubmitState.idle(),
      );
      expect(plants, hasLength(1));
      expect(plants.single.name, '몬스테라');
      expect(plants.single.placeId, 'place-1');
      expect(plants.single.placeName, '거실');
    });

    test('remote 식물 생성은 repository를 호출하고 local 목록도 갱신한다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(plantFormControllerProvider.notifier)
          .submit(
            const PlantFormSubmitInput.create(
              plantName: '몬스테라',
              placeId: 'place-1',
              placeName: '거실',
            ),
          );
      final plants = container.read(plantListProvider);

      expect(result?.destination, PlantFormSubmitDestination.home);
      expect(repository.createCalls, 1);
      expect(repository.latestCreateRequest?.toJson(), {
        'placeCode': 'place-1',
        'nickname': '몬스테라',
        'scientificNameKo': '몬스테라',
      });
      expect(plants.single.name, '몬스테라');
    });

    test('local 식물 수정은 목록 값을 갱신하고 상세 이동 결과를 반환한다', () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final plant = container
          .read(plantListProvider.notifier)
          .addPlant(name: '몬테', placeId: 'place-1', placeName: '거실');

      final result = await container
          .read(plantFormControllerProvider.notifier)
          .submit(
            PlantFormSubmitInput.update(
              plantId: plant.id,
              plantName: '몬테라',
              placeId: 'place-1',
            ),
          );
      final plants = container.read(plantListProvider);

      expect(result?.destination, PlantFormSubmitDestination.plantDetail);
      expect(result?.plantId, plant.id);
      expect(result?.placeId, 'place-1');
      expect(plants.single.name, '몬테라');
    });

    test('remote 식물 수정은 repository를 호출하고 상세 이동 결과를 반환한다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final result = await container
          .read(plantFormControllerProvider.notifier)
          .submit(
            const PlantFormSubmitInput.update(
              plantId: 'plant-1',
              plantName: '몬테라',
              placeId: 'place-1',
            ),
          );

      expect(result?.destination, PlantFormSubmitDestination.plantDetail);
      expect(repository.updateCalls, 1);
      expect(repository.latestUpdatePlantId, 'plant-1');
      expect(repository.latestUpdatePlaceCode, 'place-1');
      expect(repository.latestUpdateRequest?.toJson(), {'nickname': '몬테라'});
      expect(
        container.read(plantFormControllerProvider),
        const FormSubmitState.idle(),
      );
    });
  });
}

class _RecordingPlantRepository extends PlantRepository {
  _RecordingPlantRepository() : super(PlantRemoteDataSource(Dio()));

  int createCalls = 0;
  int updateCalls = 0;
  String? latestUpdatePlantId;
  String? latestUpdatePlaceCode;
  CreatePlantRequest? latestCreateRequest;
  UpdatePlantRequest? latestUpdateRequest;

  @override
  Future<void> createPlant(
    CreatePlantRequest request, {
    MultipartFile? image,
  }) async {
    createCalls++;
    latestCreateRequest = request;
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    required UpdatePlantRequest request,
    MultipartFile? image,
  }) async {
    updateCalls++;
    latestUpdatePlantId = plantId;
    latestUpdatePlaceCode = placeCode;
    latestUpdateRequest = request;
  }
}
