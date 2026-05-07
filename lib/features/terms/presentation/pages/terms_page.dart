import 'dart:math' as math;

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _figmaFrameWidth = 375;
const double _figmaFrameHeight = 812;
const double _sheetRearTop = 40;
const double _sheetTop = 50;
const double _sheetRadius = 10;
const double _headerTop = 63;
const double _bodyTop = 135;
const double _bottomActionsTop = 610;
const double _termsCheckRowHeight = 72;

const String _privacyTermsBody =
    'Lorem ipsum dolor sit amet consectetur. Ut scelerisque aliquet nisl '
    'facilisi molestie porttitor risus eget. Erat mattis gravida quis '
    'consequat. Leo aenean scelerisque at dolor ultrices pellentesque est '
    'fermentum aliquam. Eget viverra risus ac sem lacus sed pellentesque nibh. '
    'Neque et vel urna tortor et proin. Sollicitudin at tempor pharetra eget. '
    'Faucibus ipsum faucibus risus odio aliquam tristique non enim amet. Quam '
    'quam ullamcorper semper proin quis sed velit nunc curabitur. Ultrices '
    'ullamcorper nisi sed dignissim amet facilisis viverra tempor in. Mollis '
    'facilisi euismod sed ligula euismod duis commodo suspendisse. Commodo '
    'tellus convallis ac quis.Lorem ipsum dolor sit amet consectetur. Ut '
    'scelerisque aliquet nisl facilisi molestie porttitor risus eget. Erat '
    'mattis gravida quis consequat. Leo';

enum TermsNextDestination { profile, home }

class TermsPage extends ConsumerWidget {
  const TermsPage({
    super.key,
    this.nextDestination = TermsNextDestination.profile,
  });

  final TermsNextDestination nextDestination;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutePaths.profileSetup);
  }

  void _confirmAgreement(BuildContext context, WidgetRef ref) {
    ref.read(profileSetupStateProvider.notifier).setPrivacyTermsAccepted(true);

    switch (nextDestination) {
      case TermsNextDestination.profile:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutePaths.profileSetup);
        }
      case TermsNextDestination.home:
        context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAccepted = ref.watch(
      profileSetupStateProvider.select((state) => state.isPrivacyTermsAccepted),
    );

    return Scaffold(
      backgroundColor: AppColors.textHeadline,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final verticalScale = math.min(
            1.0,
            constraints.maxHeight / _figmaFrameHeight,
          );
          final contentWidth = math.min(
            _figmaFrameWidth - (AppSpacing.x20 * 2),
            math.max(0.0, constraints.maxWidth - (AppSpacing.x20 * 2)),
          );
          final horizontalInset = math.max(
            AppSpacing.x20,
            (constraints.maxWidth - contentWidth) / 2,
          );

          return Stack(
            children: [
              Positioned(
                top: _sheetRearTop * verticalScale,
                left: AppSpacing.x16,
                right: AppSpacing.x16,
                height: AppSpacing.x10,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                key: const ValueKey('privacyTermsSheet'),
                top: _sheetTop * verticalScale,
                left: 0,
                right: 0,
                bottom: 0,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _headerTop * verticalScale,
                left: 0,
                right: 0,
                height: AppSizes.navigationBarHeight,
                child: _TermsHeader(onBackPressed: () => _goBack(context)),
              ),
              Positioned(
                key: const ValueKey('privacyTermsBody'),
                top: _bodyTop * verticalScale,
                left: horizontalInset + AppSpacing.x10,
                right: horizontalInset + AppSpacing.x10,
                bottom: math.max(
                  0.0,
                  constraints.maxHeight - (_bottomActionsTop * verticalScale),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Text(
                    _privacyTermsBody,
                    style: AppTextStyles.size16Medium.copyWith(
                      color: AppColors.textHeadline,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _bottomActionsTop * verticalScale,
                left: 0,
                right: 0,
                bottom: 0,
                child: ColoredBox(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      _TermsConsentRow(
                        isAccepted: isAccepted,
                        onTap: () => ref
                            .read(profileSetupStateProvider.notifier)
                            .togglePrivacyTermsAccepted(),
                      ),
                      const SizedBox(height: AppSpacing.x16),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalInset,
                        ),
                        child: CommonButton(
                          key: const ValueKey('privacyTermsConfirmButton'),
                          label: '확인',
                          backgroundColor: AppColors.brandAccent,
                          foregroundColor: AppColors.white,
                          onPressed: () => _confirmAgreement(context, ref),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TermsHeader extends StatelessWidget {
  const _TermsHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: AppSizes.navigationBarSideWidth,
          height: AppSizes.navigationBarHeight,
          child: IconButton(
            key: const ValueKey('privacyTermsBackButton'),
            tooltip: '뒤로가기',
            onPressed: onBackPressed,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppSizes.navigationBackIconSize,
              color: AppColors.textStrong,
            ),
          ),
        ),
        Center(
          child: Text(
            '개인정보 이용약관',
            key: const ValueKey('privacyTermsTitle'),
            style: AppTextStyles.size18Medium.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsConsentRow extends StatelessWidget {
  const _TermsConsentRow({required this.isAccepted, required this.onTap});

  final bool isAccepted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      label: isAccepted ? '동의합니다 선택됨' : '동의합니다 선택 안 됨',
      child: GestureDetector(
        key: const ValueKey('privacyTermsCheckRow'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: _termsCheckRowHeight,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x20,
                AppSpacing.x32,
                AppSpacing.x20,
                AppSpacing.x16,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.iconMedium,
                    height: AppSizes.iconMedium,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAccepted
                          ? AppColors.brandAccent
                          : AppColors.textDisabled,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: AppSizes.iconSmall,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x12),
                  Text(
                    '동의합니다',
                    style: AppTextStyles.size16Medium.copyWith(
                      color: AppColors.textHeadline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
