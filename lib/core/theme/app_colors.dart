import 'package:flutter/material.dart';

abstract final class AppColorPrimitives {
  const AppColorPrimitives._();

  static const seaGreenDark1 = Color(0xFF00C596); // Sea Green/Dark1
  static const seaGreenDark2 = Color(0xFF00B187); // Sea Green/Dark2
  static const seaGreenDark3 = Color(0xFF009773); // Sea Green/Dark3
  static const seaGreenBg = Color(0xFFEEF8F5); // Sea Green/BG

  static const grayBlackTextHeadline = Color(
    0xFF000000,
  ); // Gray/Black_text (Headline)
  static const grayGray1 = Color(0xFFF4F4F4); // Gray/Gray 1
  static const grayGray2 = Color(0xFFE0E0E0); // Gray/Gray 2
  static const grayGray3 = Color(0xFFC8C8C8); // Gray/Gray 3
  static const grayGray4 = Color(0xFF999999); // Gray/Gray 4
  static const grayGray5 = Color(0xFF787878); // Gray/Gray 5
  static const grayGray6 = Color(0xFF404040); // Gray/Gray 6
  static const grayWhite = Color(0xFFFFFFFF); // Gray/White

  static const separatorColors = Color(0xFF3C3C43); // Separator Colors
  static const lightSeparator = Color(0xFFE5E5EA); // Light/Separator
  static const lightLabelPrimary = Color(0xFF000000); // Light/Label/Primary
  static const lightLabelSecondary = Color(
    0x993C3C43,
  ); // Light/Label/Secondary 60%
  static const lightLabelTertiary = Color(
    0x4D3C3C43,
  ); // Light/Label/Teriary 30%
  static const lightSystemBlue = Color(0xFF007AFF); // Light/System/Blue
  static const lightAlertBackground = Color(
    0xFFF2F2F2,
  ); // Light/Background/Alert

  static const primaryElectricCrimson = Color(
    0xFFE91237,
  ); // Primary/Electric Crimson
  static const unspecifiedGreenGray = Color(0xFF4D5F5A); // 미지정
  static const unspecifiedGuestLogin = Color(0xFF747474); // 미지정(게스트로그인)
  static const unspecifiedBackground = Color(0xFFEDEDED); // 미지정(배경색)
  static const unspecifiedBackgroundAlt = Color(0xFFF3F6F6); // 미지정(배경색)
  static const unspecifiedNearBlack = Color(0xFF101010); // 미지정
  static const unspecifiedBorder = Color(0xFFD9D9D9); // 미지정
  static const kakaoYellow = Color(0xFFFEE500); // Kakao/Yellow
}

abstract final class AppColors {
  const AppColors._();

  static const brandAccent = AppColorPrimitives.seaGreenDark1;
  static const brandPrimary = AppColorPrimitives.seaGreenDark2;
  static const brandStrong = AppColorPrimitives.seaGreenDark3;
  static const brandSoft = AppColorPrimitives.seaGreenBg;

  static const canvas = AppColorPrimitives.grayWhite;
  static const surfaceBase = AppColorPrimitives.grayWhite;
  static const surfaceDisabled = AppColorPrimitives.grayGray1;
  static const surfaceMuted = AppColorPrimitives.unspecifiedBackground;
  static const surfaceAlt = AppColorPrimitives.unspecifiedBackgroundAlt;

  static const borderDefault = AppColorPrimitives.grayGray2;
  static const borderSubtle = AppColorPrimitives.lightSeparator;
  static const borderMuted = AppColorPrimitives.unspecifiedBorder;
  static const separator = AppColorPrimitives.separatorColors;

  static const textPrimary = AppColorPrimitives.lightLabelPrimary;
  static const textHeadline = AppColorPrimitives.grayBlackTextHeadline;
  static const textStrong = AppColorPrimitives.grayGray6;
  static const textBody = AppColorPrimitives.grayGray5;
  static const textSecondary = AppColorPrimitives.lightLabelSecondary;
  static const textTertiary = AppColorPrimitives.lightLabelTertiary;
  static const textDisabled = AppColorPrimitives.grayGray3;

  static const iconInactive = AppColorPrimitives.grayGray4;
  static const actionBlue = AppColorPrimitives.lightSystemBlue;
  static const alertSurface = AppColorPrimitives.lightAlertBackground;
  static const danger = AppColorPrimitives.primaryElectricCrimson;
  static const guestLogin = AppColorPrimitives.unspecifiedGuestLogin;
  static const loginKakaoBackground = AppColorPrimitives.kakaoYellow;
  static const onBrand = AppColorPrimitives.grayWhite;
  static const white = AppColorPrimitives.grayWhite;
}

abstract final class AppGradients {
  const AppGradients._();

  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0, 0.53, 0.88, 1],
    colors: <Color>[
      Color(0x00000000),
      Color(0x36000000),
      Color(0xF2000000),
      Color(0xFF000000),
    ],
  );

  static const softFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0, 1],
    colors: <Color>[Color(0xFFD8DEDD), Color(0x00D8DEDD)],
  );
}
