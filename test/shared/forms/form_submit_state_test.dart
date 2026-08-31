import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API 필드 오류와 안전한 요약 메시지를 제출 상태에 보존한다', () {
    const error = ApiException(
      message: '원격 상세 오류',
      statusCode: 400,
      code: 'C001',
      kind: ApiFailureKind.validation,
      fieldErrors: [
        ApiFieldError(field: 'request.name', reason: '이름을 확인해 주세요.'),
      ],
    );

    final state = FormSubmitState.failureFrom(
      error,
      fallbackMessage: '저장에 실패했어요.',
    );

    expect(state.errorMessage, '입력 내용을 확인해 주세요.');
    expect(state.fieldError('name'), '이름을 확인해 주세요.');
    expect(state.toString(), isNot(contains('원격 상세 오류')));
  });

  test('알 수 없는 오류는 기능별 fallback을 사용한다', () {
    final state = FormSubmitState.failureFrom(
      StateError('raw error'),
      fallbackMessage: '저장에 실패했어요.',
    );

    expect(state, const FormSubmitState.failure('저장에 실패했어요.'));
    expect(state.fieldErrors, isEmpty);
  });
}
