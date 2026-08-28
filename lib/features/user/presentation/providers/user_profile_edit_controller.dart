import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_state.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileEditControllerProvider = NotifierProvider.autoDispose
    .family<
      UserProfileEditController,
      UserProfileEditState,
      UserProfileEditArgs
    >(UserProfileEditController.new);

class UserProfileEditController extends Notifier<UserProfileEditState> {
  UserProfileEditController(this.args);

  final UserProfileEditArgs args;
  UserDataSession? _initialSession;

  @override
  UserProfileEditState build() {
    if (ref.watch(useRemoteApiProvider)) {
      final session = ref.watch(userDataSessionProvider);
      _initialSession ??= session;
      if (!identical(_initialSession, session)) {
        return const UserProfileEditState(
          initialName: '',
          currentName: '',
          submitState: FormSubmitState.idle(),
        );
      }
    }
    return UserProfileEditState.initial(args.user);
  }

  void updateName(String name) {
    state = state.copyWith(
      currentName: name,
      submitState: state.isSubmitting
          ? state.submitState
          : const FormSubmitState.idle(),
    );
  }

  Future<bool> submit() async {
    if (!state.canSubmit) {
      return false;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (ref.read(useRemoteApiProvider) &&
        (!session.isActive || !identical(_initialSession, session))) {
      return false;
    }
    state = state.copyWith(submitState: const FormSubmitState.submitting());

    try {
      final updatedUser = await _updateUser(state.normalizedName);
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = state.copyWith(
        initialName: updatedUser.name.trim(),
        currentName: updatedUser.name.trim(),
        submitState: const FormSubmitState.idle(),
      );
      ref.read(currentUserProvider.notifier).replace(updatedUser);

      return true;
    } catch (_) {
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = state.copyWith(
        submitState: const FormSubmitState.failure('회원 정보를 수정하지 못했어요'),
      );

      return false;
    }
  }

  Future<UserProfile> _updateUser(String name) async {
    if (!ref.read(useRemoteApiProvider)) {
      return args.user.copyWith(name: name);
    }

    return ref
        .read(userRepositoryProvider)
        .updateMe(UpdateUserRequest(name: name));
  }
}
