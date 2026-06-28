import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.topInset,
    required this.contentHeight,
    super.key,
  });

  final double topInset;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AppColors.surfaceAlt)),
        Positioned(
          left: 0,
          right: 0,
          top: topInset,
          height: contentHeight,
          child: CommonSvgIcon(
            AppImageAssets.homeMainHeroBackground,
            fit: BoxFit.fill,
            semanticsLabel: '메인 배경',
          ),
        ),
        Positioned(
          left: AppSpacing.x20,
          top: topInset + 48,
          child: Text(
            '커먼(유저 네임',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColorPrimitives.unspecifiedGreenGray,
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.x20,
          top: topInset + 76,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 44,
                child: Container(
                  width: 70,
                  height: 10,
                  color: AppColorPrimitives.unspecifiedGreenGray.withValues(
                    alpha: 0.16,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.size20Medium.copyWith(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(text: '님과 함께 친환경 한 걸음을\n'),
                    TextSpan(
                      text: '한걸음에',
                      style: TextStyle(color: AppColors.brandStrong),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 23,
          top: topInset + 110,
          width: 88,
          height: 64,
          child: const CommonSvgIcon(
            AppIconAssets.userIllustration,
            fit: BoxFit.fill,
            semanticsLabel: '유저 일러스트',
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: topInset + 161,
          height: 27,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD8DEDD).withValues(alpha: 0.6),
                  const Color(0x00D8DEDD),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
