import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brandPrimary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.brandPrimary,
          onPrimary: AppColors.onBrand,
          secondary: AppColors.brandAccent,
          onSecondary: AppColors.onBrand,
          error: AppColors.danger,
          onError: AppColors.onBrand,
          surface: AppColors.surfaceBase,
          onSurface: AppColors.textPrimary,
          outline: AppColors.borderDefault,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: AppTextStyles.buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textHeadline,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.sectionTitle,
      ),
      extensions: const <ThemeExtension<dynamic>>[AppThemeTokens.light],
    );
  }
}
