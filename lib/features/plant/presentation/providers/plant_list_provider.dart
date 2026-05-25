import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';

final plantListProvider =
    NotifierProvider<PlantListNotifier, List<PlantSummary>>(
      PlantListNotifier.new,
    );

final remotePlantListProvider = FutureProvider<List<PlantSummary>>((ref) {
  return ref.watch(plantRepositoryProvider).fetchPlants();
});

final plantSummariesProvider = Provider<AsyncValue<List<PlantSummary>>>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    return ref.watch(remotePlantListProvider);
  }

  return AsyncData(ref.watch(plantListProvider));
});

final remotePlantDetailProvider = FutureProvider.family<PlantDetail, String>(
  (ref, plantId) =>
      ref.watch(plantRepositoryProvider).fetchPlant(plantId: plantId),
  retry: (retryCount, error) => null,
);

final remotePlantEditInfoProvider =
    FutureProvider.family<PlantEditInfo, String>(
      (ref, plantId) => ref
          .watch(plantRepositoryProvider)
          .fetchPlantEditInfo(plantId: plantId),
      retry: (retryCount, error) => null,
    );

class PlantListNotifier extends Notifier<List<PlantSummary>> {
  int _nextId = 1;

  @override
  List<PlantSummary> build() {
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
