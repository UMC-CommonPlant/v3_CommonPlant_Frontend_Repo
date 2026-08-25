import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeDetailProvider = FutureProvider.family<PlaceDetail, String>(
  (ref, code) => ref.watch(placeRepositoryProvider).fetchPlaceDetail(code),
  retry: (retryCount, error) => null,
);

final placeSummaryProvider = FutureProvider.family<PlaceSummary, String>(
  (ref, code) => ref.watch(placeRepositoryProvider).fetchPlace(code),
  retry: (retryCount, error) => null,
);
