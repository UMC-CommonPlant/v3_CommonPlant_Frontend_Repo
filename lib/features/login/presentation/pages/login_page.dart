import 'dart:math' as math;

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double _figmaFrameWidth = 375;
const double _figmaFrameHeight = 812;
const double _logoTop = 140;
const double _logoCommonWidth = 127.292;
const double _logoCommonHeight = 23.135;
const double _logoPlantWidth = 71.255;
const double _logoPlantHeight = 24.377;
const double _heroTop = 204.377;
const double _heroSize = 186;
const double _buttonTop = 582;
const double _buttonHeight = 44;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _goNext(BuildContext context) {
    context.go(AppRoutePaths.profileSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final verticalScale = math.min(
            1.0,
            constraints.maxHeight / _figmaFrameHeight,
          );
          final contentWidth = math.min(
            _figmaFrameWidth - (AppSpacing.x20 * 2),
            math.max(0.0, constraints.maxWidth - (AppSpacing.x20 * 2)),
          );
          final horizontalInset = math.max(
            AppSpacing.x20,
            (constraints.maxWidth - contentWidth) / 2,
          );

          return Stack(
            children: [
              Positioned(
                top: _logoTop * verticalScale,
                left: 0,
                right: 0,
                child: const _LoginWordmark(),
              ),
              Positioned(
                top: _heroTop * verticalScale,
                left: (constraints.maxWidth - (_heroSize * verticalScale)) / 2,
                width: _heroSize * verticalScale,
                height: _heroSize * verticalScale,
                child: const CommonSvgIcon(
                  AppImageAssets.loginHeroIllustration,
                  fit: BoxFit.fill,
                  semanticsLabel: '로그인 일러스트',
                ),
              ),
              Positioned(
                top: _buttonTop * verticalScale,
                left: horizontalInset,
                right: horizontalInset,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LoginSocialButton(
                      key: const ValueKey('loginKakaoButton'),
                      label: '카카오로 로그인',
                      backgroundColor: AppColors.loginKakaoBackground,
                      foregroundColor: AppColors.textStrong,
                      logoAssetPath: AppImageAssets.loginKakaoLogo,
                      logoWidth: 18,
                      logoHeight: 18,
                      logoTop: 11,
                      onPressed: () => _goNext(context),
                    ),
                    const SizedBox(height: AppSpacing.x12),
                    _LoginSocialButton(
                      key: const ValueKey('loginGoogleButton'),
                      label: '구글로 로그인',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.textStrong,
                      borderColor: AppColors.borderDefault,
                      logoAssetPath: AppImageAssets.loginGoogleLogo,
                      logoWidth: 18,
                      logoHeight: 18,
                      logoTop: 10,
                      onPressed: () => _goNext(context),
                    ),
                    const SizedBox(height: AppSpacing.x12),
                    _LoginSocialButton(
                      key: const ValueKey('loginAppleButton'),
                      label: 'Apple로 로그인',
                      backgroundColor: AppColors.textHeadline,
                      foregroundColor: AppColors.white,
                      logoAssetPath: AppImageAssets.loginAppleLogo,
                      logoWidth: 16.26,
                      logoHeight: 20,
                      logoTop: 12,
                      onPressed: () => _goNext(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginWordmark extends StatelessWidget {
  const _LoginWordmark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        key: const ValueKey('loginWordmark'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          CommonSvgIcon(
            AppIconAssets.logoWordmarkCommon,
            width: _logoCommonWidth,
            height: _logoCommonHeight,
            semanticsLabel: 'Common',
          ),
          SizedBox(width: AppSpacing.x16),
          CommonSvgIcon(
            AppIconAssets.logoWordmarkPlant,
            width: _logoPlantWidth,
            height: _logoPlantHeight,
            semanticsLabel: 'Plant',
          ),
        ],
      ),
    );
  }
}

class _LoginSocialButton extends StatelessWidget {
  const _LoginSocialButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.logoAssetPath,
    required this.logoWidth,
    required this.logoHeight,
    required this.logoTop,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final String logoAssetPath;
  final double logoWidth;
  final double logoHeight;
  final double logoTop;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: _buttonHeight,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: AppSpacing.x16,
                  top: logoTop,
                  child: Image.asset(
                    logoAssetPath,
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size14Bold.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
