import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';

abstract interface class PlantRepository {
  Future<List<PlantSummary>> fetchPlants({int page = 0, int size = 20});

  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  });

  Future<PlantDetail> fetchPlant({required String plantId});

  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId});

  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
  });

  Future<void> deletePlant({
    required String plantId,
    required String placeCode,
  });
}
