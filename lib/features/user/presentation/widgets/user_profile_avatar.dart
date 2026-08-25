import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_circle_image_box.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({
    super.key,
    required this.size,
    this.imageUrl,
    this.onEditPressed,
  });

  final double size;
  final String? imageUrl;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = imageUrl?.trim();
    final imageProvider =
        normalizedImageUrl == null || normalizedImageUrl.isEmpty
        ? null
        : NetworkImage(normalizedImageUrl);

    return Semantics(
      image: onEditPressed == null,
      button: onEditPressed != null,
      label: onEditPressed == null ? '프로필 이미지' : '프로필 이미지 수정',
      child: CommonCircleImageBox(
        size: size,
        imageProvider: imageProvider,
        onTap: onEditPressed,
        showOverlay: onEditPressed != null,
        overlayInset: onEditPressed == null ? 0 : AppSpacing.x8,
        placeholder: const CommonSvgIcon(
          AppIconAssets.userProfile,
          semanticsLabel: '기본 프로필 이미지',
        ),
        overlay: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.brandStrong,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CommonSvgIcon(
              AppIconAssets.cameraAlt,
              width: AppSizes.profileImageOverlayGlyphSize,
              height: AppSizes.profileImageOverlayGlyphSize,
              color: AppColors.white,
              semanticsLabel: '프로필 사진 변경',
            ),
          ),
        ),
      ),
    );
  }
}
