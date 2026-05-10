import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

const double placeFriendResultTileHeight = 56;
const double placeFriendAvatarSize = 40;
const double placeFriendSelectedMarkWidth = 56;
const double placeFriendSelectedMarkHeight = 56;
const double placeFriendSelectedAvatarSize = 36;
const double placeFriendSelectedDeleteSize = 18;
const double placeFriendSelectedDeleteTop = -12;
const double placeFriendSelectedDeleteRight = -8;
const double placeFriendActionGap = 8;

class PlaceFriendProfile {
  const PlaceFriendProfile({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageAsset;
}

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

class PlaceFriendCandidateList extends StatelessWidget {
  const PlaceFriendCandidateList({
    super.key,
    required this.friends,
    required this.selectedIds,
    required this.onToggle,
    this.topPadding = AppSpacing.x8,
    this.bottomPadding = AppSpacing.x24,
  });

  final List<PlaceFriendProfile> friends;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      itemExtent: placeFriendResultTileHeight,
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final isSelected = selectedIds.contains(friend.id);

        return _FriendCandidateTile(
          friend: friend,
          isSelected: isSelected,
          onTap: () => onToggle(friend.id),
        );
      },
    );
  }
}

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

class PlaceFriendBottomActions extends StatelessWidget {
  const PlaceFriendBottomActions({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  final VoidCallback onCancel;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        0,
        AppSpacing.x20,
        AppSpacing.x16,
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonButton.dark(
              label: '취소',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.textBody,
              foregroundColor: AppColors.white,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: placeFriendActionGap),
          Expanded(
            child: CommonButton(
              label: '완료',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.brandAccent,
              foregroundColor: AppColors.white,
              onPressed: onComplete,
            ),
          ),
        ],
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

class _FriendCandidateTile extends StatelessWidget {
  const _FriendCandidateTile({
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  final PlaceFriendProfile friend;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${friend.name} ${isSelected ? '선택됨' : '선택 안됨'}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x20,
            vertical: AppSpacing.x8,
          ),
          child: Row(
            children: [
              PlaceFriendAvatar(friend: friend),
              const SizedBox(width: AppSpacing.x16),
              Expanded(
                child: Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.size16Medium.copyWith(
                    color: AppColors.textStrong,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x16),
              _FriendSelectionIcon(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendSelectionIcon extends StatelessWidget {
  const _FriendSelectionIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
      size: AppSizes.iconMedium,
      color: isSelected ? AppColors.brandAccent : AppColors.textDisabled,
    );
  }
}
