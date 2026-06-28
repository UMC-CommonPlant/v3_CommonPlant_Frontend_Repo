import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class PlantEditPhotoButton extends StatelessWidget {
  const PlantEditPhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.plantEditPhotoCanvasSize,
      height: AppSizes.plantEditPhotoCanvasSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: AppSpacing.x10,
            top: AppSpacing.x10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.asset(
                AppImageAssets.plantEditMonstera,
                width: AppSizes.plantEditPhotoImageSize,
                height: AppSizes.plantEditPhotoImageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: AppSizes.plantEditPhotoOverlayOffset,
            top: AppSizes.plantEditPhotoOverlayOffset,
            child: Semantics(
              label: '식물 사진 수정',
              button: true,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.iconInactive,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: AppSizes.plantEditPhotoCameraSize,
                  child: Center(
                    child: CommonSvgIcon(
                      AppIconAssets.cameraAlt,
                      width: AppSizes.iconLarge,
                      height: AppSizes.iconLarge,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
