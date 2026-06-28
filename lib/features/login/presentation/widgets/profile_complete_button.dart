import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';

class ProfileCompleteButton extends StatelessWidget {
  const ProfileCompleteButton({
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final bool isSubmitting;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    if (!enabled && !isSubmitting) {
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
      isLoading: isSubmitting,
      onPressed: enabled && !isSubmitting ? onPressed : null,
    );
  }
}
