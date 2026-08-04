import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_summary.dart';

List<PlantSummary> plantSummariesFromResponse(Object? data) {
  final items = jsonListFromResponse(data, context: '식물 목록 조회');

  return [for (final item in items) plantSummaryFromJson(item)];
}

PlantDetail plantDetailFromResponse(
  Object? data, {
  required String fallbackId,
}) {
  final object = unwrapJsonObject(data, context: '식물 상세 조회');

  return plantDetailFromJson(object, fallbackId: fallbackId);
}

PlantEditInfo plantEditInfoFromResponse(Object? data) {
  final object = unwrapJsonObject(data, context: '식물 수정 정보 조회');

  return plantEditInfoFromJson(object);
}

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
