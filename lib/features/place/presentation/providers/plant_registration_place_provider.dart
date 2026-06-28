import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';

final plantRegistrationPlaceProvider = FutureProvider<List<PlaceSummary>>((
  ref,
) {
  if (ref.watch(useRemoteApiProvider)) {
    return ref.watch(placeRepositoryProvider).fetchUserPlaces();
  }

  return ref.watch(placeListProvider);
});
