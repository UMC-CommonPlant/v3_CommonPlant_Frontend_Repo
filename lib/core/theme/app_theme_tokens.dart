import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.brandAccent,
    required this.brandPrimary,
    required this.brandStrong,
    required this.brandSoft,
    required this.canvas,
    required this.surfaceBase,
    required this.surfaceMuted,
    required this.surfaceAlt,
    required this.surfaceDisabled,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderMuted,
    required this.separator,
    required this.iconInactive,
    required this.textHeadline,
    required this.textStrong,
    required this.textBody,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.danger,
    required this.onBrand,
  });

  static const light = AppThemeTokens(
    brandAccent: AppColors.brandAccent,
    brandPrimary: AppColors.brandPrimary,
    brandStrong: AppColors.brandStrong,
    brandSoft: AppColors.brandSoft,
    canvas: AppColors.canvas,
    surfaceBase: AppColors.surfaceBase,
    surfaceMuted: AppColors.surfaceMuted,
    surfaceAlt: AppColors.surfaceAlt,
    surfaceDisabled: AppColors.surfaceDisabled,
    borderDefault: AppColors.borderDefault,
    borderSubtle: AppColors.borderSubtle,
    borderMuted: AppColors.borderMuted,
    separator: AppColors.separator,
    iconInactive: AppColors.iconInactive,
    textHeadline: AppColors.textHeadline,
    textStrong: AppColors.textStrong,
    textBody: AppColors.textBody,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textDisabled: AppColors.textDisabled,
    danger: AppColors.danger,
    onBrand: AppColors.onBrand,
  );

  final Color brandAccent;
  final Color brandPrimary;
  final Color brandStrong;
  final Color brandSoft;
  final Color canvas;
  final Color surfaceBase;
  final Color surfaceMuted;
  final Color surfaceAlt;
  final Color surfaceDisabled;
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderMuted;
  final Color separator;
  final Color iconInactive;
  final Color textHeadline;
  final Color textStrong;
  final Color textBody;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color danger;
  final Color onBrand;

  @override
  AppThemeTokens copyWith({
    Color? brandAccent,
    Color? brandPrimary,
    Color? brandStrong,
    Color? brandSoft,
    Color? canvas,
    Color? surfaceBase,
    Color? surfaceMuted,
    Color? surfaceAlt,
    Color? surfaceDisabled,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderMuted,
    Color? separator,
    Color? iconInactive,
    Color? textHeadline,
    Color? textStrong,
    Color? textBody,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? danger,
    Color? onBrand,
  }) {
    return AppThemeTokens(
      brandAccent: brandAccent ?? this.brandAccent,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandStrong: brandStrong ?? this.brandStrong,
      brandSoft: brandSoft ?? this.brandSoft,
      canvas: canvas ?? this.canvas,
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderMuted: borderMuted ?? this.borderMuted,
      separator: separator ?? this.separator,
      iconInactive: iconInactive ?? this.iconInactive,
      textHeadline: textHeadline ?? this.textHeadline,
      textStrong: textStrong ?? this.textStrong,
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      danger: danger ?? this.danger,
      onBrand: onBrand ?? this.onBrand,
    );
  }

  @override
  AppThemeTokens lerp(covariant AppThemeTokens? other, double t) {
    if (other == null) {
      return this;
    }

    return AppThemeTokens(
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceDisabled: Color.lerp(surfaceDisabled, other.surfaceDisabled, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderMuted: Color.lerp(borderMuted, other.borderMuted, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      iconInactive: Color.lerp(iconInactive, other.iconInactive, t)!,
      textHeadline: Color.lerp(textHeadline, other.textHeadline, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
    );
  }
}
