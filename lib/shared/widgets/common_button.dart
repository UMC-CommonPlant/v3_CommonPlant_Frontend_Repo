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

  double get _height {
    switch (size) {
      case CommonButtonSize.large:
        return AppSizes.buttonHeight;
      case CommonButtonSize.medium:
        return AppSizes.mediumButtonHeight;
      case CommonButtonSize.small:
        return AppSizes.smallButtonHeight;
    }
  }

  double get _radius {
    switch (size) {
      case CommonButtonSize.large:
      case CommonButtonSize.small:
        return AppRadius.small;
      case CommonButtonSize.medium:
        return AppRadius.xSmall;
    }
  }

  double? get _defaultWidth {
    switch (size) {
      case CommonButtonSize.small:
        return AppSizes.smallButtonWidth;
      case CommonButtonSize.medium:
      case CommonButtonSize.large:
        return null;
    }
  }

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

  TextStyle _buttonTextStyle(AppThemeTokens tokens) {
    final baseStyle = switch (size) {
      CommonButtonSize.large => AppTextStyles.size16Medium,
      CommonButtonSize.medium => AppTextStyles.size14Medium,
      CommonButtonSize.small => AppTextStyles.size14Medium,
    };

    final effectiveForegroundColor =
        foregroundColor ??
        switch (variant) {
          CommonButtonVariant.primary || CommonButtonVariant.dark =>
            _effectiveOnPressed == null ? tokens.textDisabled : tokens.onBrand,
          CommonButtonVariant.secondary || CommonButtonVariant.text =>
            _effectiveOnPressed == null
                ? tokens.textDisabled
                : tokens.brandAccent,
          CommonButtonVariant.neutral =>
            _effectiveOnPressed == null
                ? tokens.textDisabled
                : tokens.textStrong,
        };

    return baseStyle.copyWith(color: effectiveForegroundColor);
  }

  Color _backgroundColor(AppThemeTokens tokens) {
    if (_effectiveOnPressed == null) {
      return backgroundColor ?? tokens.surfaceDisabled;
    }

    return backgroundColor ??
        switch (variant) {
          CommonButtonVariant.primary => tokens.brandStrong,
          CommonButtonVariant.secondary => tokens.surfaceBase,
          CommonButtonVariant.dark => tokens.textStrong,
          CommonButtonVariant.neutral => tokens.surfaceDisabled,
          CommonButtonVariant.text => Colors.transparent,
        };
  }

  Color _borderColor(AppThemeTokens tokens) {
    return borderColor ?? Colors.transparent;
  }

  BorderSide get _borderSide {
    if (borderColor == null) {
      return BorderSide.none;
    }

    return const BorderSide(width: 1);
  }

  Widget _wrapWidth(Widget child) {
    return SizedBox(
      width: fullWidth || (size == CommonButtonSize.large && width == null)
          ? double.infinity
          : width ?? _defaultWidth,
      height: _height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: _borderSide.copyWith(color: _borderColor(tokens)),
    );
    final textStyle = _buttonTextStyle(tokens);

    switch (variant) {
      case CommonButtonVariant.primary:
        return _wrapWidth(
          FilledButton(
            onPressed: _effectiveOnPressed,
            style: FilledButton.styleFrom(
              backgroundColor: _backgroundColor(tokens),
              foregroundColor: textStyle.color,
              minimumSize: Size(0, _height),
              maximumSize: Size(double.infinity, _height),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: buttonShape,
              textStyle: textStyle,
            ),
            child: _buildChild(textStyle),
          ),
        );
      case CommonButtonVariant.secondary:
        return _wrapWidth(
          OutlinedButton(
            onPressed: _effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: _backgroundColor(tokens),
              foregroundColor: textStyle.color,
              minimumSize: Size(0, _height),
              maximumSize: Size(double.infinity, _height),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: _borderSide.copyWith(color: _borderColor(tokens)),
              shape: buttonShape,
              textStyle: textStyle,
            ),
            child: _buildChild(textStyle),
          ),
        );
      case CommonButtonVariant.dark:
        return _wrapWidth(
          FilledButton(
            onPressed: _effectiveOnPressed,
            style: FilledButton.styleFrom(
              backgroundColor: _backgroundColor(tokens),
              foregroundColor: textStyle.color,
              minimumSize: Size(0, _height),
              maximumSize: Size(double.infinity, _height),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
              shape: buttonShape,
              textStyle: textStyle,
            ),
            child: _buildChild(textStyle),
          ),
        );
      case CommonButtonVariant.neutral:
        return _wrapWidth(
          FilledButton(
            onPressed: _effectiveOnPressed,
            style: FilledButton.styleFrom(
              backgroundColor: _backgroundColor(tokens),
              foregroundColor: textStyle.color,
              minimumSize: Size(0, _height),
              maximumSize: Size(double.infinity, _height),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
              shape: buttonShape,
              textStyle: textStyle,
            ),
            child: _buildChild(textStyle),
          ),
        );
      case CommonButtonVariant.text:
        return _wrapWidth(
          TextButton(
            onPressed: _effectiveOnPressed,
            style: TextButton.styleFrom(
              backgroundColor: _backgroundColor(tokens),
              foregroundColor: textStyle.color,
              minimumSize: Size(0, _height),
              maximumSize: Size(double.infinity, _height),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: buttonShape,
              textStyle: textStyle,
            ),
            child: _buildChild(textStyle),
          ),
        );
    }
  }
}
