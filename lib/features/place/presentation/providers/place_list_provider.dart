import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';

final placeListProvider =
    NotifierProvider<PlaceListNotifier, List<PlaceSummary>>(
      PlaceListNotifier.new,
    );

final remotePlaceListProvider = FutureProvider<List<PlaceSummary>>((ref) {
  return ref.watch(placeRepositoryProvider).fetchMyGardenPlaces();
});

final placeSummariesProvider = Provider<AsyncValue<List<PlaceSummary>>>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    return ref.watch(remotePlaceListProvider);
  }

  return AsyncData(ref.watch(placeListProvider));
});

final plantRegistrationPlaceProvider = FutureProvider<List<PlaceSummary>>((
  ref,
) {
  if (ref.watch(useRemoteApiProvider)) {
    return ref.watch(placeRepositoryProvider).fetchUserPlaces();
  }

  return ref.watch(placeListProvider);
});

final placeDetailProvider = FutureProvider.family<PlaceSummary, String>(
  (ref, code) => ref.watch(placeRepositoryProvider).fetchPlace(code),
  retry: (retryCount, error) => null,
);

class PlaceListNotifier extends Notifier<List<PlaceSummary>> {
  int _nextId = 1;

  @override
  List<PlaceSummary> build() {
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
