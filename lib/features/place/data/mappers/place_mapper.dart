import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';

List<PlaceSummary> placeSummariesFromResponse(Object? data) {
  final items = jsonListFromResponse(data, context: '장소 목록 조회');

  return [for (final item in items) placeSummaryFromJson(item)];
}

PlaceSummary placeSummaryFromResponse(
  Object? data, {
  required String fallbackId,
}) {
  final object = unwrapJsonObject(data, context: '장소 조회');

  return placeSummaryFromJson(object, fallbackId: fallbackId);
}

PlaceSummary placeSummaryFromJson(JsonMap json, {String? fallbackId}) {
  return PlaceSummary(
    id:
        readOptionalString(json, const [
          'id',
          'placeId',
          'code',
          'placeCode',
        ]) ??
        fallbackId ??
        readRequiredString(json, const ['nanoId'], '장소 ID'),
    name: readRequiredString(json, const ['name', 'placeName'], '장소 이름'),
    address: readOptionalString(json, const ['address', 'placeAddress']),
  );
}
