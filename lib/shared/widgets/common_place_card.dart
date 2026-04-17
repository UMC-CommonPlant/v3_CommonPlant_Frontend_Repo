import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonPlaceCard extends StatelessWidget {
  const CommonPlaceCard({
    super.key,
    required this.title,
    this.imageProvider,
    this.onTap,
    this.width,
    this.height = AppSizes.placeCardHeight,
    this.placeholder,
  });

  final String title;
  final ImageProvider<Object>? imageProvider;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;
    final effectiveWidth = width ?? AppSizes.placeCardWidth;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: SizedBox(
        width: effectiveWidth,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.surfaceMuted,
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider!, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? placeholder ??
                        ColoredBox(
                          color: AppColors.surfaceAlt,
                          child: Center(
                            child: CommonSvgIcon(
                              AppIconAssets.placeEmpty,
                              width: 48,
                              height: 133,
                              semanticsLabel: '장소 기본 이미지',
                            ),
                          ),
                        )
                  : null,
            ),
            const Opacity(
              opacity: 0.6,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.heroOverlay),
              ),
            ),
            Positioned(
              left: AppSpacing.x16,
              right: AppSpacing.x16,
              bottom: AppSpacing.x16,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size16Medium.copyWith(
                  color: tokens.onBrand,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: card,
    );
  }
}
