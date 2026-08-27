import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/friend_management_members_view.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_bottom_actions.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selected_strip.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _friendManagementSelectedMarkHeight = 57;
const double _friendManagementSelectedMarkGap = 4;

class FriendManagementPage extends ConsumerWidget {
  const FriendManagementPage({super.key, required this.placeId});

  final String placeId;

  void _toggleFriend(
    BuildContext context,
    WidgetRef ref,
    FriendManagementState state,
    PlaceFriendProfile friend,
  ) {
    if (state.isSelected(friend.id)) {
      _showDeleteDialog(context, ref, friend);
      return;
    }

    ref
        .read(friendManagementControllerProvider(placeId).notifier)
        .select(friend);
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    PlaceFriendProfile friend,
  ) {
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
              ref
                  .read(friendManagementControllerProvider(placeId).notifier)
                  .remove(friend);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _leavePage(BuildContext context) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router == null) {
      return;
    }

    if (placeId.isEmpty) {
      router.go(AppRoutePaths.home);
      return;
    }

    router.go(AppRoutePaths.placeDetailLocation(placeId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = friendManagementControllerProvider(placeId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final members = ref.watch(friendManagementMembersProvider(placeId));
    final selectedFriends = state.selectedFrom(members.value ?? const []);

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
              if (state.isReadOnly)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x20,
                    vertical: AppSpacing.x8,
                  ),
                  child: Text(
                    '현재는 멤버 조회와 검색만 지원해요. 추가·삭제 기능은 준비 중이에요.',
                    style: AppTextStyles.size12Medium.copyWith(
                      color: AppColors.textBody,
                    ),
                  ),
                ),
              if (!state.isReadOnly && selectedFriends.isNotEmpty)
                PlaceSelectedFriendMarkStrip(
                  friends: selectedFriends,
                  onRemove: (friend) => _showDeleteDialog(context, ref, friend),
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
                hintText: '닉네임 검색',
                horizontalPadding: AppSpacing.x16,
                onChanged: controller.updateQuery,
              ),
              Expanded(
                child: FriendManagementMembersView(
                  members: members.whenData(state.filter),
                  hasQuery: state.query.isNotEmpty,
                  selectedIds: state.selectedIds,
                  onToggle: state.isReadOnly
                      ? null
                      : (friend) => _toggleFriend(context, ref, state, friend),
                  onRetry: () => ref.invalidate(
                    remoteFriendManagementMembersProvider(placeId),
                  ),
                ),
              ),
              if (state.isReadOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x20,
                    0,
                    AppSpacing.x20,
                    AppSpacing.x16,
                  ),
                  child: CommonButton(
                    label: '확인',
                    size: CommonButtonSize.medium,
                    fullWidth: true,
                    onPressed: () => _leavePage(context),
                  ),
                )
              else
                PlaceFriendBottomActions(
                  onCancel: () => _leavePage(context),
                  onComplete: () => _leavePage(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
