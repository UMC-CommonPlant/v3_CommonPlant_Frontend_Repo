import 'dart:async';

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

import '../../../../helpers/user_data_session.dart';

void main() {
  group('PlantFormController', () {
    for (final isEdit in [false, true]) {
      for (final fails in [false, true]) {
        test(
          '식물 ${isEdit ? '수정' : '생성'} 중 입력해도 한 번만 제출하고 ${fails ? '실패 후 재시도한다' : '이동 결과를 한 번 반환한다'}',
          () async {
            final barrier = Completer<void>();
            final repository = _RecordingPlantRepository()
              ..writeBarrier = barrier;
            final container = ProviderContainer(
              overrides: [
                authenticatedUserDataSession,
                useRemoteApiProvider.overrideWithValue(true),
                plantRepositoryProvider.overrideWithValue(repository),
                plantRegistrationPlaceProvider.overrideWith(
                  (ref) => plantRegistrationPlaceFallbacks,
                ),
              ],
            );
            addTearDown(container.dispose);
            final args = PlantFormArgs(
              plantId: isEdit ? 'plant-1' : null,
              placeId: isEdit ? 'place-1' : null,
              initialPlantName: '첫 제출',
            );
            final provider = plantFormControllerProvider(args);
            container.listen(provider, (_, _) {});
            if (isEdit) {
              await container.read(
                remotePlantFormEditInfoProvider('plant-1').future,
              );
            } else {
              await container.read(plantRegistrationPlaceProvider.future);
            }
            await container.pump();
            final controller = container.read(provider.notifier);
            controller.updateName('첫 제출');
            controller.updateLastWateredDate(DateTime(2026, 8, 20));
            final first = controller.submit();
            final duplicates = <Future<PlantFormSubmitResult?>>[];
            final pendingStates = <PlantFormState>[];

            for (final edit in <void Function()>[
              () => controller.updateName('다음 제출'),
              () => controller.updateLastWateredDate(DateTime(2026, 8, 21)),
              if (!isEdit)
                () =>
                    controller.selectPlace(plantRegistrationPlaceFallbacks[1]),
            ]) {
              edit();
              pendingStates.add(container.read(provider));
              duplicates.add(controller.submit());
            }
            if (fails) {
              barrier.completeError(StateError('첫 요청 실패'));
            } else {
              barrier.complete();
            }
            final results = await Future.wait([first, ...duplicates]);

            expect(pendingStates.every((state) => state.isSubmitting), isTrue);
            expect(pendingStates.every((state) => !state.canSubmit), isTrue);
            expect(pendingStates.last.currentName, '다음 제출');
            expect(pendingStates.last.currentLastWateredDate, '2026-08-21');
            expect(isEdit ? repository.updateCalls : repository.createCalls, 1);
            expect(
              isEdit
                  ? repository.latestUpdateNickname
                  : repository.latestCreateNickname,
              '첫 제출',
            );
            expect(
              isEdit
                  ? repository.latestUpdateLastWateredDate
                  : repository.latestCreateLastWateredDate,
              '2026-08-20',
            );
            if (!isEdit) expect(repository.latestCreatePlaceCode, 'place-1');
            expect(results.skip(1), everyElement(isNull));
            if (!fails) {
              expect(
                results.first?.destination,
                isEdit
                    ? PlantFormSubmitDestination.plantDetail
                    : PlantFormSubmitDestination.home,
              );
              return;
            }

            expect(results.first, isNull);
            expect(container.read(provider).submitErrorMessage, isNotNull);
            expect(container.read(provider).canSubmit, isTrue);
            repository.writeBarrier = null;
            expect(await controller.submit(), isNotNull);
            expect(isEdit ? repository.updateCalls : repository.createCalls, 2);
            expect(
              isEdit
                  ? repository.latestUpdateNickname
                  : repository.latestCreateNickname,
              '다음 제출',
            );
            expect(
              isEdit
                  ? repository.latestUpdateLastWateredDate
                  : repository.latestCreateLastWateredDate,
              '2026-08-21',
            );
            if (!isEdit) expect(repository.latestCreatePlaceCode, 'place-2');
          },
        );
      }
    }

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
          authenticatedUserDataSession,
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
          authenticatedUserDataSession,
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
      expect(repository.updatedImageKeys, [null]);
    });

    for (final changeName in [true, false]) {
      test('${changeName ? '이름' : '날짜'}만 수정해도 기존 이미지 key를 전달한다', () async {
        final repository = _RecordingPlantRepository(
          editInfo: const PlantEditInfo(
            name: '몬테',
            lastWateredDate: '2026-05-25',
            imageKey: 'images/existing.png',
            imageUrl: 'https://example.com/existing.png?signature=old',
          ),
        );
        final container = ProviderContainer(
          overrides: [
            authenticatedUserDataSession,
            useRemoteApiProvider.overrideWithValue(true),
            plantRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        const args = PlantFormArgs(plantId: 'plant-1', placeId: 'place-1');
        final subscription = container.listen(
          plantFormControllerProvider(args),
          (previous, next) {},
        );
        addTearDown(subscription.close);
        await container.read(remotePlantFormEditInfoProvider('plant-1').future);
        await container.pump();
        final controller = container.read(
          plantFormControllerProvider(args).notifier,
        );

        if (changeName) {
          controller.updateName('몬테라');
        } else {
          controller.updateLastWateredDate(DateTime(2026, 8, 24));
        }
        final result = await controller.submit();

        expect(result?.destination, PlantFormSubmitDestination.plantDetail);
        expect(repository.updatedImageKeys, ['images/existing.png']);
      });
    }

    for (final imageKey in [null, '   ']) {
      test('사진 URL만 있고 유효한 key가 없으면 수정 요청을 막는다 ($imageKey)', () async {
        final repository = _RecordingPlantRepository(
          editInfo: PlantEditInfo(
            name: '몬테',
            imageKey: imageKey,
            imageUrl: 'https://example.com/existing.png',
          ),
        );
        final container = ProviderContainer(
          overrides: [
            authenticatedUserDataSession,
            useRemoteApiProvider.overrideWithValue(true),
            plantRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        const args = PlantFormArgs(plantId: 'plant-1', placeId: 'place-1');
        final subscription = container.listen(
          plantFormControllerProvider(args),
          (previous, next) {},
        );
        addTearDown(subscription.close);
        await container.read(remotePlantFormEditInfoProvider('plant-1').future);
        await container.pump();
        final controller = container.read(
          plantFormControllerProvider(args).notifier,
        );

        controller.updateName('몬테라');
        final result = await controller.submit();

        expect(result, isNull);
        expect(repository.updateCalls, 0);
        final state = container.read(plantFormControllerProvider(args));
        expect(state.submitErrorMessage, contains('기존 사진'));
        expect(state.currentName, '몬테라');
        expect(state.isSubmitting, isFalse);
      });
    }

    test('수정 실패 후 입력을 바꿔 재시도해도 기존 이미지 key를 보존한다', () async {
      final repository = _RecordingPlantRepository(
        editInfo: const PlantEditInfo(
          name: '몬테',
          imageKey: 'images/existing.png',
        ),
        failFirstUpdate: true,
      );
      final container = ProviderContainer(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          plantRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      const args = PlantFormArgs(plantId: 'plant-1', placeId: 'place-1');
      final subscription = container.listen(
        plantFormControllerProvider(args),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await container.read(remotePlantFormEditInfoProvider('plant-1').future);
      await container.pump();
      final controller = container.read(
        plantFormControllerProvider(args).notifier,
      );

      controller.updateName('몬테라');
      expect(await controller.submit(), isNull);
      controller.updateLastWateredDate(DateTime(2026, 8, 24));
      final result = await controller.submit();

      expect(result?.destination, PlantFormSubmitDestination.plantDetail);
      expect(repository.updatedImageKeys, [
        'images/existing.png',
        'images/existing.png',
      ]);
    });
  });
}

class _RecordingPlantRepository extends Fake implements PlantRepository {
  _RecordingPlantRepository({
    this.editInfo = const PlantEditInfo(
      name: '몬테',
      lastWateredDate: '2026-05-25',
    ),
    this.failFirstUpdate = false,
  });

  final PlantEditInfo editInfo;
  final bool failFirstUpdate;
  Completer<void>? writeBarrier;
  final List<String?> updatedImageKeys = [];
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
    return editInfo;
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
    await writeBarrier?.future;
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
    updatedImageKeys.add(imageKey);
    latestUpdatePlantId = plantId;
    latestUpdatePlaceCode = placeCode;
    latestUpdateNickname = nickname;
    latestUpdateLastWateredDate = lastWateredDate;
    await writeBarrier?.future;

    if (failFirstUpdate && updateCalls == 1) {
      throw StateError('첫 수정 실패');
    }
  }
}
