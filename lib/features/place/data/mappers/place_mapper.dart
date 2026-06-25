import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';

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
