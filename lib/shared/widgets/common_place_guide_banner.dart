import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonPlaceGuideBanner extends StatelessWidget {
  const CommonPlaceGuideBanner({super.key, required this.label, this.leading});

  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return SizedBox(
      height: AppSizes.placeGuideHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.brandStrong,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x10,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                child:
                    leading ??
                    CommonSvgIcon(
                      AppIconAssets.addPlace,
                      height: 20,
                      color: tokens.onBrand,
                      semanticsLabel: '장소 안내',
                    ),
              ),
              const SizedBox(width: AppSpacing.x8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.size14Medium.copyWith(
                    color: tokens.onBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
