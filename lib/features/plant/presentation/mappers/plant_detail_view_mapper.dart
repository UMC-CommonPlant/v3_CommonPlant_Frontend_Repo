import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';

PlantDetailViewData? mapPlantDetailToViewData({
  required PlantDetailViewData fallback,
  required PlantDetail detail,
}) {
  if (detail.name.trim().isEmpty) {
    return null;
  }

  return PlantDetailViewData(
    placeCode: detail.placeId ?? fallback.placeCode,
    placeName: detail.placeName ?? fallback.placeName,
    name: detail.name,
    species: detail.species ?? fallback.species,
    daysTogether: fallback.daysTogether,
    dDayLabel: fallback.dDayLabel,
    startDate: fallback.startDate,
    lastWateredDate: detail.lastWateredDate ?? fallback.lastWateredDate,
    wateringCycleLabel: fallback.wateringCycleLabel,
    memos: fallback.memos,
  );
}
