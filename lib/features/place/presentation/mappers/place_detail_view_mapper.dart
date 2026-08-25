import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_view_data.dart';

PlaceDetailViewData? mapPlaceDetailToViewData(PlaceDetail detail) {
  if (detail.name.trim().isEmpty) {
    return null;
  }

  return PlaceDetailViewData(
    role: detail.isOwner ? PlaceDetailRole.leader : PlaceDetailRole.member,
    name: detail.name,
    address: detail.address,
    friends: [
      for (final (index, member) in detail.members.indexed)
        PlaceDetailFriendItem(
          id: 'member-${index + 1}',
          name: member.name,
          imageUrl: _nonBlank(member.imageUrl),
        ),
    ],
    plants: [for (final plant in detail.plants) _mapPlant(plant)],
  );
}

PlaceDetailPlantItem _mapPlant(PlacePlant plant) {
  final lastWateredDate = _formatDate(plant.lastWateredDate);
  final registeredAt = _formatDate(plant.registeredAt);
  final dateLabel = lastWateredDate ?? registeredAt;
  final dateTypeLabel = lastWateredDate != null
      ? '마지막 물주기'
      : registeredAt != null
      ? '등록일'
      : null;

  return PlaceDetailPlantItem(
    id: plant.id,
    name: plant.scientificNameKo,
    species: _nonBlank(plant.scientificNameEn) ?? plant.scientificNameKo,
    description:
        _nonBlank(plant.description) ?? _nonBlank(plant.memo) ?? '등록된 설명이 없어요',
    dDayLabel: dateTypeLabel,
    dateLabel: dateLabel,
    imageUrl: _nonBlank(plant.imageUrl),
  );
}

String? _formatDate(String? value) {
  final normalized = _nonBlank(value);
  if (normalized == null) {
    return null;
  }

  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) {
    return normalized;
  }

  return '${parsed.year.toString().padLeft(4, '0')}.'
      '${parsed.month.toString().padLeft(2, '0')}.'
      '${parsed.day.toString().padLeft(2, '0')}';
}

String? _nonBlank(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
