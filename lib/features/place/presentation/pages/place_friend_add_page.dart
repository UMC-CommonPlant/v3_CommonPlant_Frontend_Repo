import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selection_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double _friendAddTrailingWidth = 81;

class PlaceFriendAddPage extends StatefulWidget {
  const PlaceFriendAddPage({super.key});

  @override
  State<PlaceFriendAddPage> createState() => _PlaceFriendAddPageState();
}

class _PlaceFriendAddPageState extends State<PlaceFriendAddPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};

  static const List<PlaceFriendProfile> _friends = [
    PlaceFriendProfile(
      id: 'friend-1',
      name: '커먼맘',
      imageAsset: AppImageAssets.placeFriendAddCommonMom,
    ),
    PlaceFriendProfile(
      id: 'friend-2',
      name: '커먼인척',
      imageAsset: AppImageAssets.placeFriendAddCommonFake,
    ),
    PlaceFriendProfile(
      id: 'friend-3',
      name: '커먼일뻔',
      imageAsset: AppImageAssets.placeFriendAddCommonAlmost,
    ),
    PlaceFriendProfile(
      id: 'friend-4',
      name: '커먼일지도',
      imageAsset: AppImageAssets.placeFriendAddCommonMaybe,
    ),
    PlaceFriendProfile(id: 'friend-5', name: '커먼 파파'),
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
        ? const <PlaceFriendProfile>[]
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
                PlaceSelectedFriendMarkStrip(
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
                child: PlaceFriendCandidateList(
                  friends: results,
                  selectedIds: _selectedIds,
                  onToggle: _toggle,
                ),
              ),
              PlaceFriendBottomActions(
                onCancel: _cancel,
                onComplete: _complete,
              ),
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
