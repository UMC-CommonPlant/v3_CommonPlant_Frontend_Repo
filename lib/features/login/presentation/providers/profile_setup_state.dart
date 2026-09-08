import 'package:commonplant_frontend/features/image/data/models/selected_image.dart';

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
    this.selectedImage,
    this.isPickingImage = false,
    this.errorMessage,
    this.nicknameErrorMessage,
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

  final SelectedImage? selectedImage;
  final bool isPickingImage;

  final String nickname;
  final bool hasImage;
  final String? profileImageUrl;
  final bool isPrivacyTermsAccepted;
  final ProfileSetupSubmitStatus submitStatus;
  final String? errorMessage;
  final String? nicknameErrorMessage;

  bool get hasValidNickname {
    final nicknameLength = nickname.trim().length;
    return nicknameLength >= profileNicknameMinLength &&
        nicknameLength <= profileNicknameMaxLength;
  }

  bool get isSubmitting => submitStatus == ProfileSetupSubmitStatus.submitting;

  bool get canSubmit => hasValidNickname && !isSubmitting && !isPickingImage;

  ProfileSetupState copyWith({
    SelectedImage? selectedImage,
    bool clearSelectedImage = false,
    bool? isPickingImage,
    String? nickname,
    bool? hasImage,
    String? profileImageUrl,
    bool? isPrivacyTermsAccepted,
    ProfileSetupSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? nicknameErrorMessage,
    bool clearNicknameErrorMessage = false,
    bool clearProfileImageUrl = false,
  }) {
    return ProfileSetupState(
      selectedImage: clearSelectedImage
          ? null
          : selectedImage ?? this.selectedImage,
      isPickingImage: isPickingImage ?? this.isPickingImage,
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
      nicknameErrorMessage: clearNicknameErrorMessage
          ? null
          : nicknameErrorMessage ?? this.nicknameErrorMessage,
    );
  }
}
