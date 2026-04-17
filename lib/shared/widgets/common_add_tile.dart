import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

enum CommonAddTileVariant { place, plantDisabled, outline }

class CommonAddTile extends StatelessWidget {
  const CommonAddTile({
    super.key,
    required this.label,
    this.onTap,
    this.height,
    this.width,
    this.icon,
    this.helper,
    this.enabled = true,
    this.variant = CommonAddTileVariant.outline,
  });

  final String label;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Widget? icon;
  final String? helper;
  final bool enabled;
  final CommonAddTileVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    final effectiveVariant = enabled
        ? variant
        : CommonAddTileVariant.plantDisabled;
    final effectiveHeight = height ?? _defaultHeight(effectiveVariant);
    final borderRadius = BorderRadius.circular(AppRadius.small);
    final iconWidget = switch (effectiveVariant) {
      CommonAddTileVariant.place => const CommonSvgIcon(
        AppIconAssets.plusGreen,
        width: 24,
        height: 24,
        semanticsLabel: '장소 추가',
      ),
      CommonAddTileVariant.plantDisabled => const CommonSvgIcon(
        AppIconAssets.plusGray,
        width: 24,
        height: 24,
        semanticsLabel: '식물 추가',
      ),
      CommonAddTileVariant.outline => icon,
    };

    final content = switch (effectiveVariant) {
      CommonAddTileVariant.place => Container(
        width: width ?? AppSizes.placeAddTileWidth,
        height: effectiveHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius,
          border: Border.all(color: tokens.brandAccent, width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget!,
              const SizedBox(width: AppSpacing.x10),
              Text(
                label,
                style: AppTextStyles.size14Medium.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      CommonAddTileVariant.plantDisabled => Container(
        width: width ?? AppSizes.plantAddTileWidth,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: tokens.surfaceBase,
          borderRadius: borderRadius,
          border: Border.all(color: tokens.borderDefault, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget!,
            const SizedBox(height: AppSpacing.x4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
      CommonAddTileVariant.outline => Container(
        width: width,
        height: effectiveHeight,
        padding: const EdgeInsets.all(AppSpacing.x20),
        decoration: BoxDecoration(
          color: tokens.surfaceBase,
          borderRadius: borderRadius,
          border: Border.all(
            color: enabled ? tokens.brandAccent : tokens.borderDefault,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: AppSpacing.x12),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.size16Medium.copyWith(
                color: enabled ? tokens.brandPrimary : tokens.textDisabled,
              ),
            ),
            if (helper != null) ...[
              const SizedBox(height: AppSpacing.x8),
              Text(
                helper!,
                textAlign: TextAlign.center,
                style: AppTextStyles.size12Medium.copyWith(
                  color: tokens.textBody,
                ),
              ),
            ],
          ],
        ),
      ),
    };

    if (onTap == null || !enabled) {
      return content;
    }

    return InkWell(onTap: onTap, borderRadius: borderRadius, child: content);
  }

  double _defaultHeight(CommonAddTileVariant effectiveVariant) {
    return switch (effectiveVariant) {
      CommonAddTileVariant.place => AppSizes.placeAddTileHeight,
      CommonAddTileVariant.plantDisabled => AppSizes.plantAddTileHeight,
      CommonAddTileVariant.outline => 180,
    };
  }
}
