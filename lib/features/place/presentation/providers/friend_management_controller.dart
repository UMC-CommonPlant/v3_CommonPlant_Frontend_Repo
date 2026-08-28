import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/friend_management_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendManagementControllerProvider = NotifierProvider.autoDispose
    .family<FriendManagementController, FriendManagementState, String>(
      FriendManagementController.new,
    );

class FriendManagementState {
  const FriendManagementState({
    required this.placeId,
    required this.query,
    required this.selectedIds,
    required this.isReadOnly,
  });

  final String placeId;
  final String query;
  final Set<String> selectedIds;
  final bool isReadOnly;

  List<PlaceFriendProfile> filter(List<PlaceFriendProfile> friends) {
    if (query.isEmpty) {
      return friends;
    }

    return List.unmodifiable(
      friends.where((friend) => friend.name.contains(query)),
    );
  }

  List<PlaceFriendProfile> selectedFrom(List<PlaceFriendProfile> friends) =>
      List.unmodifiable(
        friends.where((friend) => selectedIds.contains(friend.id)),
      );

  bool isSelected(String friendId) {
    return selectedIds.contains(friendId);
  }

  FriendManagementState copyWith({String? query, Set<String>? selectedIds}) {
    return FriendManagementState(
      placeId: placeId,
      query: query ?? this.query,
      selectedIds: selectedIds ?? this.selectedIds,
      isReadOnly: isReadOnly,
    );
  }
}

class FriendManagementController extends Notifier<FriendManagementState> {
  FriendManagementController(this.placeId);

  final String placeId;

  @override
  FriendManagementState build() {
    final isReadOnly = ref.watch(useRemoteApiProvider);
    if (isReadOnly) {
      ref.watch(userDataSessionProvider);
    }

    return FriendManagementState(
      placeId: placeId,
      query: '',
      selectedIds: isReadOnly
          ? const {}
          : Set.unmodifiable(
              friendManagementFixture.map((friend) => friend.id),
            ),
      isReadOnly: isReadOnly,
    );
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query.trim());
  }

  void select(PlaceFriendProfile friend) {
    if (state.isReadOnly || state.isSelected(friend.id)) {
      return;
    }

    state = state.copyWith(
      selectedIds: Set.unmodifiable({...state.selectedIds, friend.id}),
    );
  }

  void remove(PlaceFriendProfile friend) {
    if (state.isReadOnly || !state.isSelected(friend.id)) {
      return;
    }

    final selectedIds = Set<String>.of(state.selectedIds)..remove(friend.id);
    state = state.copyWith(selectedIds: Set.unmodifiable(selectedIds));
  }
}
