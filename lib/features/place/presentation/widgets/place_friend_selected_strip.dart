import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_avatar.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

const double placeFriendSelectedMarkWidth = 56;
const double placeFriendSelectedMarkHeight = 56;
const double placeFriendSelectedAvatarSize = 36;
const double placeFriendSelectedDeleteSize = 18;
const double placeFriendSelectedDeleteTop = -12;
const double placeFriendSelectedDeleteRight = -8;

class PlaceSelectedFriendMarkStrip extends StatelessWidget {
  const PlaceSelectedFriendMarkStrip({
    super.key,
    required this.friends,
    required this.onRemove,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.x20,
      AppSpacing.x16,
      AppSpacing.x20,
      AppSpacing.x8,
    ),
    this.height = placeFriendSelectedMarkHeight,
    this.separatorWidth = AppSpacing.x12,
  });

  final List<PlaceFriendProfile> friends;
  final ValueChanged<String> onRemove;
  final EdgeInsetsGeometry padding;
  final double height;
  final double separatorWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: friends.length,
          separatorBuilder: (context, index) => SizedBox(width: separatorWidth),
          itemBuilder: (context, index) {
            final friend = friends[index];

            return _SelectedFriendMark(
              key: ValueKey('selected-friend-${friend.id}'),
              friend: friend,
              height: height,
              onRemove: () => onRemove(friend.id),
            );
          },
        ),
      ),
    );
  }
}

class _SelectedFriendMark extends StatelessWidget {
  const _SelectedFriendMark({
    super.key,
    required this.friend,
    required this.height,
    required this.onRemove,
  });

  final PlaceFriendProfile friend;
  final double height;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '선택된 친구 ${friend.name}',
      child: SizedBox(
        width: placeFriendSelectedMarkWidth,
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: placeFriendSelectedMarkWidth,
              height: placeFriendAvatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: AppSpacing.x10,
                    top: AppSpacing.x4,
                    child: PlaceFriendAvatar(
                      friend: friend,
                      dimension: placeFriendSelectedAvatarSize,
                    ),
                  ),
                  Positioned(
                    top: placeFriendSelectedDeleteTop,
                    right: placeFriendSelectedDeleteRight,
                    child: _SelectedFriendRemoveButton(
                      friendId: friend.id,
                      friendName: friend.name,
                      onPressed: onRemove,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              friend.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.size12Medium.copyWith(
                color: AppColors.iconInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedFriendRemoveButton extends StatelessWidget {
  const _SelectedFriendRemoveButton({
    required this.friendId,
    required this.friendName,
    required this.onPressed,
  });

  final String friendId;
  final String friendName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.iconButtonSize,
      child: IconButton(
        key: ValueKey('selected-friend-remove-$friendId'),
        onPressed: onPressed,
        tooltip: '$friendName 선택 해제',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: AppSizes.iconButtonSize,
          height: AppSizes.iconButtonSize,
        ),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const CommonSvgIcon(
          AppIconAssets.delete,
          width: placeFriendSelectedDeleteSize,
          height: placeFriendSelectedDeleteSize,
          color: AppColors.textBody,
          semanticsLabel: '선택 친구 삭제',
        ),
      ),
    );
  }
}
