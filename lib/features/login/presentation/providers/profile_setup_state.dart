import 'package:commonplant_frontend/features/image/data/models/selected_image.dart';

const int _profileNicknameMinLength = 2;
const int profileNicknameMaxLength = 10;

final _unsupportedNicknameCharacter = RegExp(r'[^a-zA-Z가-힣 \t\n\x0B\f\r]');

String? validateProfileNickname(String value) {
  final nickname = value.trim();
  if (nickname.length < _profileNicknameMinLength ||
      nickname.length > profileNicknameMaxLength) {
    return '$_profileNicknameMinLength~$profileNicknameMaxLength자의 닉네임으로 입력해 주세요';
  }
  if (_unsupportedNicknameCharacter.hasMatch(nickname)) {
    return '닉네임은 한글, 영문, 공백만 사용할 수 있어요';
  }
  return null;
}

enum ProfileSetupSubmitStatus { idle, submitting, success, failure }

class ProfileSetupState {
  const ProfileSetupState({
    required this.nickname,
    required this.hasImage,
    required this.profileImageUrl,
    required this.isAgeConfirmed,
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
         isAgeConfirmed: false,
         isPrivacyTermsAccepted: false,
         submitStatus: ProfileSetupSubmitStatus.idle,
       );

  final SelectedImage? selectedImage;
  final bool isPickingImage;

  final String nickname;
  final bool hasImage;
  final String? profileImageUrl;
  final bool isAgeConfirmed;
  final bool isPrivacyTermsAccepted;
  final ProfileSetupSubmitStatus submitStatus;
  final String? errorMessage;
  final String? nicknameErrorMessage;

  bool get hasValidNickname => validateProfileNickname(nickname) == null;

  bool get isSubmitting => submitStatus == ProfileSetupSubmitStatus.submitting;

  bool get canSubmit =>
      hasValidNickname && isAgeConfirmed && !isSubmitting && !isPickingImage;

  ProfileSetupState copyWith({
    SelectedImage? selectedImage,
    bool clearSelectedImage = false,
    bool? isPickingImage,
    String? nickname,
    bool? hasImage,
    String? profileImageUrl,
    bool? isAgeConfirmed,
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
      isAgeConfirmed: isAgeConfirmed ?? this.isAgeConfirmed,
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
