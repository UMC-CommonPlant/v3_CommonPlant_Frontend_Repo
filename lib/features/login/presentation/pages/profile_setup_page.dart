import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_image_action_sheet.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_photo_permission_dialog.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_setup_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupPage extends ConsumerWidget {
  const ProfileSetupPage({super.key});

  Future<void> _openProfileImageSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final action = await showModalBottomSheet<ProfileImageSheetAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      elevation: 0,
      builder: (context) => const ProfileImageActionSheet(),
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case ProfileImageSheetAction.selectFromAlbum:
        await _openPhotoPermissionDialog(context, ref);
      case ProfileImageSheetAction.resetToDefault:
        ref.read(profileSetupControllerProvider.notifier).resetProfileImage();
    }
  }

  Future<void> _openPhotoPermissionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final action = await showDialog<ProfilePhotoPermissionAction>(
      context: context,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      builder: (context) => const ProfilePhotoPermissionDialog(),
    );

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case ProfilePhotoPermissionAction.selectLimited:
      case ProfilePhotoPermissionAction.allowAll:
        ref.read(profileSetupControllerProvider.notifier).selectProfileImage();
      case ProfilePhotoPermissionAction.deny:
      case null:
        break;
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);

    return ProfileSetupLayout(
      nickname: state.nickname,
      hasImage: state.hasImage,
      profileImageUrl: state.profileImageUrl,
      isTermsAccepted: state.isPrivacyTermsAccepted,
      isCompleteEnabled: state.canSubmit,
      isSubmitting: state.isSubmitting,
      onBack: () => _goBack(context),
      onImagePressed: () => _openProfileImageSheet(context, ref),
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
