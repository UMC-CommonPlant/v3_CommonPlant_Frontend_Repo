import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPlaceSummariesProvider = FutureProvider<List<PlaceSummary>>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    requireUserDataSession(ref);
    return ref.watch(placeRepositoryProvider).fetchUserPlaces();
  }

  return ref.watch(placeListProvider);
}, retry: (retryCount, error) => null);
