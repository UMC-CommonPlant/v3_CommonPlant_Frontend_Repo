import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonEditDeletePopup extends StatelessWidget {
  const CommonEditDeletePopup({
    super.key,
    this.onEdit,
    this.onDelete,
    this.editLabel = '수정하기',
    this.deleteLabel = '삭제하기',
    this.editLeading,
    this.deleteLeading,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String editLabel;
  final String deleteLabel;
  final Widget? editLeading;
  final Widget? deleteLeading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.editDeletePopupWidth,
      height: AppSizes.editDeletePopupHeight,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: _PopupActionRow(
                label: editLabel,
                onTap: onEdit,
                leading:
                    editLeading ??
                    const CommonSvgIcon(
                      AppIconAssets.edit,
                      width: AppSizes.editDeletePopupIconSize,
                      height: AppSizes.editDeletePopupIconSize,
                      color: Colors.black,
                      semanticsLabel: '수정하기',
                    ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColorPrimitives.separatorColors.withValues(alpha: 0.36),
            ),
            Expanded(
              child: _PopupActionRow(
                label: deleteLabel,
                onTap: onDelete,
                leading:
                    deleteLeading ??
                    const CommonSvgIcon(
                      AppIconAssets.trashBin,
                      width: AppSizes.editDeletePopupIconSize,
                      height: AppSizes.editDeletePopupIconSize,
                      color: Colors.black,
                      semanticsLabel: '삭제하기',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupActionRow extends StatelessWidget {
  const _PopupActionRow({
    required this.label,
    required this.leading,
    this.onTap,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x24),
      child: Row(
        children: [
          SizedBox.square(
            dimension: AppSizes.editDeletePopupIconSize,
            child: Center(child: leading),
          ),
          const SizedBox(width: AppSpacing.x20),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.size16Medium.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return SizedBox.expand(child: child);
    }

    return SizedBox.expand(
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
