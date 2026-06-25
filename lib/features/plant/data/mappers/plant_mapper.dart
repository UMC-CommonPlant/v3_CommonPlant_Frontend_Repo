import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';

PlantSummary plantSummaryFromJson(JsonMap json) {
  return PlantSummary(
    id: readRequiredString(json, const ['id', 'plantId'], '식물 ID'),
    name: readRequiredString(json, const ['nickname', 'name'], '식물 이름'),
    placeId: readOptionalString(json, const ['placeId', 'placeCode']),
    placeName: readOptionalString(json, const ['placeName']),
    description: readOptionalString(json, const ['description']),
    imageUrl: readOptionalString(json, const [
      'representativeImageUrl',
      'imageUrl',
    ]),
  );
}

PlantDetail plantDetailFromJson(
  JsonMap json, {
  required String fallbackId,
  String? fallbackPlaceId,
}) {
  return PlantDetail(
    id: readOptionalString(json, const ['id', 'plantId']) ?? fallbackId,
    name: readRequiredString(json, const [
      'nickname',
      'name',
      'scientificNameKo',
      'scientificNameEn',
    ], '식물 이름'),
    placeId:
        readOptionalString(json, const ['placeId', 'placeCode']) ??
        fallbackPlaceId,
    placeName: readOptionalString(json, const ['placeName']),
    species: readOptionalString(json, const [
      'scientificNameEn',
      'scientificNameKo',
      'species',
    ]),
    description: readOptionalString(json, const ['plantInfo', 'description']),
    lastWateredDate: readOptionalString(json, const ['lastWateredDate']),
    imageKey: readOptionalString(json, const ['imageKey']),
    imageUrl: readOptionalString(json, const ['imageUrl']),
    memo: readOptionalString(json, const ['memo']),
    registeredAt: readOptionalString(json, const ['registeredAt']),
  );
}

PlantEditInfo plantEditInfoFromJson(JsonMap json) {
  return PlantEditInfo(
    name: readRequiredString(json, const ['nickname', 'name'], '식물 애칭'),
    lastWateredDate: readOptionalString(json, const ['lastWateredDate']),
    imageKey: readOptionalString(json, const ['imageKey']),
    imageUrl: readOptionalString(json, const ['imageUrl']),
  );
}
