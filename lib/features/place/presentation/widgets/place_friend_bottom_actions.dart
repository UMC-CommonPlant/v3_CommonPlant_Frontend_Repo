import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';

const double placeFriendActionGap = 8;

class PlaceFriendBottomActions extends StatelessWidget {
  const PlaceFriendBottomActions({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  final VoidCallback onCancel;
  final VoidCallback onComplete;

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
          const SizedBox(width: placeFriendActionGap),
          Expanded(
            child: CommonButton(
              label: '완료',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.brandAccent,
              foregroundColor: AppColors.white,
              onPressed: onComplete,
            ),
          ),
        ],
      ),
    );
  }
}
