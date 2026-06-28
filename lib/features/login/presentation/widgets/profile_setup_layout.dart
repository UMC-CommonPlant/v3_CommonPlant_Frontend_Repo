import 'dart:math' as math;

import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_avatar.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_complete_button.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_nickname_field.dart';
import 'package:commonplant_frontend/features/login/presentation/widgets/profile_terms_agreement_row.dart';
import 'package:flutter/material.dart';

const double _figmaFrameWidth = 375;
const double _figmaFrameHeight = 812;
const double _sheetRearTop = 40;
const double _sheetTop = 50;
const double _sheetRadius = 10;
const double _backButtonTop = 63;
const double _profileContentTop = 147;
const double _bottomActionsTop = 626;

class ProfileSetupLayout extends StatelessWidget {
  const ProfileSetupLayout({
    required this.nicknameController,
    required this.nicknameFocusNode,
    required this.hasImage,
    required this.isTermsAccepted,
    required this.isCompleteEnabled,
    required this.isSubmitting,
    required this.onBack,
    required this.onImagePressed,
    required this.onNicknameChanged,
    required this.onTermsPressed,
    required this.onTermsViewPressed,
    required this.onComplete,
    super.key,
  });

  final TextEditingController nicknameController;
  final FocusNode nicknameFocusNode;
  final bool hasImage;
  final bool isTermsAccepted;
  final bool isCompleteEnabled;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onImagePressed;
  final ValueChanged<String> onNicknameChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onTermsViewPressed;
  final Future<void> Function() onComplete;

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
                    onPressed: onBack,
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
                    ProfileAvatar(hasImage: hasImage, onTap: onImagePressed),
                    const SizedBox(height: AppSpacing.x16),
                    ProfileNicknameField(
                      controller: nicknameController,
                      focusNode: nicknameFocusNode,
                      onChanged: onNicknameChanged,
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
                    ProfileTermsAgreementRow(
                      isAccepted: isTermsAccepted,
                      onCheckPressed: onTermsPressed,
                      onViewPressed: onTermsViewPressed,
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalInset,
                      ),
                      child: ProfileCompleteButton(
                        enabled: isCompleteEnabled,
                        isSubmitting: isSubmitting,
                        onPressed: onComplete,
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
