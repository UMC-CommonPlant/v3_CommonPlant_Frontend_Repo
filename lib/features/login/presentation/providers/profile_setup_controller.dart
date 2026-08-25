import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String profileSetupSubmitFailureMessage = '프로필 설정에 실패했어요';

final profileSetupControllerProvider =
    NotifierProvider.autoDispose<ProfileSetupController, ProfileSetupState>(
      ProfileSetupController.new,
    );

class ProfileSetupController extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() {
    final session = ref.read(authSessionControllerProvider).value;

    if (session case AuthSessionState(
      status: AuthSessionStatus.signupRequired,
      :final suggestedName,
      :final suggestedImgUrl,
    )) {
      return ProfileSetupState.initial(
        nickname: suggestedName ?? '',
        profileImageUrl: suggestedImgUrl,
      );
    }

    return const ProfileSetupState.initial();
  }

  void updateNickname(String nickname) {
    state = state.copyWith(
      nickname: nickname,
      submitStatus: ProfileSetupSubmitStatus.idle,
      clearErrorMessage: true,
    );
  }

  void selectProfileImage() {
    state = state.copyWith(hasImage: true, clearProfileImageUrl: true);
  }

  void resetProfileImage() {
    state = state.copyWith(hasImage: false, clearProfileImageUrl: true);
  }

  void setPrivacyTermsAccepted(bool isAccepted) {
    state = state.copyWith(isPrivacyTermsAccepted: isAccepted);
  }

  void togglePrivacyTermsAccepted() {
    setPrivacyTermsAccepted(!state.isPrivacyTermsAccepted);
  }

  Future<bool> submit({Future<void> Function()? action}) async {
    if (!state.canSubmit) {
      return false;
    }

    state = state.copyWith(
      submitStatus: ProfileSetupSubmitStatus.submitting,
      clearErrorMessage: true,
    );

    try {
      if (action != null) {
        await action();
      } else if (ref.read(useRemoteApiProvider)) {
        await _register();
      }
      state = state.copyWith(submitStatus: ProfileSetupSubmitStatus.success);
      return true;
    } catch (_) {
      state = state.copyWith(
        submitStatus: ProfileSetupSubmitStatus.failure,
        errorMessage: profileSetupSubmitFailureMessage,
      );
      return false;
    }
  }

  Future<void> _register() async {
    final session = await ref.read(authSessionControllerProvider.future);
    final signupToken = session.signupToken;

    if (!session.isSignupRequired || signupToken == null) {
      throw StateError('회원가입 세션이 없습니다.');
    }

    final result = await ref
        .read(authRepositoryProvider)
        .register(
          RegisterRequest(
            signupToken: signupToken,
            name: state.nickname.trim(),
          ),
        );

    if (result is! AuthenticatedResult) {
      throw StateError('회원가입 후 인증 결과가 없습니다.');
    }

    ref.read(authSessionControllerProvider.notifier).applyAuthResult(result);
  }
}
