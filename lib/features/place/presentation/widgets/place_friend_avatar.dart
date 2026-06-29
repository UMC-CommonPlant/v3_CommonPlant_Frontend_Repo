import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

const double placeFriendAvatarSize = 40;

class PlaceFriendAvatar extends StatelessWidget {
  const PlaceFriendAvatar({
    super.key,
    required this.friend,
    this.dimension = placeFriendAvatarSize,
  });

  final PlaceFriendProfile friend;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: ClipOval(
        child: friend.imageAsset == null
            ? ColoredBox(
                color: AppColors.borderDefault,
                child: Center(
                  child: CommonSvgIcon(
                    AppIconAssets.addPerson,
                    width: dimension * 0.7,
                    height: dimension * 0.7,
                    color: AppColors.white,
                    semanticsLabel: '기본 프로필',
                  ),
                ),
              )
            : Image.asset(friend.imageAsset!, fit: BoxFit.cover),
      ),
    );
  }
}
