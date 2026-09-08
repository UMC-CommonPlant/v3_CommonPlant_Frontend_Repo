import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('주기는 기본값 없이 필수 검증하고 생성·수정·재진입에서 유지한다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final create = plantFormControllerProvider(
      const PlantFormArgs(initialPlantName: '새 식물'),
    );
    container.listen(create, (_, _) {});
    await container.pump();
    final controller = container.read(create.notifier);
    expect(container.read(create).wateringCycleDays, isNull);
    expect(await controller.submit(), isNull);
    for (final value in [
      '',
      '0',
      '-1',
      '1.5',
      'abc',
      '999999999999999999999999999',
    ]) {
      controller.updateWateringCycle(value);
      expect(container.read(create).canSubmit, isFalse, reason: value);
    }
    controller.updateWateringCycle('7');
    expect(container.read(create).canSubmit, isTrue);
    expect(await controller.submit(), isNotNull);
    final plant = container.read(plantListProvider).single;
    expect(plant.wateringCycleDays, 7);

    final edit = plantFormControllerProvider(PlantFormArgs(plantId: plant.id));
    final subscription = container.listen(edit, (_, _) {});
    expect(container.read(edit).wateringCycleInput, '7');
    expect(container.read(edit).canSubmit, isFalse);
    container.read(edit.notifier).updateWateringCycle('14');
    expect(container.read(edit).canSubmit, isTrue);
    expect(await container.read(edit.notifier).submit(), isNotNull);
    subscription.close();
    await container.pump();
    container.listen(edit, (_, _) {});
    expect(container.read(edit).wateringCycleInput, '14');
    expect(
      container
          .read(
            plantLocalDetailViewProvider((plantId: plant.id, placeCode: null)),
          )
          .wateringCycleLabel,
      '14일마다',
    );
  });

  test('API 모드는 주기 계약이 없으면 null을 유지하고 입력을 저장한 척하지 않는다', () async {
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(true),
        plantRegistrationPlaceProvider.overrideWith(
          (ref) => plantRegistrationPlaceFallbacks,
        ),
      ],
    );
    addTearDown(container.dispose);
    final form = plantFormControllerProvider(const PlantFormArgs());
    container.listen(form, (_, _) {});
    await container.read(plantRegistrationPlaceProvider.future);
    await container.pump();
    expect(container.read(form).wateringCycleSupported, isFalse);
    container.read(form.notifier).updateWateringCycle('7');
    expect(container.read(form).wateringCycleDays, isNull);
    expect(container.read(form).wateringCycleInput, isEmpty);
  });

  test('수정 정보의 주기 초기값을 쓰고 없으면 비워 둔다', () {
    for (final days in [null, 12]) {
      final container = ProviderContainer(
        overrides: [
          plantFormEditInfoProvider('p').overrideWithValue(
            AsyncData(PlantEditInfo(name: '식물', wateringCycleDays: days)),
          ),
        ],
      );
      final form = plantFormControllerProvider(
        const PlantFormArgs(plantId: 'p'),
      );
      container.listen(form, (_, _) {});
      expect(container.read(form).wateringCycleDays, days);
      expect(container.read(form).wateringCycleInput, days?.toString() ?? '');
      container.dispose();
    }
  });

  test('샘플 수정 이후 새 식물 ID는 기존 값을 덮어쓰지 않는다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final list = container.read(plantListProvider.notifier);
    list.updatePlant(id: 'plant-1', name: '기존', wateringCycleDays: 3);
    final created = list.addPlant(name: '신규', wateringCycleDays: 7);
    expect(created.id, isNot('plant-1'));
    expect(container.read(plantListProvider).map((p) => p.wateringCycleDays), [
      3,
      7,
    ]);
  });
}
