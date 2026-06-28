import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';

class PlantFormBottomActions extends StatelessWidget {
  const PlantFormBottomActions({
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        0,
        AppSpacing.x20,
        AppSpacing.x16,
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonButton.dark(
              label: '취소',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.textBody,
              foregroundColor: AppColors.white,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: AppSpacing.x8),
          Expanded(
            child: CommonButton(
              label: '등록',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.brandAccent,
              foregroundColor: AppColors.white,
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
