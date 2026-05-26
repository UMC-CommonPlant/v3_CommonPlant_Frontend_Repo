import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selection_widgets.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_search_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _friendAddTrailingWidth = 81;

class PlaceFriendAddPage extends ConsumerStatefulWidget {
  const PlaceFriendAddPage({super.key});

  @override
  ConsumerState<PlaceFriendAddPage> createState() => _PlaceFriendAddPageState();
}

class _PlaceFriendAddPageState extends ConsumerState<PlaceFriendAddPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  final Map<String, PlaceFriendProfile> _remoteSelectedFriends =
      <String, PlaceFriendProfile>{};

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
        _remoteSelectedFriends.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleRemote(PlaceFriendProfile friend) {
    setState(() {
      if (_selectedIds.contains(friend.id)) {
        _selectedIds.remove(friend.id);
        _remoteSelectedFriends.remove(friend.id);
      } else {
        _selectedIds.add(friend.id);
        _remoteSelectedFriends[friend.id] = friend;
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
    final useRemoteApi = ref.watch(useRemoteApiProvider);
    final localResults = query.isEmpty
        ? const <PlaceFriendProfile>[]
        : _friends.where((friend) => friend.name.contains(query)).toList();
    final selectedFriends = useRemoteApi
        ? _remoteSelectedFriends.values.toList()
        : _friends.where((friend) => _selectedIds.contains(friend.id)).toList();

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
                child: useRemoteApi
                    ? _RemoteFriendCandidateList(
                        query: query,
                        selectedIds: _selectedIds,
                        onToggle: _toggleRemote,
                      )
                    : PlaceFriendCandidateList(
                        friends: localResults,
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

class _RemoteFriendCandidateList extends ConsumerWidget {
  const _RemoteFriendCandidateList({
    required this.query,
    required this.selectedIds,
    required this.onToggle,
  });

  final String query;
  final Set<String> selectedIds;
  final ValueChanged<PlaceFriendProfile> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    final users = ref.watch(userSearchProvider(query));

    return users.when(
      data: (items) {
        final friends = _friendsFromUsers(items);

        if (friends.isEmpty) {
          return const _FriendSearchStatusView(
            title: '검색 결과가 없어요',
            message: '다른 닉네임으로 검색해 주세요',
          );
        }

        return PlaceFriendCandidateList(
          friends: friends,
          selectedIds: selectedIds,
          onToggle: (id) {
            final friend = friends.firstWhere((friend) => friend.id == id);
            onToggle(friend);
          },
        );
      },
      error: (error, stackTrace) => _FriendSearchStatusView(
        title: '사용자 검색에 실패했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(userSearchProvider(query)),
      ),
      loading: () => const _FriendSearchStatusView(
        title: '사용자를 검색하고 있어요',
        message: '닉네임 검색 결과를 준비하고 있어요',
        isLoading: true,
      ),
    );
  }

  List<PlaceFriendProfile> _friendsFromUsers(List<UserProfile> users) {
    return [
      for (final user in users)
        PlaceFriendProfile(id: user.id, name: user.name),
    ];
  }
}

class _FriendSearchStatusView extends StatelessWidget {
  const _FriendSearchStatusView({
    required this.title,
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const SizedBox.square(
                dimension: AppSizes.iconLarge,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: AppSpacing.x16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.size16Medium.copyWith(
                color: AppColors.textStrong,
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textBody,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.x16),
              SizedBox(
                width: AppSizes.smallButtonWidth,
                child: TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
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
