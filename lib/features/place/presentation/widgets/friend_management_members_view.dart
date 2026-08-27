import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_candidate_list.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_search_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendManagementMembersView extends StatelessWidget {
  const FriendManagementMembersView({
    super.key,
    required this.members,
    required this.hasQuery,
    required this.selectedIds,
    required this.onToggle,
    required this.onRetry,
  });

  final AsyncValue<List<PlaceFriendProfile>> members;
  final bool hasQuery;
  final Set<String> selectedIds;
  final ValueChanged<PlaceFriendProfile>? onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return members.when(
      data: (friends) {
        if (friends.isEmpty) {
          return PlaceFriendSearchStatusView(
            title: hasQuery ? '검색 결과가 없어요' : '장소 멤버가 없어요',
            message: hasQuery ? '다른 닉네임으로 검색해 주세요' : '참여한 멤버가 생기면 여기에 표시돼요',
          );
        }

        return PlaceFriendCandidateList(
          friends: friends,
          selectedIds: selectedIds,
          onToggle: onToggle,
          topPadding: 0,
        );
      },
      error: (error, stackTrace) => PlaceFriendSearchStatusView(
        title: '장소 멤버를 불러오지 못했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: onRetry,
      ),
      loading: () => const PlaceFriendSearchStatusView(
        title: '장소 멤버를 불러오고 있어요',
        message: '함께하는 멤버를 확인하고 있어요',
        isLoading: true,
      ),
    );
  }
}
