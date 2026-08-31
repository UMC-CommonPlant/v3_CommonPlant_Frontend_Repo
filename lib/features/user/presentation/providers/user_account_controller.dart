import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
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
  FormSubmitState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return const FormSubmitState.idle();
  }

  Future<bool> logout() async {
    return _run(action: () async {}, failureMessage: '로그아웃하지 못했어요');
  }

  Future<bool> deleteAccount() async {
    return _run(
      action: () async {
        if (ref.read(useRemoteApiProvider)) {
          if (!ref.read(userDataSessionProvider).isActive) {
            throw StateError('회원 탈퇴를 진행할 로그인 세션이 없습니다.');
          }
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

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    state = const FormSubmitState.submitting();

    try {
      await action();
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = const FormSubmitState.idle();
      await ref.read(authSessionControllerProvider.notifier).clearSession();

      return true;
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = FormSubmitState.failureFrom(
        error,
        fallbackMessage: failureMessage,
      );

      return false;
    }
  }
}
