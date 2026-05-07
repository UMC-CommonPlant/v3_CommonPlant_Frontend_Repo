import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileSetupStateProvider =
    NotifierProvider<ProfileSetupStateNotifier, ProfileSetupState>(
      ProfileSetupStateNotifier.new,
    );

class ProfileSetupState {
  const ProfileSetupState({this.isPrivacyTermsAccepted = false});

  final bool isPrivacyTermsAccepted;

  ProfileSetupState copyWith({bool? isPrivacyTermsAccepted}) {
    return ProfileSetupState(
      isPrivacyTermsAccepted:
          isPrivacyTermsAccepted ?? this.isPrivacyTermsAccepted,
    );
  }
}

class ProfileSetupStateNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() {
    return const ProfileSetupState();
  }

  void setPrivacyTermsAccepted(bool isAccepted) {
    state = state.copyWith(isPrivacyTermsAccepted: isAccepted);
  }

  void togglePrivacyTermsAccepted() {
    setPrivacyTermsAccepted(!state.isPrivacyTermsAccepted);
  }
}
