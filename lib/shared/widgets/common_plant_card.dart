import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonPlantCard extends StatelessWidget {
  const CommonPlantCard({
    super.key,
    this.imageProvider,
    this.onTap,
    this.width = AppSizes.plantCardWidth,
    this.height = AppSizes.plantCardHeight,
    this.placeholder,
  });

  final ImageProvider<Object>? imageProvider;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: SizedBox(
        width: width,
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
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSizes.plantCardFadeBottom,
              height: AppSizes.plantCardFadeHeight,
              child: const Opacity(
                opacity: 0.6,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.softFade),
                ),
              ),
            ),
            if (imageProvider == null)
              Center(
                child:
                    placeholder ??
                    const CommonSvgIcon(
                      AppIconAssets.plantEmpty,
                      height: AppSizes.plantEmptyIconHeight,
                      semanticsLabel: '식물 기본 이미지',
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

class CommonPlacePlantCard extends StatelessWidget {
  const CommonPlacePlantCard({
    super.key,
    required this.name,
    required this.species,
    required this.description,
    this.imageProvider,
    this.action,
    this.dDayLabel,
    this.dateLabel,
    this.trailing,
    this.onTap,
    this.placeholder,
    this.width = AppSizes.placePlantCardWidth,
    this.height = AppSizes.placePlantCardHeight,
  });

  final String name;
  final String species;
  final String description;
  final ImageProvider<Object>? imageProvider;
  final Widget? action;
  final String? dDayLabel;
  final String? dateLabel;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? placeholder;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBody.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.placePlantCardPadding),
          child: Row(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: SizedBox(
                    width: AppSizes.placePlantCardImageWidth,
                    height: AppSizes.placePlantCardImageHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.surfaceMuted,
                        image: imageProvider != null
                            ? DecorationImage(
                                image: imageProvider!,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageProvider == null
                          ? placeholder ??
                                ColoredBox(
                                  color: tokens.surfaceAlt,
                                  child: Center(
                                    child: CommonSvgIcon(
                                      AppIconAssets.plantEmpty,
                                      height: AppSizes.plantEmptyIconHeight,
                                      semanticsLabel: '식물 기본 이미지',
                                    ),
                                  ),
                                )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.size16Bold.copyWith(
                            color: AppColors.textBody,
                          ),
                        ),
                        Text(
                          species,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.size12Medium.copyWith(
                            color: AppColors.textBody,
                          ),
                        ),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.size12Medium.copyWith(
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (action != null) ...[
                          action!,
                          const SizedBox(width: AppSpacing.x8),
                        ],
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child:
                                trailing ??
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (dDayLabel != null)
                                      Text(
                                        dDayLabel!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.size16Medium
                                            .copyWith(
                                              color: AppColors.brandPrimary,
                                            ),
                                      ),
                                    if (dateLabel != null)
                                      Text(
                                        dateLabel!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.size12Medium
                                            .copyWith(
                                              color: AppColors.textBody,
                                            ),
                                      ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: content,
    );
  }
}
