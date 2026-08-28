import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';

final plantListProvider =
    NotifierProvider<PlantListNotifier, List<PlantSummary>>(
      PlantListNotifier.new,
    );

final remotePlantListProvider = FutureProvider<List<PlantSummary>>((ref) {
  requireUserDataSession(ref);
  return ref.watch(plantRepositoryProvider).fetchPlants();
}, retry: (retryCount, error) => null);

final plantSummariesProvider = Provider<AsyncValue<List<PlantSummary>>>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    return ref.watch(remotePlantListProvider).unwrapPrevious();
  }

  return AsyncData(ref.watch(plantListProvider));
});

class PlantListNotifier extends Notifier<List<PlantSummary>> {
  int _nextId = 1;

  @override
  List<PlantSummary> build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    _nextId = 1;
    return const [];
  }

  PlantSummary addPlant({
    required String name,
    String? placeId,
    String? placeName,
    String? description,
  }) {
    final plant = PlantSummary(
      id: 'plant-${_nextId++}',
      name: name,
      placeId: placeId,
      placeName: placeName,
      description: description,
    );
    state = [...state, plant];
    return plant;
  }

  void updatePlant({
    required String id,
    required String name,
    String? placeId,
    String? placeName,
    String? description,
  }) {
    state = [
      for (final plant in state)
        if (plant.id == id)
          plant.copyWith(
            name: name,
            placeId: placeId,
            placeName: placeName,
            description: description,
          )
        else
          plant,
    ];
  }
}
