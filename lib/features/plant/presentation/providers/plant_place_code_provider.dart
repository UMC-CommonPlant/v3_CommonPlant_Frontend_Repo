import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remotePlantPlaceCodeProvider = FutureProvider.family<String?, String>((
  ref,
  plantId,
) async {
  final normalizedPlantId = plantId.trim();
  if (normalizedPlantId.isEmpty) {
    return null;
  }

  final places = await ref.watch(remotePlaceListProvider.future);

  for (final place in places) {
    final detail = await ref.watch(placeDetailProvider(place.id).future);
    final containsPlant = detail.plants.any(
      (plant) => plant.id.trim() == normalizedPlantId,
    );

    if (containsPlant) {
      final code = detail.code.trim();
      return code.isEmpty ? place.id.trim() : code;
    }
  }

  return null;
}, retry: (retryCount, error) => null);

void invalidateRemotePlantPlaceCode(WidgetRef ref, String plantId) {
  final places = ref.read(remotePlaceListProvider).value;

  if (places != null) {
    for (final place in places) {
      ref.invalidate(placeDetailProvider(place.id));
    }
  }

  ref.invalidate(remotePlaceListProvider);
  ref.invalidate(remotePlantPlaceCodeProvider(plantId));
}
