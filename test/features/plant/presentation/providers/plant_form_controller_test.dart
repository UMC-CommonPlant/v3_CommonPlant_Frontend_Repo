import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
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
      controller.updateLastWateredDate(DateTime(2026, 8, 25));

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

      final controller = container.read(
        plantFormControllerProvider(args).notifier,
      );
      controller.updateLastWateredDate(DateTime(2026, 8, 5));
      final result = await controller.submit();
      final plants = container.read(plantListProvider);

      expect(result?.destination, PlantFormSubmitDestination.home);
      expect(repository.createCalls, 1);
      expect(repository.latestCreatePlaceCode, 'place-1');
      expect(repository.latestCreateNickname, '몬스테라');
      expect(repository.latestCreateScientificNameKo, isNull);
      expect(repository.latestCreateLastWateredDate, '2026-08-05');
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
      expect(initialState.currentLastWateredDate, '2026-05-25');

      controller.updateName('몬테라');
      controller.updateLastWateredDate(DateTime(2026, 8, 24));
      final result = await controller.submit();

      expect(result?.destination, PlantFormSubmitDestination.plantDetail);
      expect(repository.updateCalls, 1);
      expect(repository.latestUpdatePlantId, 'plant-1');
      expect(repository.latestUpdatePlaceCode, 'place-1');
      expect(repository.latestUpdateNickname, '몬테라');
      expect(repository.latestUpdateLastWateredDate, '2026-08-24');
    });
  });
}

class _RecordingPlantRepository extends Fake implements PlantRepository {
  int createCalls = 0;
  int updateCalls = 0;
  String? latestUpdatePlantId;
  String? latestUpdatePlaceCode;
  String? latestCreatePlaceCode;
  String? latestCreateNickname;
  String? latestCreateScientificNameKo;
  String? latestCreateLastWateredDate;
  String? latestUpdateNickname;
  String? latestUpdateLastWateredDate;

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    return const PlantEditInfo(name: '몬테', lastWateredDate: '2026-05-25');
  }

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  }) async {
    createCalls++;
    latestCreatePlaceCode = placeCode;
    latestCreateNickname = nickname;
    latestCreateScientificNameKo = scientificNameKo;
    latestCreateLastWateredDate = lastWateredDate;
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
  }) async {
    updateCalls++;
    latestUpdatePlantId = plantId;
    latestUpdatePlaceCode = placeCode;
    latestUpdateNickname = nickname;
    latestUpdateLastWateredDate = lastWateredDate;
  }
}
