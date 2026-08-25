import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userAccountControllerProvider =
    NotifierProvider.autoDispose<UserAccountController, FormSubmitState>(
      UserAccountController.new,
    );

class UserAccountController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() => const FormSubmitState.idle();

  Future<bool> logout() async {
    return _run(action: () async {}, failureMessage: '로그아웃하지 못했어요');
  }

  Future<bool> deleteAccount() async {
    return _run(
      action: () async {
        if (ref.read(useRemoteApiProvider)) {
          await ref.read(userRepositoryProvider).deleteMe();
        }
      },
      failureMessage: '회원 탈퇴를 완료하지 못했어요',
    );
  }

  Future<bool> _run({
    required Future<void> Function() action,
    required String failureMessage,
  }) async {
    if (state.isSubmitting) {
      return false;
    }

    state = const FormSubmitState.submitting();

    try {
      await action();
      state = const FormSubmitState.idle();
      await ref.read(authSessionControllerProvider.notifier).clearSession();

      return true;
    } catch (_) {
      state = FormSubmitState.failure(failureMessage);

      return false;
    }
  }
}
