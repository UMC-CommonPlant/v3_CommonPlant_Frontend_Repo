import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantFormController', () {
    test('local 식물 생성은 선택 장소와 plant draft를 목록에 저장한다', () async {
      final container = ProviderContainer();
      const args = PlantFormArgs(initialPlantName: ' 몬스테라 ');
      final subscription = container.listen(
        plantFormControllerProvider(args),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(
        plantFormControllerProvider(args).notifier,
      );
      controller.selectPlace(plantRegistrationPlaceFallbacks[1]);

      final result = await controller.submit();
      final plants = container.read(plantListProvider);

      expect(result?.destination, PlantFormSubmitDestination.home);
      expect(
        container.read(plantFormControllerProvider(args)).submitState,
        const FormSubmitState.idle(),
      );
      expect(plants, hasLength(1));
      expect(plants.single.name, '몬스테라');
      expect(plants.single.placeId, 'place-2');
      expect(plants.single.placeName, '낫 스윗 회사_가든');
    });

    test('remote 식물 생성은 Provider 장소를 사용해 repository를 호출한다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
          plantRegistrationPlaceProvider.overrideWith(
            (ref) => [plantRegistrationPlaceFallbacks.first],
          ),
        ],
      );
      const args = PlantFormArgs(initialPlantName: '몬스테라');
      final subscription = container.listen(
        plantFormControllerProvider(args),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      await container.read(plantRegistrationPlaceProvider.future);
      await Future<void>.delayed(Duration.zero);

      final result = await container
          .read(plantFormControllerProvider(args).notifier)
          .submit();
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

    test('local 식물 수정은 조회 초기값과 변경한 이름을 목록에 반영한다', () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final plant = container
          .read(plantListProvider.notifier)
          .addPlant(name: '몬테', placeId: 'place-1', placeName: '거실');
      final args = PlantFormArgs(plantId: plant.id, placeId: 'place-1');
      final subscription = container.listen(
        plantFormControllerProvider(args),
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final initialState = container.read(plantFormControllerProvider(args));
      final controller = container.read(
        plantFormControllerProvider(args).notifier,
      );

      expect(initialState.loadStatus, PlantFormLoadStatus.ready);
      expect(initialState.currentName, '몬테');
      expect(initialState.canSubmit, isFalse);

      controller.updateName('몬테라');
      final result = await controller.submit();
      final plants = container.read(plantListProvider);

      expect(result?.destination, PlantFormSubmitDestination.plantDetail);
      expect(result?.plantId, plant.id);
      expect(result?.placeId, 'place-1');
      expect(plants.single.name, '몬테라');
    });

    test('remote 식물 수정은 조회값을 draft로 사용하고 repository를 호출한다', () async {
      final repository = _RecordingPlantRepository();
      final container = ProviderContainer(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      const args = PlantFormArgs(plantId: 'plant-1', placeId: 'place-1');
      final subscription = container.listen(
        plantFormControllerProvider(args),
        (previous, next) {},
      );

      addTearDown(subscription.close);
      addTearDown(container.dispose);

      await container.read(remotePlantFormEditInfoProvider('plant-1').future);
      await Future<void>.delayed(Duration.zero);

      final initialState = container.read(plantFormControllerProvider(args));
      final controller = container.read(
        plantFormControllerProvider(args).notifier,
      );

      expect(initialState.currentName, '몬테');

      controller.updateName('몬테라');
      final result = await controller.submit();

      expect(result?.destination, PlantFormSubmitDestination.plantDetail);
      expect(repository.updateCalls, 1);
      expect(repository.latestUpdatePlantId, 'plant-1');
      expect(repository.latestUpdatePlaceCode, 'place-1');
      expect(repository.latestUpdateRequest?.toJson(), {'nickname': '몬테라'});
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
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    return const PlantEditInfo(name: '몬테');
  }

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
