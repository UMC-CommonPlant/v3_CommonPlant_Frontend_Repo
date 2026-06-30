import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPlaceExitDialog({
  required BuildContext context,
  required bool isExiting,
  required VoidCallback onConfirm,
}) async {
  await showCommonDialog<void>(
    context: context,
    child: CommonDialogCard(
      title: '장소를 나가시겠어요?',
      message: '나가면 더 이상 식물을 관리할 수 없어요.',
      actions: [
        CommonDialogActionButton(
          label: '취소',
          foregroundColor: AppColors.textBody,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CommonDialogActionButton.confirm(
          label: '나가기',
          foregroundColor: AppColors.danger,
          onPressed: isExiting ? null : onConfirm,
        ),
      ],
    ),
  );
}
