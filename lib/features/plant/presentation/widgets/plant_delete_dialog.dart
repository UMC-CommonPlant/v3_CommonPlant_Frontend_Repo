import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPlantDeleteDialog({
  required BuildContext context,
  required bool isDeleting,
  required VoidCallback onConfirm,
}) async {
  await showCommonDialog<void>(
    context: context,
    child: CommonDialogCard(
      title: '식물을 삭제할까요?',
      message: '삭제하면 기록된 메모도 함께 사라져요.',
      actions: [
        CommonDialogActionButton(
          label: '취소',
          foregroundColor: AppColors.textBody,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CommonDialogActionButton.confirm(
          label: '삭제',
          foregroundColor: AppColors.danger,
          onPressed: isDeleting ? null : onConfirm,
        ),
      ],
    ),
  );
}
