const int profileNicknameMinLength = 2;
const int profileNicknameMaxLength = 10;

enum ProfileSetupSubmitStatus { idle, submitting, success, failure }

class ProfileSetupState {
  const ProfileSetupState({
    required this.nickname,
    required this.hasImage,
    required this.isPrivacyTermsAccepted,
    required this.submitStatus,
    this.errorMessage,
  });

  const ProfileSetupState.initial()
    : this(
        nickname: '',
        hasImage: false,
        isPrivacyTermsAccepted: false,
        submitStatus: ProfileSetupSubmitStatus.idle,
      );

  final String nickname;
  final bool hasImage;
  final bool isPrivacyTermsAccepted;
  final ProfileSetupSubmitStatus submitStatus;
  final String? errorMessage;

  bool get hasValidNickname {
    final nicknameLength = nickname.trim().length;
    return nicknameLength >= profileNicknameMinLength &&
        nicknameLength <= profileNicknameMaxLength;
  }

  bool get isSubmitting => submitStatus == ProfileSetupSubmitStatus.submitting;

  bool get canSubmit => hasValidNickname && !isSubmitting;

  ProfileSetupState copyWith({
    String? nickname,
    bool? hasImage,
    bool? isPrivacyTermsAccepted,
    ProfileSetupSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileSetupState(
      nickname: nickname ?? this.nickname,
      hasImage: hasImage ?? this.hasImage,
      isPrivacyTermsAccepted:
          isPrivacyTermsAccepted ?? this.isPrivacyTermsAccepted,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
