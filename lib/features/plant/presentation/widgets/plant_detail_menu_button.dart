import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_motion.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class PlantDetailMenuButton extends StatelessWidget {
  const PlantDetailMenuButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '식물 상세 메뉴',
      child: ExcludeSemantics(
        child: IconButton(
          tooltip: '식물 상세 메뉴',
          onPressed: () => _showMenu(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: AppSizes.navigationBarSideWidth,
            height: AppSizes.navigationBarHeight,
          ),
          icon: const CommonSvgIcon(
            AppIconAssets.shape,
            width: 4,
            height: 20,
            color: AppColors.textStrong,
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final selectedAction = await showGeneralDialog<VoidCallback>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '식물 상세 메뉴 닫기',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: AppMotion.durationOf(context, AppMotion.fast),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standardCurve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween<double>(begin: 0.96, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, _, _) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                top:
                    MediaQuery.paddingOf(dialogContext).top +
                    AppSizes.navigationBarHeight +
                    AppSpacing.x8,
                right: AppSpacing.x20,
                child: CommonEditDeletePopup(
                  onEdit: () {
                    Navigator.of(dialogContext).pop(onEdit);
                  },
                  onDelete: () {
                    Navigator.of(dialogContext).pop(onDelete);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (context.mounted) {
      selectedAction?.call();
    }
  }
}
