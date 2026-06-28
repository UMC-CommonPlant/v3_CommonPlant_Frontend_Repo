import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

const double _profileAvatarBoxSize = 100;
const double _profileAvatarImageSize = 83.33;

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.hasImage, required this.onTap, super.key});

  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasImage ? '프로필 이미지' : '프로필 추가',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          key: const ValueKey('profileAvatar'),
          width: _profileAvatarBoxSize,
          height: _profileAvatarBoxSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (hasImage)
                ClipOval(
                  child: Image.asset(
                    AppImageAssets.profileSetupSampleAvatar,
                    width: _profileAvatarImageSize,
                    height: _profileAvatarImageSize,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                )
              else
                const CommonSvgIcon(
                  AppIconAssets.addPerson,
                  width: _profileAvatarBoxSize,
                  height: _profileAvatarBoxSize,
                  semanticsLabel: '프로필 기본 이미지',
                ),
              if (!hasImage)
                const Positioned(
                  right: 6,
                  bottom: 8,
                  child: CommonSvgIcon(
                    AppIconAssets.plus,
                    width: AppSizes.profileImageOverlaySize,
                    height: AppSizes.profileImageOverlaySize,
                    semanticsLabel: '프로필 이미지 추가',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
