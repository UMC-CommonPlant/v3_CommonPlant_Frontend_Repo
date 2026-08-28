import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantRegistrationPlaceProvider =
    FutureProvider.autoDispose<List<PlantRegistrationPlace>>((ref) async {
      final summaries = await ref.watch(userPlaceSummariesProvider.future);

      return List.unmodifiable([
        for (final place in summaries)
          PlantRegistrationPlace(
            id: place.id,
            name: place.name,
            imageAsset: AppImageAssets.placeEditLivingRoom,
          ),
      ]);
    }, retry: (retryCount, error) => null);
