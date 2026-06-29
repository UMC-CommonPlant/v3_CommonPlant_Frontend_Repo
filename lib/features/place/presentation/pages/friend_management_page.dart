import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_bottom_actions.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_candidate_list.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selected_strip.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double _friendManagementSelectedMarkHeight = 57;
const double _friendManagementSelectedMarkGap = 4;

class FriendManagementPage extends StatefulWidget {
  const FriendManagementPage({super.key, required this.placeId});

  final String placeId;

  @override
  State<FriendManagementPage> createState() => _FriendManagementPageState();
}

class _FriendManagementPageState extends State<FriendManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{'friend-1', 'friend-2'};

  static const List<PlaceFriendProfile> _friends = [
    PlaceFriendProfile(
      id: 'friend-1',
      name: '커먼맘',
      imageAsset: AppImageAssets.placeFriendAddCommonMom,
    ),
    PlaceFriendProfile(id: 'friend-2', name: '커먼 파파'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFriend(String friendId) {
    final friend = _friends.firstWhere((friend) => friend.id == friendId);

    if (_selectedIds.contains(friendId)) {
      _showDeleteDialog(friend);
      return;
    }

    setState(() => _selectedIds.add(friendId));
  }

  void _removeFriend(String friendId) {
    final friend = _friends.firstWhere((friend) => friend.id == friendId);
    _showDeleteDialog(friend);
  }

  void _showDeleteDialog(PlaceFriendProfile friend) {
    showCommonDialog<void>(
      context: context,
      barrierColor: AppColors.textHeadline.withValues(alpha: 0.6),
      child: CommonDialogCard(
        title: friend.name,
        message: '님을 친구 목록에서 삭제하시겠습니까?',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            foregroundColor: AppColors.textBody,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CommonDialogActionButton.confirm(
            label: '삭제',
            onPressed: () {
              setState(() => _selectedIds.remove(friend.id));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _leavePage() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router == null) {
      return;
    }

    if (widget.placeId.isEmpty) {
      router.go(AppRoutePaths.home);
      return;
    }

    router.go(AppRoutePaths.placeDetailLocation(widget.placeId));
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = query.isEmpty
        ? _friends
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
                title: '친구 관리',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (selectedFriends.isNotEmpty)
                PlaceSelectedFriendMarkStrip(
                  friends: selectedFriends,
                  onRemove: _removeFriend,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x20,
                    AppSpacing.x16,
                    AppSpacing.x20,
                    0,
                  ),
                  height: _friendManagementSelectedMarkHeight,
                  separatorWidth: _friendManagementSelectedMarkGap,
                ),
              CommonSearchTextField(
                controller: _searchController,
                hintText: '닉네임 검색',
                horizontalPadding: AppSpacing.x16,
                onChanged: (_) => setState(() {}),
              ),
              Expanded(
                child: PlaceFriendCandidateList(
                  friends: results,
                  selectedIds: _selectedIds,
                  topPadding: 0,
                  onToggle: _toggleFriend,
                ),
              ),
              PlaceFriendBottomActions(
                onCancel: _leavePage,
                onComplete: _leavePage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
