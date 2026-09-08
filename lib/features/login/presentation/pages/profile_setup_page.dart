import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_setup_layout.dart';
import 'package:commonplant_frontend/shared/widgets/common_form_image_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupPage extends ConsumerWidget {
  const ProfileSetupPage({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final message = await ref
        .read(profileSetupControllerProvider.notifier)
        .selectImage();
    if (context.mounted && message != null) {
      showCommonSnackBar(context, message);
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutePaths.login);
  }

  void _openTerms(BuildContext context, TermsReturnDestination destination) {
    context.push(AppRoutePaths.termsLocation(next: destination.queryValue));
  }

  void _handleTermsCheck(BuildContext context, WidgetRef ref, bool isAccepted) {
    if (isAccepted) {
      ref
          .read(profileSetupControllerProvider.notifier)
          .setPrivacyTermsAccepted(false);
      return;
    }

    _openTerms(context, TermsReturnDestination.profile);
  }

  Future<void> _handleComplete(BuildContext context, WidgetRef ref) async {
    final isTermsAccepted = ref
        .read(profileSetupControllerProvider)
        .isPrivacyTermsAccepted;
    if (!isTermsAccepted) {
      _openTerms(context, TermsReturnDestination.home);
      return;
    }

    final didSubmit = await ref
        .read(profileSetupControllerProvider.notifier)
        .submit();

    if (!context.mounted) {
      return;
    }

    if (!didSubmit) {
      _showSubmitError(context, ref);
      return;
    }

    context.go(AppRoutePaths.home);
  }

  void _showSubmitError(BuildContext context, WidgetRef ref) {
    final message = ref.read(profileSetupControllerProvider).errorMessage;
    if (message == null) {
      return;
    }

    showCommonSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);

    return ProfileSetupLayout(
      imageField: CommonFormImageField(
        key: const ValueKey('profileAvatar'),
        isCircular: true,
        imageProvider: state.selectedImage == null
            ? null
            : MemoryImage(state.selectedImage!.bytes),
        isPicking: state.isPickingImage,
        onPick: state.isPickingImage || state.isSubmitting
            ? null
            : () => _pickImage(context, ref),
        onReset:
            state.selectedImage != null &&
                !state.isPickingImage &&
                !state.isSubmitting
            ? controller.clearSelectedImage
            : null,
      ),
      nickname: state.nickname,
      nicknameErrorMessage: state.nicknameErrorMessage,
      hasImage: state.hasImage,
      profileImageUrl: state.profileImageUrl,
      isTermsAccepted: state.isPrivacyTermsAccepted,
      isCompleteEnabled: state.canSubmit,
      isSubmitting: state.isSubmitting,
      onBack: () => _goBack(context),
      onImagePressed: () => _pickImage(context, ref),
      onNicknameChanged: controller.updateNickname,
      onTermsPressed: () =>
          _handleTermsCheck(context, ref, state.isPrivacyTermsAccepted),
      onTermsViewPressed: () =>
          _openTerms(context, TermsReturnDestination.profile),
      onComplete: () => _handleComplete(context, ref),
    );
  }
}

enum TermsReturnDestination {
  profile('profile'),
  home('home');

  const TermsReturnDestination(this.queryValue);

  final String queryValue;
}
