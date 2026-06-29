import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_avatar.dart';
import 'package:flutter/material.dart';

const double placeFriendResultTileHeight = 56;

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
