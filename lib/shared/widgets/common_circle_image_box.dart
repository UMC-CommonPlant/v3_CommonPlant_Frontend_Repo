import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonCircleImageBox extends StatelessWidget {
  const CommonCircleImageBox({
    super.key,
    this.size = AppSizes.profileImageBoxSize,
    this.imageProvider,
    this.placeholder,
    this.onTap,
    this.overlay,
    this.placeholderColor = AppColors.brandAccent,
    this.showOverlay = true,
  });

  final double size;
  final ImageProvider<Object>? imageProvider;
  final Widget? placeholder;
  final VoidCallback? onTap;
  final Widget? overlay;
  final Color placeholderColor;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider!, fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? placeholder != null
                        ? SizedBox.expand(child: placeholder!)
                        : CommonSvgIcon(
                            AppIconAssets.addPerson,
                            width: size,
                            height: size,
                            color: placeholderColor,
                            semanticsLabel: '프로필 추가',
                          )
                  : null,
            ),
          ),
        ),
        if (showOverlay)
          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: AppSizes.profileImageOverlaySize,
              height: AppSizes.profileImageOverlaySize,
              child:
                  overlay ??
                  const CommonSvgIcon(
                    AppIconAssets.subtract,
                    width: AppSizes.profileImageOverlaySize,
                    height: AppSizes.profileImageOverlaySize,
                    semanticsLabel: '프로필 추가 버튼',
                  ),
            ),
          ),
      ],
    );

    return child;
  }
}
