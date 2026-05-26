import 'dart:async';

import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('submit은 진행 중 상태를 노출하고 중복 실행을 막는다', () async {
    final controller = FormSubmitController();
    final completer = Completer<void>();
    final states = <FormSubmitState>[];
    var submitCalls = 0;

    addTearDown(controller.dispose);
    controller.addListener(() => states.add(controller.state));

    final submitFuture = controller.submit(() {
      submitCalls++;
      return completer.future;
    });
    await Future<void>.delayed(Duration.zero);

    expect(controller.state, const FormSubmitState.submitting());

    await controller.submit(() async {
      submitCalls++;
    });

    completer.complete();
    await submitFuture;

    expect(submitCalls, 1);
    expect(states, [
      const FormSubmitState.submitting(),
      const FormSubmitState.idle(),
    ]);
  });

  test('submit 실패는 사용자 메시지 상태로 남기고 다시 제출할 수 있다', () async {
    final controller = FormSubmitController();

    addTearDown(controller.dispose);

    await controller.submit(
      () async => throw StateError('raw failure'),
      failureMessage: '저장에 실패했어요',
    );

    expect(controller.state, const FormSubmitState.failure('저장에 실패했어요'));
    expect(controller.state.isSubmitting, isFalse);

    await controller.submit(() async {});

    expect(controller.state, const FormSubmitState.idle());
  });
}
