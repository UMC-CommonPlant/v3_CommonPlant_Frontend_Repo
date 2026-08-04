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
  });

  final String placeId;
  final String query;
  final Set<String> selectedIds;

  List<PlaceFriendProfile> get results {
    if (query.isEmpty) {
      return friendManagementFixture;
    }

    return List.unmodifiable(
      friendManagementFixture.where((friend) => friend.name.contains(query)),
    );
  }

  List<PlaceFriendProfile> get selectedFriends => List.unmodifiable(
    friendManagementFixture.where((friend) => selectedIds.contains(friend.id)),
  );

  bool isSelected(String friendId) {
    return selectedIds.contains(friendId);
  }

  FriendManagementState copyWith({String? query, Set<String>? selectedIds}) {
    return FriendManagementState(
      placeId: placeId,
      query: query ?? this.query,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class FriendManagementController extends Notifier<FriendManagementState> {
  FriendManagementController(this.placeId);

  final String placeId;

  @override
  FriendManagementState build() {
    return FriendManagementState(
      placeId: placeId,
      query: '',
      selectedIds: Set.unmodifiable(
        friendManagementFixture.map((friend) => friend.id),
      ),
    );
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query.trim());
  }

  void select(PlaceFriendProfile friend) {
    if (state.isSelected(friend.id)) {
      return;
    }

    state = state.copyWith(
      selectedIds: Set.unmodifiable({...state.selectedIds, friend.id}),
    );
  }

  void remove(PlaceFriendProfile friend) {
    if (!state.isSelected(friend.id)) {
      return;
    }

    final selectedIds = Set<String>.of(state.selectedIds)..remove(friend.id);
    state = state.copyWith(selectedIds: Set.unmodifiable(selectedIds));
  }
}
