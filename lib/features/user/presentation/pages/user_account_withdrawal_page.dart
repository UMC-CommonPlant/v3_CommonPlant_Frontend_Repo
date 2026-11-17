import 'dart:math' as math;

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_account_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserAccountWithdrawalPage extends ConsumerStatefulWidget {
  const UserAccountWithdrawalPage({super.key});

  @override
  ConsumerState<UserAccountWithdrawalPage> createState() =>
      _UserAccountWithdrawalPageState();
}

class _UserAccountWithdrawalPageState
    extends ConsumerState<UserAccountWithdrawalPage> {
  bool _acknowledged = false;
  bool _hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(userAccountControllerProvider);
    final isSubmitting = submission.isSubmitting;

    return PopScope(
      canPop: !isSubmitting,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.surfaceBase,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.surfaceBase,
          body: SafeArea(
            child: Column(
              children: [
                CommonNavigationBar(
                  title: '회원탈퇴',
                  titleStyle: AppTextStyles.size18Medium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textStrong,
                  ),
                  backIcon: Transform.translate(
                    offset: const Offset(4.73, 0),
                    child: Transform.rotate(
                      angle: 3 * math.pi / 4,
                      child: Transform.flip(
                        flipX: true,
                        child: const CommonSvgIcon(
                          AppIconAssets.withdrawalBackChevron,
                          width: 13.5,
                          height: 13.5,
                          semanticsLabel: '뒤로 가기',
                        ),
                      ),
                    ),
                  ),
                  onBackPressed: () {
                    if (isSubmitting) return;
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutePaths.userSettings);
                    }
                  },
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: _WithdrawalNotices()),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: ColoredBox(
                          color: AppColors.surfaceAlt,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ColoredBox(
                              color: AppColors.surfaceBase,
                              child: _WithdrawalActions(
                                acknowledged: _acknowledged,
                                isSubmitting: isSubmitting,
                                errorMessage: _hasSubmitted
                                    ? submission.errorMessage
                                    : null,
                                onToggle: () => setState(
                                  () => _acknowledged = !_acknowledged,
                                ),
                                onDelete: _deleteAccount,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _hasSubmitted = true);
    final succeeded = await ref
        .read(userAccountControllerProvider.notifier)
        .deleteAccount();
    if (succeeded && mounted) context.go(AppRoutePaths.login);
  }
}

class _WithdrawalNotices extends StatelessWidget {
  const _WithdrawalNotices();

  static const _notices = [
    '회원 탈퇴 시 이 계정으로 이용하던 장소와 메모에 접근할 수 없습니다.',
    '탈퇴가 완료되면 앱에서 탈퇴를 취소하거나 계정을 복구할 수 없습니다.',
    '탈퇴한 계정으로 다시 로그인할 수 없습니다.',
  ];

  @override
  Widget build(BuildContext context) {
    final noticeStyle = AppTextStyles.size14Medium.copyWith(
      color: AppColors.textStrong,
      fontWeight: FontWeight.w400,
    );

    return ColoredBox(
      color: AppColors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x20,
          AppSpacing.x16 + AppSpacing.x20,
          AppSpacing.x20,
          AppSpacing.x40 + AppSpacing.x16,
        ),
        child: Column(
          children: [
            Text(
              '커먼님 잠시만요 !',
              textAlign: TextAlign.center,
              style: AppTextStyles.size24Medium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.x24),
            const CommonSvgIcon(
              AppImageAssets.accountWithdrawalIllustration,
              width: 148,
              height: 148,
            ),
            const SizedBox(
              height: AppSpacing.x40 + AppSpacing.x24 + AppSpacing.x10,
            ),
            Column(
              spacing: AppSpacing.x16,
              children: [
                for (final notice in _notices)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      SizedBox(
                        width: AppSpacing.x20,
                        child: ExcludeSemantics(
                          child: Text(
                            '•',
                            textAlign: TextAlign.center,
                            style: noticeStyle.copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                      Expanded(child: Text(notice, style: noticeStyle)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalActions extends StatelessWidget {
  const _WithdrawalActions({
    required this.acknowledged,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onToggle,
    required this.onDelete,
  });

  final bool acknowledged;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x24,
        AppSpacing.x20,
        AppSpacing.x32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x16,
        children: [
          MergeSemantics(
            child: Semantics(
              checked: acknowledged,
              enabled: !isSubmitting,
              child: InkWell(
                onTap: isSubmitting ? null : onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.x16),
                  child: Row(
                    spacing: AppSpacing.x12,
                    children: [
                      if (acknowledged)
                        const Icon(
                          Icons.check_circle,
                          size: AppSizes.iconMedium,
                          color: AppColors.brandStrong,
                        )
                      else
                        const CommonSvgIcon(
                          AppIconAssets.checkCircleUnselected,
                          width: AppSizes.iconMedium,
                          height: AppSizes.iconMedium,
                        ),
                      Expanded(
                        child: Text(
                          '유의사항을 모두 확인하였습니다.',
                          style: AppTextStyles.size16Medium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (errorMessage case final message?)
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: AppTextStyles.size14Medium.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          CommonButton(
            label: '계정 삭제하기',
            onPressed: acknowledged && !isSubmitting ? onDelete : null,
            backgroundColor: acknowledged && !isSubmitting
                ? AppColors.danger
                : null,
            isLoading: isSubmitting,
          ),
        ],
      ),
    );
  }
}
