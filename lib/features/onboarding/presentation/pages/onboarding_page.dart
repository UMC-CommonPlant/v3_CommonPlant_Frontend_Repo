import 'dart:math' as math;

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _figmaFrameWidth = 375;
const double _figmaFrameHeight = 812;
const double _topSurfaceHeight = 334.71;
const double _heroTop = 174.52;
const double _heroWidth = 223.698;
const double _heroHeight = 253.251;
const double _titleTop = 463.3;
const double _buttonBottom = 42;

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key, this.redirect});

  final String? redirect;

  Future<void> _handleStart(BuildContext context, WidgetRef ref) async {
    final didComplete = await ref
        .read(onboardingControllerProvider.notifier)
        .complete();
    if (!context.mounted) {
      return;
    }
    if (!didComplete) {
      showCommonSnackBar(context, onboardingSaveFailureMessage);
      return;
    }

    context.go(AppRoutePaths.loginLocation(redirect: redirect));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionState = ref.watch(onboardingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
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
          final heroWidth = _heroWidth * verticalScale;
          final heroHeight = _heroHeight * verticalScale;
          final buttonBottom = math.max(
            MediaQuery.viewPaddingOf(context).bottom + AppSpacing.x8,
            _buttonBottom * verticalScale,
          );

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _topSurfaceHeight * verticalScale,
                child: const ColoredBox(color: AppColors.surfaceAlt),
              ),
              Positioned(
                top: _heroTop * verticalScale,
                left: (constraints.maxWidth - heroWidth) / 2,
                width: heroWidth,
                height: heroHeight,
                child: const CommonSvgIcon(
                  AppImageAssets.onboardingHeroIllustration,
                  fit: BoxFit.fill,
                  semanticsLabel: '온보딩 일러스트',
                ),
              ),
              Positioned(
                top: _titleTop * verticalScale,
                left: horizontalInset,
                width: contentWidth,
                child: Text(
                  '식물을 내 공간으로,\n공간은 내 폰으로',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size24Medium.copyWith(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: horizontalInset,
                right: horizontalInset,
                bottom: buttonBottom,
                child: CommonButton(
                  key: const ValueKey('onboardingStartButton'),
                  label: '시작하기',
                  isLoading: completionState.isLoading,
                  onPressed: () => _handleStart(context, ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
