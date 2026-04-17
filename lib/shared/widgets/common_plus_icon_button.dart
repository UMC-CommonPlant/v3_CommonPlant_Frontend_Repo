import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_plus_mark.dart';
import 'package:flutter/material.dart';

class CommonPlusIconButton extends StatelessWidget {
  const CommonPlusIconButton({
    super.key,
    this.onPressed,
    this.size = AppSizes.iconButtonSize,
    this.iconSize = AppSizes.iconButtonGlyphSize,
  });

  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tokens.brandAccent,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      alignment: Alignment.center,
      child: CommonPlusMark(
        size: iconSize,
        thickness: 3.25,
        color: tokens.onBrand,
      ),
    );

    if (onPressed == null) {
      return button;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: button,
      ),
    );
  }
}
