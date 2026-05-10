import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double _friendAddResultTileHeight = 56;
const double _friendAddAvatarSize = 40;
const double _friendAddSelectedMarkWidth = 56;
const double _friendAddSelectedMarkHeight = 56;
const double _friendAddSelectedAvatarSize = 36;
const double _friendAddSelectedDeleteSize = 18;
const double _friendAddSelectedDeleteTop = -12;
const double _friendAddSelectedDeleteRight = -8;
const double _friendAddActionGap = 8;
const double _friendAddTrailingWidth = 81;

class PlaceFriendAddPage extends StatefulWidget {
  const PlaceFriendAddPage({super.key});

  @override
  State<PlaceFriendAddPage> createState() => _PlaceFriendAddPageState();
}

class _PlaceFriendAddPageState extends State<PlaceFriendAddPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};

  static const List<_FriendCandidate> _friends = [
    _FriendCandidate(
      id: 'friend-1',
      name: '커먼맘',
      imageAsset: AppImageAssets.placeFriendAddCommonMom,
    ),
    _FriendCandidate(
      id: 'friend-2',
      name: '커먼인척',
      imageAsset: AppImageAssets.placeFriendAddCommonFake,
    ),
    _FriendCandidate(
      id: 'friend-3',
      name: '커먼일뻔',
      imageAsset: AppImageAssets.placeFriendAddCommonAlmost,
    ),
    _FriendCandidate(
      id: 'friend-4',
      name: '커먼일지도',
      imageAsset: AppImageAssets.placeFriendAddCommonMaybe,
    ),
    _FriendCandidate(id: 'friend-5', name: '커먼 파파'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _cancel() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }

    context.go(AppRoutePaths.home);
  }

  void _complete() {
    context.go(AppRoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = query.isEmpty
        ? const <_FriendCandidate>[]
        : _friends.where((friend) => friend.name.contains(query)).toList();
    final selectedFriends = _friends
        .where((friend) => _selectedIds.contains(friend.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              CommonNavigationBar(
                title: '친구 추가',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
                trailing: _FriendAddSkipButton(onPressed: _complete),
              ),
              if (selectedFriends.isNotEmpty)
                _SelectedFriendMarkStrip(
                  friends: selectedFriends,
                  onRemove: _toggle,
                ),
              CommonSearchTextField(
                controller: _searchController,
                hintText: '닉네임 검색',
                horizontalPadding: AppSpacing.x16,
                onChanged: (_) => setState(() {}),
              ),
              Expanded(
                child: _FriendCandidateList(
                  friends: results,
                  selectedIds: _selectedIds,
                  onToggle: _toggle,
                ),
              ),
              _FriendAddBottomActions(onCancel: _cancel, onComplete: _complete),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendAddSkipButton extends StatelessWidget {
  const _FriendAddSkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _friendAddTrailingWidth,
      height: AppSizes.navigationBarHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textBody,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, AppSizes.navigationBarHeight),
          textStyle: AppTextStyles.size14Medium,
        ),
        child: Text(
          '건너뛰기',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size14Medium.copyWith(color: AppColors.textBody),
        ),
      ),
    );
  }
}

class _SelectedFriendMarkStrip extends StatelessWidget {
  const _SelectedFriendMarkStrip({
    required this.friends,
    required this.onRemove,
  });

  final List<_FriendCandidate> friends;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x16,
        AppSpacing.x20,
        AppSpacing.x8,
      ),
      child: SizedBox(
        width: double.infinity,
        height: _friendAddSelectedMarkHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: friends.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.x12),
          itemBuilder: (context, index) {
            final friend = friends[index];

            return _SelectedFriendMark(
              key: ValueKey('selected-friend-${friend.id}'),
              friend: friend,
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
    required this.onRemove,
  });

  final _FriendCandidate friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '선택된 친구 ${friend.name}',
      child: SizedBox(
        width: _friendAddSelectedMarkWidth,
        height: _friendAddSelectedMarkHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _friendAddSelectedMarkWidth,
              height: _friendAddAvatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: AppSpacing.x10,
                    top: AppSpacing.x4,
                    child: _FriendAvatar(
                      friend: friend,
                      dimension: _friendAddSelectedAvatarSize,
                    ),
                  ),
                  Positioned(
                    top: _friendAddSelectedDeleteTop,
                    right: _friendAddSelectedDeleteRight,
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
          width: _friendAddSelectedDeleteSize,
          height: _friendAddSelectedDeleteSize,
          color: AppColors.textBody,
          semanticsLabel: '선택 친구 삭제',
        ),
      ),
    );
  }
}

class _FriendCandidateList extends StatelessWidget {
  const _FriendCandidateList({
    required this.friends,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<_FriendCandidate> friends;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.x8,
        bottom: AppSpacing.x24,
      ),
      itemExtent: _friendAddResultTileHeight,
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

  final _FriendCandidate friend;
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
              _FriendAvatar(friend: friend),
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

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.friend,
    this.dimension = _friendAddAvatarSize,
  });

  final _FriendCandidate friend;
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

class _FriendAddBottomActions extends StatelessWidget {
  const _FriendAddBottomActions({
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
          const SizedBox(width: _friendAddActionGap),
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

class _FriendCandidate {
  const _FriendCandidate({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageAsset;
}
