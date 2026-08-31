import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_account_controller.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_settings_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _settingsSwitchScale = 0.78;

class UserSettingsPage extends ConsumerWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(userNotificationSettingProvider);
    final accountState = ref.watch(userAccountControllerProvider);

    return CommonScaffold(
      title: '설정',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textHeadline,
      ),
      bodyPadding: const EdgeInsets.only(
        top: AppSpacing.x10,
        bottom: AppSpacing.x24,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SettingsSectionTitle('알람설정'),
            _NotificationSettingCard(
              isEnabled: notificationsEnabled,
              onChanged: ref
                  .read(userNotificationSettingProvider.notifier)
                  .setEnabled,
            ),
            const SizedBox(height: AppSpacing.x16),
            const _SettingsDivider(),
            const SizedBox(height: AppSpacing.x16),
            const _SettingsSectionTitle('계정'),
            _AccountActionRow(
              label: '로그아웃',
              onTap: accountState.isSubmitting
                  ? null
                  : () => _confirmLogout(context, ref),
            ),
            _AccountActionRow(
              label: '회원탈퇴',
              onTap: accountState.isSubmitting
                  ? null
                  : () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCommonDialog<bool>(
      context: context,
      child: CommonDialogCard(
        title: '로그아웃',
        message: '현재 계정에서 로그아웃할까요?',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CommonDialogActionButton.confirm(
            label: '로그아웃',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _runAccountAction(
      context,
      ref,
      ref.read(userAccountControllerProvider.notifier).logout,
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showCommonDialog<bool>(
      context: context,
      child: CommonDialogCard(
        title: '회원 탈퇴',
        message: '계정과 연결된 정보를 삭제할까요?',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CommonDialogActionButton.confirm(
            label: '탈퇴',
            foregroundColor: AppColors.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _runAccountAction(
      context,
      ref,
      ref.read(userAccountControllerProvider.notifier).deleteAccount,
    );
  }

  Future<void> _runAccountAction(
    BuildContext context,
    WidgetRef ref,
    Future<bool> Function() action,
  ) async {
    final succeeded = await action();

    if (succeeded || !context.mounted) {
      return;
    }

    final message = ref.read(userAccountControllerProvider).errorMessage;
    if (message != null) {
      showCommonSnackBar(context, message);
    }
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x20,
        vertical: AppSpacing.x10,
      ),
      child: Text(
        title,
        style: AppTextStyles.size18Medium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textHeadline,
        ),
      ),
    );
  }
}

class _NotificationSettingCard extends StatelessWidget {
  const _NotificationSettingCard({
    required this.isEnabled,
    required this.onChanged,
  });

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
      child: Material(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x16,
            vertical: AppSpacing.x20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '알림 설정',
                      style: AppTextStyles.size16Medium.copyWith(
                        color: AppColors.textStrong,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: AppSpacing.x40,
                    height: AppSpacing.x24,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Transform.scale(
                        scale: _settingsSwitchScale,
                        child: Switch(
                          value: isEnabled,
                          onChanged: onChanged,
                          activeTrackColor: AppColors.brandStrong,
                          inactiveTrackColor: AppColors.borderDefault,
                          trackOutlineColor: const WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '물주기 및 식물의 상태를 알려드려요',
                style: AppTextStyles.size12Medium.copyWith(
                  color: AppColors.brandStrong,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountActionRow extends StatelessWidget {
  const _AccountActionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
      child: Material(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x16,
                vertical: AppSpacing.x20,
              ),
              child: Text(
                label,
                style: AppTextStyles.size16Medium.copyWith(
                  color: onTap == null
                      ? AppColors.textDisabled
                      : AppColors.textStrong,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: AppSpacing.x8,
      child: ColoredBox(color: AppColors.surfaceDisabled),
    );
  }
}
