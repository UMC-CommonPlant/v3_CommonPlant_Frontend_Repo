import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remotePlantDetailProvider = FutureProvider.family<PlantDetail, String>(
  (ref, plantId) =>
      ref.watch(plantRepositoryProvider).fetchPlant(plantId: plantId),
  retry: (retryCount, error) => null,
);
