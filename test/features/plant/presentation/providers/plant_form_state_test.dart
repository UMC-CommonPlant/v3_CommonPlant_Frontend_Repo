import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const places = [
    PlantRegistrationPlace(id: 'place-1', name: '거실', imageAsset: 'living'),
    PlantRegistrationPlace(id: 'place-2', name: '작업실', imageAsset: 'work'),
  ];

  group('PlantFormState', () {
    test('생성 상태는 첫 장소를 선택하고 제출할 수 있다', () {
      final state = PlantFormState.create(plantName: '몬스테라', places: places);

      expect(state.isEdit, isFalse);
      expect(state.selectedPlace?.id, 'place-1');
      expect(state.canSubmit, isTrue);
    });

    test('생성 상태는 장소가 없거나 제출 중이면 제출할 수 없다', () {
      final emptyState = PlantFormState.create(
        plantName: '몬스테라',
        places: const [],
      );
      final submittingState = PlantFormState.create(
        plantName: '몬스테라',
        places: places,
      ).copyWith(submitState: const FormSubmitState.submitting());

      expect(emptyState.canSubmit, isFalse);
      expect(submittingState.canSubmit, isFalse);
    });

    test('수정 상태는 이름이 달라진 경우에만 제출할 수 있다', () {
      const state = PlantFormState.edit(
        plantId: 'plant-1',
        placeId: 'place-1',
        name: '몬테',
      );

      expect(state.isEdit, isTrue);
      expect(state.hasChanges, isFalse);
      expect(state.canSubmit, isFalse);
      expect(state.copyWith(currentName: '몬테라').canSubmit, isTrue);
    });

    test('로딩과 조회 실패 상태는 제출할 수 없다', () {
      const loadingState = PlantFormState.loadingEdit(
        plantId: 'plant-1',
        placeId: 'place-1',
      );
      const failureState = PlantFormState.failure(
        plantId: 'plant-1',
        placeId: 'place-1',
        message: '조회 실패',
      );

      expect(loadingState.canSubmit, isFalse);
      expect(failureState.canSubmit, isFalse);
      expect(failureState.loadErrorMessage, '조회 실패');
    });

    test('route 인자가 같으면 family Provider key도 같다', () {
      const first = PlantFormArgs(
        plantId: 'plant-1',
        placeId: 'place-1',
        initialPlantName: '몬스테라',
      );
      const second = PlantFormArgs(
        plantId: 'plant-1',
        placeId: 'place-1',
        initialPlantName: '몬스테라',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
