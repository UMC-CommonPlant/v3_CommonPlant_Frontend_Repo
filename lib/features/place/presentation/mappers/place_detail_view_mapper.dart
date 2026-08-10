import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_view_data.dart';

PlaceDetailViewData? mapPlaceSummaryToDetailViewData({
  required PlaceDetailViewData fallback,
  required PlaceSummary summary,
}) {
  if (summary.name.trim().isEmpty) {
    return null;
  }

  return PlaceDetailViewData(
    role: fallback.role,
    name: summary.name,
    address: summary.address ?? fallback.address,
    sunlightLabel: fallback.sunlightLabel,
    humidityLabel: fallback.humidityLabel,
    friends: fallback.friends,
    plants: fallback.plants,
  );
}
