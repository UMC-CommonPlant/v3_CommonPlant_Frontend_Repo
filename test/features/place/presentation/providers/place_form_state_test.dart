import 'package:commonplant_frontend/features/place/presentation/providers/place_form_state.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceFormState', () {
    test('이름·주소·제출 상태가 바뀌어도 기존 이미지 여부를 보존한다', () {
      const state = PlaceFormState.edit(
        placeId: 'place-1',
        name: '거실',
        address: '서울시',
        imageUrl: 'https://example.com/place.png',
      );
      final changed = state.copyWith(
        currentName: '루프탑',
        currentAddress: '경기도',
        submitState: const FormSubmitState.failure('요청 실패'),
      );

      expect(changed.initialImageUrl, state.initialImageUrl);
      expect(changed.hasExistingImage, isTrue);
      expect(const PlaceFormState.create().hasExistingImage, isFalse);
    });

    test('생성 상태는 이름이 입력되면 제출할 수 있다', () {
      const state = PlaceFormState.create();

      expect(state.isEdit, isFalse);
      expect(state.canSubmit, isFalse);
      expect(state.copyWith(currentName: ' 거실 ').canSubmit, isTrue);
    });

    test('수정 상태는 이름이나 주소가 달라진 경우에만 제출할 수 있다', () {
      const state = PlaceFormState.edit(
        placeId: 'place-1',
        name: '거실',
        address: '서울시 성북구',
      );

      expect(state.isEdit, isTrue);
      expect(state.hasChanges, isFalse);
      expect(state.canSubmit, isFalse);
      expect(state.copyWith(currentName: '루프탑').canSubmit, isTrue);
      expect(state.copyWith(currentAddress: null).canSubmit, isTrue);
    });

    test('로딩 중이거나 제출 중이면 제출할 수 없다', () {
      const loadingState = PlaceFormState.loading('place-1');
      final submittingState = const PlaceFormState.create().copyWith(
        currentName: '거실',
        submitState: const FormSubmitState.submitting(),
      );

      expect(loadingState.canSubmit, isFalse);
      expect(submittingState.canSubmit, isFalse);
    });

    test('실패 상태는 조회 오류 메시지를 보관한다', () {
      const state = PlaceFormState.failure('place-1', '조회 실패');

      expect(state.loadStatus, PlaceFormLoadStatus.failure);
      expect(state.loadErrorMessage, '조회 실패');
      expect(state.canSubmit, isFalse);
    });
  });
}
