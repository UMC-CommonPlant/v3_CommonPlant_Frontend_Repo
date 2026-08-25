import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';

PlantDetailViewData? mapPlantDetailToViewData({
  required PlantDetail detail,
  required String? placeCode,
  required DateTime now,
}) {
  if (detail.name.trim().isEmpty) {
    return null;
  }

  final registeredDate = _parseApiCalendarDate(detail.registeredAt);
  final today = DateTime.utc(now.year, now.month, now.day);
  final daysTogether = registeredDate == null || registeredDate.isAfter(today)
      ? null
      : today.difference(registeredDate).inDays + 1;

  return PlantDetailViewData(
    placeCode: _nonBlank(detail.placeId) ?? placeCode,
    placeName: _nonBlank(detail.placeName) ?? '장소 정보 없음',
    name: detail.name.trim(),
    species: _nonBlank(detail.species) ?? '학명 정보 없음',
    imageUrl: _nonBlank(detail.imageUrl),
    imageAsset: null,
    daysTogether: daysTogether,
    dDayLabel: null,
    startDate: registeredDate == null ? null : _formatDate(registeredDate),
    lastWateredDate: _formatApiDate(detail.lastWateredDate),
    wateringCycleLabel: null,
    representativeMemo: _nonBlank(detail.memo),
    plantInfo: _nonBlank(detail.description),
    memos: const [],
    supportsMemoActions: false,
  );
}

String? _nonBlank(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _formatApiDate(String? value) {
  final date = _parseApiCalendarDate(value);
  return date == null ? null : _formatDate(date);
}

DateTime? _parseApiCalendarDate(String? value) {
  final normalized = _nonBlank(value);
  if (normalized == null) {
    return null;
  }

  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(normalized);
  if (match == null) {
    return null;
  }

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);

  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }

  return date;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}
