import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return CommonScaffold(
      title: '온보딩',
      showNavigationBar: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x40,
        AppSpacing.x20,
        AppSpacing.x24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CommonSvgIcon(
                AppIconAssets.logoWordmarkCommon,
                height: 28,
                semanticsLabel: 'Common',
              ),
              SizedBox(width: AppSpacing.x8),
              CommonSvgIcon(
                AppIconAssets.logoWordmarkPlant,
                height: 28,
                semanticsLabel: 'Plant',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x40),
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.brandSoft,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.x32),
              child: CommonSvgIcon(
                AppIconAssets.userIllustration,
                height: 220,
                semanticsLabel: '커먼플랜트 시작 이미지',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x40),
          Text(
            '함께 돌보는 식물 생활',
            textAlign: TextAlign.center,
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
          const SizedBox(height: AppSpacing.x12),
          Text(
            '장소를 만들고 친구와 식물을 초대해\n물주기와 메모를 함께 관리해요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: AppSpacing.x40),
          CommonButton(
            label: '시작하기',
            onPressed: () => context.go(AppRoutePaths.profileSetup),
          ),
          const SizedBox(height: AppSpacing.x12),
          CommonButton.text(
            label: '둘러보기',
            onPressed: () => context.go(AppRoutePaths.home),
          ),
        ],
      ),
    );
  }
}
