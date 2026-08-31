import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_friend_request_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_friend_selection_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_bottom_actions.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_candidate_list.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_search_status_view.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selected_strip.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _friendAddTrailingWidth = 81;

class PlaceFriendAddPage extends ConsumerWidget {
  const PlaceFriendAddPage({super.key, this.placeCode});

  final String? placeCode;

  void _cancel(BuildContext context) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }

    context.go(AppRoutePaths.home);
  }

  void _finish(BuildContext context) {
    context.go(AppRoutePaths.home);
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    List<PlaceFriendProfile> friends,
  ) async {
    final succeeded = await ref
        .read(placeFriendRequestControllerProvider.notifier)
        .submit(placeCode: placeCode, friends: friends);

    if (!context.mounted) {
      return;
    }

    if (succeeded) {
      _finish(context);
      return;
    }

    final errorMessage = ref
        .read(placeFriendRequestControllerProvider)
        .errorMessage;
    if (errorMessage != null) {
      showCommonSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(placeFriendSelectionControllerProvider);
    final requestState = ref.watch(placeFriendRequestControllerProvider);
    final searchState = ref.watch(placeFriendSearchProvider);
    final controller = ref.read(
      placeFriendSelectionControllerProvider.notifier,
    );

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
                trailing: _FriendAddSkipButton(
                  onPressed: requestState.isSubmitting
                      ? null
                      : () => _finish(context),
                ),
              ),
              if (selectionState.selectedFriends.isNotEmpty)
                PlaceSelectedFriendMarkStrip(
                  friends: selectionState.selectedFriends,
                  onRemove: controller.remove,
                ),
              CommonSearchTextField(
                hintText: '닉네임 검색',
                horizontalPadding: AppSpacing.x16,
                onChanged: controller.updateQuery,
              ),
              Expanded(
                child: _FriendCandidateResults(
                  searchState: searchState,
                  selectedIds: selectionState.selectedIds,
                  onToggle: controller.toggle,
                  onRetry: controller.retrySearch,
                ),
              ),
              PlaceFriendBottomActions(
                onCancel: () => _cancel(context),
                onComplete: () =>
                    _complete(context, ref, selectionState.selectedFriends),
                isSubmitting: requestState.isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendCandidateResults extends StatelessWidget {
  const _FriendCandidateResults({
    required this.searchState,
    required this.selectedIds,
    required this.onToggle,
    required this.onRetry,
  });

  final PlaceFriendSearchState searchState;
  final Set<String> selectedIds;
  final ValueChanged<PlaceFriendProfile> onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return searchState.result.when(
      data: (friends) {
        if (friends.isEmpty) {
          if (!searchState.showEmptyState) {
            return const SizedBox.shrink();
          }

          return const PlaceFriendSearchStatusView(
            title: '검색 결과가 없어요',
            message: '다른 닉네임으로 검색해 주세요',
          );
        }

        return PlaceFriendCandidateList(
          friends: friends,
          selectedIds: selectedIds,
          onToggle: onToggle,
        );
      },
      error: (error, stackTrace) => PlaceFriendSearchStatusView(
        title: '사용자 검색에 실패했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: onRetry,
      ),
      loading: () => const PlaceFriendSearchStatusView(
        title: '사용자를 검색하고 있어요',
        message: '닉네임 검색 결과를 준비하고 있어요',
        isLoading: true,
      ),
    );
  }
}

class _FriendAddSkipButton extends StatelessWidget {
  const _FriendAddSkipButton({required this.onPressed});

  final VoidCallback? onPressed;

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
