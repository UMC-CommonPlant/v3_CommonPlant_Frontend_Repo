import 'dart:math' as math;

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double _figmaFrameWidth = 375;
const double _figmaFrameHeight = 812;
const double _sheetRearTop = 40;
const double _sheetTop = 50;
const double _sheetRadius = 10;
const double _backButtonTop = 63;
const double _profileContentTop = 147;
const double _profileAvatarBoxSize = 100;
const double _profileAvatarImageSize = 83.33;
const double _bottomActionsTop = 626;
const double _termsRowHeight = 56;
const double _nicknameFieldHeight = 56;
const double _nicknameFieldHeightWithHelper = 80;

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  bool _hasImage = false;

  bool get _canSubmit {
    final nickname = _nicknameController.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  @override
  void dispose() {
    _nicknameFocusNode.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _toggleSampleImage() {
    setState(() => _hasImage = !_hasImage);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textHeadline,
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
                top: _sheetRearTop * verticalScale,
                left: AppSpacing.x16,
                right: AppSpacing.x16,
                height: AppSpacing.x10,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _sheetTop * verticalScale,
                left: 0,
                right: 0,
                bottom: 0,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _backButtonTop * verticalScale,
                left: 0,
                child: SizedBox(
                  width: AppSizes.navigationBarSideWidth,
                  height: AppSizes.navigationBarHeight,
                  child: IconButton(
                    tooltip: '뒤로가기',
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: AppSizes.navigationBackIconSize,
                      color: AppColors.textStrong,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _profileContentTop * verticalScale,
                left: horizontalInset,
                width: contentWidth,
                child: Column(
                  children: [
                    _ProfileAvatar(
                      hasImage: _hasImage,
                      onTap: _toggleSampleImage,
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    _ProfileNicknameField(
                      controller: _nicknameController,
                      focusNode: _nicknameFocusNode,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: _bottomActionsTop * verticalScale,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    _TermsAgreementRow(
                      onViewPressed: () => context.push(AppRoutePaths.terms),
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalInset,
                      ),
                      child: _ProfileCompleteButton(
                        enabled: _canSubmit,
                        onPressed: () => context.go(AppRoutePaths.terms),
                      ),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.hasImage, required this.onTap});

  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasImage ? '프로필 이미지' : '프로필 추가',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          key: const ValueKey('profileAvatar'),
          width: _profileAvatarBoxSize,
          height: _profileAvatarBoxSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (hasImage)
                ClipOval(
                  child: Image.asset(
                    AppImageAssets.profileSetupSampleAvatar,
                    width: _profileAvatarImageSize,
                    height: _profileAvatarImageSize,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                )
              else
                const CommonSvgIcon(
                  AppIconAssets.addPerson,
                  width: _profileAvatarBoxSize,
                  height: _profileAvatarBoxSize,
                  semanticsLabel: '프로필 기본 이미지',
                ),
              if (!hasImage)
                const Positioned(
                  right: 6,
                  bottom: 8,
                  child: CommonSvgIcon(
                    AppIconAssets.plus,
                    width: AppSizes.profileImageOverlaySize,
                    height: AppSizes.profileImageOverlaySize,
                    semanticsLabel: '프로필 이미지 추가',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileNicknameField extends StatelessWidget {
  const _ProfileNicknameField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  bool get _hasValidNickname {
    final nickname = controller.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    final hasValidNickname = _hasValidNickname;
    final lineColor = hasValidNickname
        ? AppColors.brandStrong
        : AppColors.textDisabled;

    return SizedBox(
      key: const ValueKey('profileNicknameField'),
      height: hasValidNickname
          ? _nicknameFieldHeightWithHelper
          : _nicknameFieldHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _nicknameFieldHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      maxLength: 10,
                      style: AppTextStyles.size18Medium.copyWith(
                        color: AppColors.textHeadline,
                      ),
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력해 주세요',
                        hintStyle: AppTextStyles.size18Medium.copyWith(
                          color: AppColors.textDisabled,
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x16,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (!hasText)
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.size14Medium.copyWith(
                          color: AppColors.textBody,
                        ),
                        children: const [
                          TextSpan(
                            text: '0',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: '/10'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (hasValidNickname)
            Positioned(
              left: 0,
              top: 64,
              child: Text(
                '사용 가능한 닉네임입니다',
                style: AppTextStyles.size12Medium.copyWith(
                  color: AppColors.brandStrong,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TermsAgreementRow extends StatelessWidget {
  const _TermsAgreementRow({required this.onViewPressed});

  final VoidCallback onViewPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('profileTermsRow'),
      height: _termsRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x20,
          vertical: AppSpacing.x16,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconMedium,
              height: AppSizes.iconMedium,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iconInactive,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: AppSizes.iconSmall,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.x12),
            Flexible(
              child: Text(
                '개인정보 이용 약관 동의',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size16Medium.copyWith(
                  color: AppColors.textHeadline,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x8),
            GestureDetector(
              onTap: onViewPressed,
              child: Text(
                '보기',
                style: AppTextStyles.size16Bold.copyWith(
                  color: AppColors.iconInactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompleteButton extends StatelessWidget {
  const _ProfileCompleteButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return CommonButton(
        key: const ValueKey('profileCompleteButton'),
        label: '완료',
        backgroundColor: AppColors.surfaceDisabled,
        foregroundColor: AppColors.textDisabled,
        onPressed: null,
      );
    }

    return CommonButton.secondary(
      key: const ValueKey('profileCompleteButton'),
      label: '완료',
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.brandPrimary,
      borderColor: AppColors.brandPrimary,
      onPressed: onPressed,
    );
  }
}
