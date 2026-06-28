import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state_provider.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_image_action_sheet.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_photo_permission_dialog.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_setup_layout.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  late final FormSubmitController _submitController;
  bool _hasImage = false;

  bool get _hasValidNickname {
    final nickname = _nicknameController.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  bool get _isSubmitting => _submitController.state.isSubmitting;

  @override
  void initState() {
    super.initState();
    _submitController = FormSubmitController()
      ..addListener(_handleSubmitStateChanged);
  }

  @override
  void dispose() {
    _submitController
      ..removeListener(_handleSubmitStateChanged)
      ..dispose();
    _nicknameFocusNode.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleSubmitStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openProfileImageSheet() async {
    _nicknameFocusNode.unfocus();

    final action = await showModalBottomSheet<ProfileImageSheetAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      elevation: 0,
      builder: (context) => const ProfileImageActionSheet(),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case ProfileImageSheetAction.selectFromAlbum:
        await _openPhotoPermissionDialog();
      case ProfileImageSheetAction.resetToDefault:
        setState(() => _hasImage = false);
    }
  }

  Future<void> _openPhotoPermissionDialog() async {
    final action = await showDialog<ProfilePhotoPermissionAction>(
      context: context,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      builder: (context) => const ProfilePhotoPermissionDialog(),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case ProfilePhotoPermissionAction.selectLimited:
      case ProfilePhotoPermissionAction.allowAll:
        setState(() => _hasImage = true);
      case ProfilePhotoPermissionAction.deny:
      case null:
        break;
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutePaths.login);
  }

  void _openTerms(TermsReturnDestination destination) {
    context.push(AppRoutePaths.termsLocation(next: destination.queryValue));
  }

  void _handleTermsCheck(bool isAccepted) {
    if (isAccepted) {
      ref
          .read(profileSetupStateProvider.notifier)
          .setPrivacyTermsAccepted(false);
      return;
    }

    _openTerms(TermsReturnDestination.profile);
  }

  Future<void> _handleComplete(bool isTermsAccepted) async {
    await _submitController.submit(() async {
      if (!mounted) {
        return;
      }

      if (isTermsAccepted) {
        context.go(AppRoutePaths.home);
        return;
      }

      _openTerms(TermsReturnDestination.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTermsAccepted = ref.watch(
      profileSetupStateProvider.select((state) => state.isPrivacyTermsAccepted),
    );

    return ProfileSetupLayout(
      nicknameController: _nicknameController,
      nicknameFocusNode: _nicknameFocusNode,
      hasImage: _hasImage,
      isTermsAccepted: isTermsAccepted,
      isCompleteEnabled: _hasValidNickname,
      isSubmitting: _isSubmitting,
      onBack: _goBack,
      onImagePressed: _openProfileImageSheet,
      onNicknameChanged: (_) => setState(() {}),
      onTermsPressed: () => _handleTermsCheck(isTermsAccepted),
      onTermsViewPressed: () => _openTerms(TermsReturnDestination.profile),
      onComplete: () => _handleComplete(isTermsAccepted),
    );
  }
}

enum TermsReturnDestination {
  profile('profile'),
  home('home');

  const TermsReturnDestination(this.queryValue);

  final String queryValue;
}
