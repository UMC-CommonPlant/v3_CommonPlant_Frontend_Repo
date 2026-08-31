import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';

class UserProfileEditArgs {
  const UserProfileEditArgs({required this.user});

  final UserProfile user;

  @override
  bool operator ==(Object other) {
    return other is UserProfileEditArgs && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

class UserProfileEditState {
  const UserProfileEditState({
    required this.initialName,
    required this.currentName,
    required this.submitState,
  });

  factory UserProfileEditState.initial(UserProfile user) {
    return UserProfileEditState(
      initialName: user.name.trim(),
      currentName: user.name.trim(),
      submitState: const FormSubmitState.idle(),
    );
  }

  final String initialName;
  final String currentName;
  final FormSubmitState submitState;

  String get normalizedName => currentName.trim();

  bool get isNameValid {
    return normalizedName.length >= 2 && normalizedName.length <= 10;
  }

  bool get hasChanges => normalizedName != initialName;

  bool get isSubmitting => submitState.isSubmitting;

  String? get nameErrorMessage => submitState.fieldError('name');

  bool get canSubmit => isNameValid && hasChanges && !isSubmitting;

  UserProfileEditState copyWith({
    String? initialName,
    String? currentName,
    FormSubmitState? submitState,
  }) {
    return UserProfileEditState(
      initialName: initialName ?? this.initialName,
      currentName: currentName ?? this.currentName,
      submitState: submitState ?? this.submitState,
    );
  }
}
