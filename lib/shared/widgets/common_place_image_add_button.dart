import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonPlaceImageAddButton extends StatelessWidget {
  const CommonPlaceImageAddButton({
    super.key,
    this.onTap,
    this.size = AppSizes.placeImageAddButtonSize,
    this.imageAsset,
    this.imageSemanticsLabel,
  });

  final VoidCallback? onTap;
  final double size;
  final String? imageAsset;
  final String? imageSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: SizedBox(
                width: AppSizes.placeImageAddInnerSize,
                height: AppSizes.placeImageAddInnerSize,
                child: imageAsset == null
                    ? const ColoredBox(
                        color: AppColors.borderDefault,
                        child: Center(
                          child: CommonSvgIcon(
                            AppIconAssets.addPlace,
                            width: 75,
                            height: 75,
                            color: AppColors.white,
                            semanticsLabel: '장소 이미지 추가',
                          ),
                        ),
                      )
                    : Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        semanticLabel: imageSemanticsLabel,
                        excludeFromSemantics: imageSemanticsLabel == null,
                      ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: AppSizes.placeImageCameraBoxSize,
              height: AppSizes.placeImageCameraBoxSize,
              decoration: const BoxDecoration(
                color: AppColors.iconInactive,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const CommonSvgIcon(
                AppIconAssets.camera,
                width: AppSizes.placeImageCameraIconSize,
                height: AppSizes.placeImageCameraIconSize,
                color: AppColors.white,
                semanticsLabel: '카메라',
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: content,
    );
  }
}
