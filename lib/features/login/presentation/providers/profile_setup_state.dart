const int profileNicknameMinLength = 2;
const int profileNicknameMaxLength = 10;

enum ProfileSetupSubmitStatus { idle, submitting, success, failure }

class ProfileSetupState {
  const ProfileSetupState({
    required this.nickname,
    required this.hasImage,
    required this.profileImageUrl,
    required this.isPrivacyTermsAccepted,
    required this.submitStatus,
    this.errorMessage,
  });

  const ProfileSetupState.initial({
    String nickname = '',
    String? profileImageUrl,
  }) : this(
         nickname: nickname,
         hasImage: profileImageUrl != null,
         profileImageUrl: profileImageUrl,
         isPrivacyTermsAccepted: false,
         submitStatus: ProfileSetupSubmitStatus.idle,
       );

  final String nickname;
  final bool hasImage;
  final String? profileImageUrl;
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
    String? profileImageUrl,
    bool? isPrivacyTermsAccepted,
    ProfileSetupSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearProfileImageUrl = false,
  }) {
    return ProfileSetupState(
      nickname: nickname ?? this.nickname,
      hasImage: hasImage ?? this.hasImage,
      profileImageUrl: clearProfileImageUrl
          ? null
          : profileImageUrl ?? this.profileImageUrl,
      isPrivacyTermsAccepted:
          isPrivacyTermsAccepted ?? this.isPrivacyTermsAccepted,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
