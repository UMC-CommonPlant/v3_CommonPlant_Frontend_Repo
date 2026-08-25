import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';

enum PlaceRemovalMode { leave, delete }

Future<void> showPlaceExitDialog({
  required BuildContext context,
  required bool isExiting,
  required VoidCallback onConfirm,
  PlaceRemovalMode mode = PlaceRemovalMode.leave,
}) async {
  final isDelete = mode == PlaceRemovalMode.delete;

  await showCommonDialog<void>(
    context: context,
    child: CommonDialogCard(
      title: isDelete ? '장소를 삭제하시겠어요?' : '장소를 나가시겠어요?',
      message: isDelete
          ? '삭제하면 장소의 식물과 메모도 함께 사라져요.'
          : '나가면 더 이상 식물을 관리할 수 없어요.',
      actions: [
        CommonDialogActionButton(
          label: '취소',
          foregroundColor: AppColors.textBody,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CommonDialogActionButton.confirm(
          label: isDelete ? '삭제' : '나가기',
          foregroundColor: AppColors.danger,
          onPressed: isExiting ? null : onConfirm,
        ),
      ],
    ),
  );
}
