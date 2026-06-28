import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';

class MemoDeleteDialog extends StatelessWidget {
  const MemoDeleteDialog({
    super.key,
    required this.onCancel,
    required this.onDelete,
  });

  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CommonDialogCard(
      title: '게시물 삭제',
      message: '해당 게시물을 삭제하시겠습니까?',
      actions: [
        CommonDialogActionButton(
          label: '취소',
          foregroundColor: AppColors.textBody,
          onPressed: onCancel,
        ),
        CommonDialogActionButton.confirm(
          label: '삭제',
          foregroundColor: AppColors.danger,
          onPressed: onDelete,
        ),
      ],
    );
  }
}
