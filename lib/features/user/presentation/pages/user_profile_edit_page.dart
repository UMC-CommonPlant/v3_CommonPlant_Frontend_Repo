import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_profile_edit_state.dart';
import 'package:commonplant_frontend/features/user/presentation/widgets/user_profile_avatar.dart';
import 'package:commonplant_frontend/features/user/presentation/widgets/user_profile_name_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserProfileEditPage extends ConsumerWidget {
  const UserProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).unwrapPrevious();

    return currentUser.when(
      data: (user) => _UserProfileEditForm(user: user),
      error: (error, stackTrace) => CommonScaffold(
        title: '회원 정보 수정',
        navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
          color: AppColors.textHeadline,
        ),
        child: _ProfileEditStatus(
          message: '회원 정보를 불러오지 못했어요',
          actionLabel: '다시 시도',
          onAction: () => ref.invalidate(currentUserProvider),
        ),
      ),
      loading: () => const CommonScaffold(
        title: '회원 정보 수정',
        navigationTitleStyle: AppTextStyles.size18Medium,
        child: _ProfileEditStatus(message: '회원 정보를 불러오고 있어요', isLoading: true),
      ),
    );
  }
}

class _UserProfileEditForm extends ConsumerWidget {
  const _UserProfileEditForm({required this.user});

  final UserProfile user;

  UserProfileEditArgs get _args => UserProfileEditArgs(user: user);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userProfileEditControllerProvider(_args));
    final controller = ref.read(
      userProfileEditControllerProvider(_args).notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              CommonNavigationBar(
                title: '회원 정보 수정',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textHeadline,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x20,
                    AppSpacing.x24,
                    AppSpacing.x20,
                    AppSpacing.x24,
                  ),
                  child: Column(
                    children: [
                      UserProfileAvatar(
                        size: AppSizes.profileImageBoxSize,
                        imageUrl: user.imgUrl,
                        onEditPressed: () => _showImagePickerNotice(context),
                      ),
                      const SizedBox(height: AppSpacing.x16),
                      UserProfileNameField(
                        name: formState.currentName,
                        onChanged: controller.updateName,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x20,
                  AppSpacing.x12,
                  AppSpacing.x20,
                  AppSpacing.x40,
                ),
                child: CommonButton(
                  label: '수정 완료',
                  fullWidth: true,
                  isLoading: formState.isSubmitting,
                  onPressed: formState.canSubmit
                      ? () => _submit(context, ref)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필 사진 변경은 이미지 선택 정책 확정 후 연결됩니다')),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final provider = userProfileEditControllerProvider(_args);
    final succeeded = await ref.read(provider.notifier).submit();

    if (!context.mounted) {
      return;
    }

    if (succeeded) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutePaths.userProfile);
      }
      return;
    }

    final message = ref.read(provider).submitErrorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _ProfileEditStatus extends StatelessWidget {
  const _ProfileEditStatus({
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(height: AppSpacing.x16),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.size16Medium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.x16),
            CommonButton.secondary(
              label: actionLabel!,
              size: CommonButtonSize.medium,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
