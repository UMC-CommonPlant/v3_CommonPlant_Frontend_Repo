import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Pretendard';

  static const TextStyle size24Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 32 / 24,
    letterSpacing: 0,
    color: AppColors.textHeadline,
  );

  static const TextStyle size20Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 24 / 20,
    letterSpacing: 0,
    color: AppColors.textHeadline,
  );

  static const TextStyle size18Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    letterSpacing: 0,
    color: AppColors.textHeadline,
  );

  static const TextStyle size16Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 22 / 16,
    letterSpacing: 0,
    color: AppColors.textHeadline,
  );

  static const TextStyle size16Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    letterSpacing: 0,
    color: AppColors.textBody,
  );

  static const TextStyle size14Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.textHeadline,
  );

  static const TextStyle size14Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.textBody,
  );

  static const TextStyle size12Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0,
    color: AppColors.textBody,
  );

  static const TextStyle headline = size24Medium;
  static const TextStyle sectionTitle = size20Medium;
  static const TextStyle title = size18Medium;
  static const TextStyle body = size16Medium;
  static const TextStyle bodyCompact = size12Medium;
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    letterSpacing: 0,
    color: AppColors.onBrand,
  );
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    letterSpacing: 0,
    color: AppColors.brandPrimary,
  );

  static TextTheme buildTextTheme() {
    return const TextTheme(
      headlineMedium: headline,
      titleLarge: sectionTitle,
      titleMedium: title,
      bodyLarge: body,
      bodyMedium: size14Medium,
      labelLarge: button,
      labelMedium: buttonSecondary,
    );
  }
}
