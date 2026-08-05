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
    state = state.copyWith(hasImage: true);
  }

  void resetProfileImage() {
    state = state.copyWith(hasImage: false);
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
      await action?.call();
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
}
