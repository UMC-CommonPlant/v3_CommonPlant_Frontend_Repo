import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_friend_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeFriendSelectionControllerProvider =
    NotifierProvider.autoDispose<
      PlaceFriendSelectionController,
      PlaceFriendSelectionState
    >(PlaceFriendSelectionController.new);

final placeFriendSearchProvider = Provider.autoDispose<PlaceFriendSearchState>((
  ref,
) {
  final query = ref.watch(
    placeFriendSelectionControllerProvider.select((state) => state.query),
  );

  if (query.isEmpty) {
    return const PlaceFriendSearchState.idle();
  }

  if (!ref.watch(useRemoteApiProvider)) {
    final friends = placeFriendFixture
        .where((friend) => friend.name.contains(query))
        .toList(growable: false);

    return PlaceFriendSearchState.local(friends);
  }

  final result = ref
      .watch(userSearchProvider(query))
      .unwrapPrevious()
      .whenData(
        (users) => List<PlaceFriendProfile>.unmodifiable(
          users.map((user) => PlaceFriendProfile(id: user.id, name: user.name)),
        ),
      );

  return PlaceFriendSearchState.remote(result);
});

class PlaceFriendSelectionState {
  const PlaceFriendSelectionState({
    required this.query,
    required this.selectedFriendsById,
  });

  const PlaceFriendSelectionState.initial()
    : query = '',
      selectedFriendsById = const {};

  final String query;
  final Map<String, PlaceFriendProfile> selectedFriendsById;

  Set<String> get selectedIds => Set.unmodifiable(selectedFriendsById.keys);

  List<PlaceFriendProfile> get selectedFriends =>
      List.unmodifiable(selectedFriendsById.values);

  bool isSelected(String friendId) {
    return selectedFriendsById.containsKey(friendId);
  }

  PlaceFriendSelectionState copyWith({
    String? query,
    Map<String, PlaceFriendProfile>? selectedFriendsById,
  }) {
    return PlaceFriendSelectionState(
      query: query ?? this.query,
      selectedFriendsById: selectedFriendsById ?? this.selectedFriendsById,
    );
  }
}

class PlaceFriendSearchState {
  const PlaceFriendSearchState._({
    required this.result,
    required this.showEmptyState,
  });

  const PlaceFriendSearchState.idle()
    : this._(
        result: const AsyncData<List<PlaceFriendProfile>>([]),
        showEmptyState: false,
      );

  PlaceFriendSearchState.local(List<PlaceFriendProfile> friends)
    : this._(
        result: AsyncData(List.unmodifiable(friends)),
        showEmptyState: false,
      );

  const PlaceFriendSearchState.remote(
    AsyncValue<List<PlaceFriendProfile>> result,
  ) : this._(result: result, showEmptyState: true);

  final AsyncValue<List<PlaceFriendProfile>> result;
  final bool showEmptyState;
}

class PlaceFriendSelectionController
    extends Notifier<PlaceFriendSelectionState> {
  @override
  PlaceFriendSelectionState build() {
    if (ref.watch(useRemoteApiProvider)) {
      ref.watch(userDataSessionProvider);
    }
    return const PlaceFriendSelectionState.initial();
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query.trim());
  }

  void toggle(PlaceFriendProfile friend) {
    final selectedFriends = Map<String, PlaceFriendProfile>.of(
      state.selectedFriendsById,
    );

    if (selectedFriends.containsKey(friend.id)) {
      selectedFriends.remove(friend.id);
    } else {
      selectedFriends[friend.id] = friend;
    }

    state = state.copyWith(
      selectedFriendsById: Map.unmodifiable(selectedFriends),
    );
  }

  void remove(PlaceFriendProfile friend) {
    if (!state.isSelected(friend.id)) {
      return;
    }

    final selectedFriends = Map<String, PlaceFriendProfile>.of(
      state.selectedFriendsById,
    )..remove(friend.id);

    state = state.copyWith(
      selectedFriendsById: Map.unmodifiable(selectedFriends),
    );
  }

  void retrySearch() {
    if (state.query.isEmpty) {
      return;
    }

    ref.invalidate(userSearchProvider(state.query));
  }
}
