import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

enum CommonButtonVariant { primary, secondary, dark, neutral, text }

enum CommonButtonSize { large, medium, small }

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CommonButtonVariant.primary,
    this.size = CommonButtonSize.large,
    this.fullWidth = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.leading,
    this.trailing,
    this.isLoading = false,
  });

  const CommonButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = CommonButtonSize.large,
    this.fullWidth = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.leading,
    this.trailing,
    this.isLoading = false,
  }) : variant = CommonButtonVariant.secondary;

  const CommonButton.neutral({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = CommonButtonSize.large,
    this.fullWidth = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.leading,
    this.trailing,
    this.isLoading = false,
  }) : variant = CommonButtonVariant.neutral;

  const CommonButton.dark({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = CommonButtonSize.large,
    this.fullWidth = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.leading,
    this.trailing,
    this.isLoading = false,
  }) : variant = CommonButtonVariant.dark;

  const CommonButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = CommonButtonSize.large,
    this.fullWidth = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.leading,
    this.trailing,
    this.isLoading = false,
  }) : variant = CommonButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final CommonButtonVariant variant;
  final CommonButtonSize size;
  final bool fullWidth;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;

  VoidCallback? get _effectiveOnPressed => isLoading ? null : onPressed;

  Widget _buildChild(TextStyle textStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox.square(
            dimension: AppSizes.iconSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textStyle.color ?? AppThemeTokens.light.textDisabled,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x8),
        ],
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.x8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.x8),
          trailing!,
        ],
      ],
    );
  }

  Widget _wrapWidth(_CommonButtonMetrics metrics, Widget child) {
    return SizedBox(
      width: fullWidth || (size == CommonButtonSize.large && width == null)
          ? double.infinity
          : width ?? metrics.defaultWidth,
      height: metrics.height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;
    final metrics = _CommonButtonMetrics.resolve(size, variant);
    final buttonStyle = _CommonButtonStyle.resolve(
      tokens: tokens,
      variant: variant,
      size: size,
      enabled: _effectiveOnPressed != null,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
    );

    switch (variant) {
      case CommonButtonVariant.primary:
        return _wrapWidth(
          metrics,
          FilledButton(
            onPressed: _effectiveOnPressed,
            style: buttonStyle.filledButtonStyle(metrics),
            child: _buildChild(buttonStyle.textStyle),
          ),
        );
      case CommonButtonVariant.secondary:
        return _wrapWidth(
          metrics,
          OutlinedButton(
            onPressed: _effectiveOnPressed,
            style: buttonStyle.outlinedButtonStyle(metrics),
            child: _buildChild(buttonStyle.textStyle),
          ),
        );
      case CommonButtonVariant.dark:
        return _wrapWidth(
          metrics,
          FilledButton(
            onPressed: _effectiveOnPressed,
            style: buttonStyle.filledButtonStyle(metrics, elevation: 0),
            child: _buildChild(buttonStyle.textStyle),
          ),
        );
      case CommonButtonVariant.neutral:
        return _wrapWidth(
          metrics,
          FilledButton(
            onPressed: _effectiveOnPressed,
            style: buttonStyle.filledButtonStyle(metrics, elevation: 0),
            child: _buildChild(buttonStyle.textStyle),
          ),
        );
      case CommonButtonVariant.text:
        return _wrapWidth(
          metrics,
          TextButton(
            onPressed: _effectiveOnPressed,
            style: buttonStyle.textButtonStyle(metrics),
            child: _buildChild(buttonStyle.textStyle),
          ),
        );
    }
  }
}

class _CommonButtonMetrics {
  const _CommonButtonMetrics({
    required this.height,
    required this.radius,
    required this.padding,
    required this.baseTextStyle,
    this.defaultWidth,
  });

  final double height;
  final double radius;
  final EdgeInsetsGeometry padding;
  final TextStyle baseTextStyle;
  final double? defaultWidth;

  static _CommonButtonMetrics resolve(
    CommonButtonSize size,
    CommonButtonVariant variant,
  ) {
    return _CommonButtonMetrics(
      height: switch (size) {
        CommonButtonSize.large => AppSizes.buttonHeight,
        CommonButtonSize.medium => AppSizes.mediumButtonHeight,
        CommonButtonSize.small => AppSizes.smallButtonHeight,
      },
      radius: switch (size) {
        CommonButtonSize.large || CommonButtonSize.small => AppRadius.small,
        CommonButtonSize.medium => AppRadius.xSmall,
      },
      padding: EdgeInsets.symmetric(
        horizontal: variant == CommonButtonVariant.text
            ? AppSpacing.x12
            : AppSpacing.x20,
      ),
      baseTextStyle: switch (size) {
        CommonButtonSize.large => AppTextStyles.size16Medium,
        CommonButtonSize.medium => AppTextStyles.size14Medium,
        CommonButtonSize.small => AppTextStyles.size14Medium,
      },
      defaultWidth: switch (size) {
        CommonButtonSize.small => AppSizes.smallButtonWidth,
        CommonButtonSize.medium || CommonButtonSize.large => null,
      },
    );
  }
}

class _CommonButtonStyle {
  const _CommonButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderSide,
    required this.textStyle,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide borderSide;
  final TextStyle textStyle;

  static _CommonButtonStyle resolve({
    required AppThemeTokens tokens,
    required CommonButtonVariant variant,
    required CommonButtonSize size,
    required bool enabled,
    required Color? backgroundColor,
    required Color? foregroundColor,
    required Color? borderColor,
  }) {
    final metrics = _CommonButtonMetrics.resolve(size, variant);
    final resolvedForegroundColor =
        foregroundColor ??
        switch (variant) {
          CommonButtonVariant.primary || CommonButtonVariant.dark =>
            enabled ? tokens.onBrand : tokens.textDisabled,
          CommonButtonVariant.secondary || CommonButtonVariant.text =>
            enabled ? tokens.brandAccent : tokens.textDisabled,
          CommonButtonVariant.neutral =>
            enabled ? tokens.textStrong : tokens.textDisabled,
        };

    return _CommonButtonStyle(
      backgroundColor:
          backgroundColor ?? _resolveBackgroundColor(tokens, variant, enabled),
      foregroundColor: resolvedForegroundColor,
      borderSide: borderColor == null
          ? BorderSide.none
          : BorderSide(width: 1, color: borderColor),
      textStyle: metrics.baseTextStyle.copyWith(color: resolvedForegroundColor),
    );
  }

  static Color _resolveBackgroundColor(
    AppThemeTokens tokens,
    CommonButtonVariant variant,
    bool enabled,
  ) {
    if (!enabled) {
      return tokens.surfaceDisabled;
    }

    return switch (variant) {
      CommonButtonVariant.primary => tokens.brandStrong,
      CommonButtonVariant.secondary => tokens.surfaceBase,
      CommonButtonVariant.dark => tokens.textStrong,
      CommonButtonVariant.neutral => tokens.surfaceDisabled,
      CommonButtonVariant.text => Colors.transparent,
    };
  }

  RoundedRectangleBorder shape(_CommonButtonMetrics metrics) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(metrics.radius),
      side: borderSide,
    );
  }

  ButtonStyle filledButtonStyle(
    _CommonButtonMetrics metrics, {
    double? elevation,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(0, metrics.height),
      maximumSize: Size(double.infinity, metrics.height),
      padding: metrics.padding,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: elevation,
      shape: shape(metrics),
      textStyle: textStyle,
    );
  }

  ButtonStyle outlinedButtonStyle(_CommonButtonMetrics metrics) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(0, metrics.height),
      maximumSize: Size(double.infinity, metrics.height),
      padding: metrics.padding,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: borderSide,
      shape: shape(metrics),
      textStyle: textStyle,
    );
  }

  ButtonStyle textButtonStyle(_CommonButtonMetrics metrics) {
    return TextButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(0, metrics.height),
      maximumSize: Size(double.infinity, metrics.height),
      padding: metrics.padding,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: shape(metrics),
      textStyle: textStyle,
    );
  }
}
