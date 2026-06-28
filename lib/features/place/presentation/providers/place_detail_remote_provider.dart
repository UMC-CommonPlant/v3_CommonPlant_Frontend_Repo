import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeDetailProvider = FutureProvider.family<PlaceSummary, String>(
  (ref, code) => ref.watch(placeRepositoryProvider).fetchPlace(code),
  retry: (retryCount, error) => null,
);
