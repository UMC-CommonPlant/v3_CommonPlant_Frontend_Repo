import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonWateringButton extends StatelessWidget {
  const CommonWateringButton({
    super.key,
    this.onPressed,
    this.width = AppSizes.wateringButtonWidth,
    this.height = AppSizes.wateringButtonHeight,
  });

  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: onPressed == null
              ? tokens.surfaceDisabled
              : tokens.brandStrong,
          foregroundColor: tokens.onBrand,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const CommonSvgIcon(
          AppIconAssets.watering,
          width: 32,
          height: 25,
          semanticsLabel: '물주기',
        ),
      ),
    );
  }
}
