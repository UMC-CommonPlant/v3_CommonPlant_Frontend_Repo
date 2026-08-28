import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';

final placeListProvider =
    NotifierProvider<PlaceListNotifier, List<PlaceSummary>>(
      PlaceListNotifier.new,
    );

final remotePlaceListProvider = FutureProvider<List<PlaceSummary>>((ref) {
  requireUserDataSession(ref);
  return ref.watch(placeRepositoryProvider).fetchMyGardenPlaces();
}, retry: (retryCount, error) => null);

final placeSummariesProvider = Provider<AsyncValue<List<PlaceSummary>>>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    return ref.watch(remotePlaceListProvider).unwrapPrevious();
  }

  return AsyncData(ref.watch(placeListProvider));
});

class PlaceListNotifier extends Notifier<List<PlaceSummary>> {
  int _nextId = 1;

  @override
  List<PlaceSummary> build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    _nextId = 1;
    return const [];
  }

  PlaceSummary addPlace({required String name, String? address}) {
    final place = PlaceSummary(
      id: 'place-${_nextId++}',
      name: name,
      address: address,
    );
    state = [...state, place];
    return place;
  }

  void updatePlace({
    required String id,
    required String name,
    String? address,
  }) {
    state = [
      for (final place in state)
        if (place.id == id)
          place.copyWith(name: name, address: address)
        else
          place,
    ];
  }
}
