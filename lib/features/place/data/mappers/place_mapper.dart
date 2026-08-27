import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';

List<PlaceSummary> placeSummariesFromResponse(Object? data) {
  final response = jsonObjectFromResponse(data, context: '장소 목록 조회');
  final result = response['result'];

  if (result is JsonMap) {
    final placeList = result['placeList'];
    if (placeList is List) {
      return [
        for (final (index, item) in placeList.indexed)
          placeSummaryFromJson(
            _requireJsonMap(item, context: '장소 목록 ${index + 1}번째 항목'),
          ),
      ];
    }
  }

  final items = jsonListFromResponse(data, context: '장소 목록 조회');

  return [for (final item in items) placeSummaryFromJson(item)];
}

String placeCodeFromCreateResponse(Object? data) {
  final response = jsonObjectFromResponse(data, context: '장소 생성');
  final result = response['result'];

  if (result is String && result.trim().isNotEmpty) {
    return result.trim();
  }

  throw const ApiException(message: '장소 생성 응답에 장소 코드가 없습니다.');
}

PlaceSummary updatedPlaceFromResponse(
  Object? data, {
  required String fallbackCode,
}) {
  return placeSummaryFromResponse(data, fallbackId: fallbackCode);
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
    imageUrl: readOptionalString(json, const ['image', 'imgUrl', 'imageUrl']),
    memberCount: readOptionalInt(json, const ['member', 'memberCount']),
    plantCount: readOptionalInt(json, const ['plant', 'plantCount']),
  );
}

PlaceDetail placeDetailFromResponse(
  Object? data, {
  required String fallbackCode,
}) {
  final json = unwrapJsonObject(data, context: '장소 상세 조회');
  final members = _readObjectList(json, key: 'userList', context: '장소 멤버 목록');
  final plants = _readObjectList(json, key: 'plantList', context: '장소 식물 목록');

  return PlaceDetail(
    code: readOptionalString(json, const ['code', 'placeCode']) ?? fallbackCode,
    name: readRequiredString(json, const ['name', 'placeName'], '장소 이름'),
    address: readOptionalString(json, const ['address', 'placeAddress']) ?? '',
    imageUrl: readOptionalString(json, const ['imgUrl', 'imageUrl', 'image']),
    isOwner: readOptionalBool(json, const ['owner', 'isOwner']) ?? false,
    members: [for (final member in members) placeMemberFromJson(member)],
    plants: [for (final plant in plants) placePlantFromJson(plant)],
  );
}

PlaceMember placeMemberFromJson(JsonMap json) {
  return PlaceMember(
    name: readRequiredString(json, const ['name'], '장소 멤버 이름'),
    imageUrl: readOptionalString(json, const ['image', 'imgUrl', 'imageUrl']),
  );
}

List<PlaceMember> placeMembersFromResponse(Object? data) {
  final response = jsonObjectFromResponse(data, context: '장소 멤버 조회');
  final members = response['result'];

  if (members is! List) {
    throw const ApiException(message: '장소 멤버 조회 응답이 목록 형식이 아닙니다.');
  }

  return List.unmodifiable([
    for (final (index, member) in members.indexed)
      placeMemberFromJson(
        _requireJsonMap(member, context: '장소 멤버 ${index + 1}번째 항목'),
      ),
  ]);
}

PlacePlant placePlantFromJson(JsonMap json) {
  return PlacePlant(
    id: readRequiredString(json, const ['plantId', 'id'], '장소 식물 ID'),
    scientificNameKo: readRequiredString(json, const [
      'scientificNameKo',
      'nickname',
      'name',
    ], '장소 식물 이름'),
    scientificNameEn: readOptionalString(json, const ['scientificNameEn']),
    registeredAt: readOptionalString(json, const ['registeredAt']),
    lastWateredDate: readOptionalString(json, const ['lastWateredDate']),
    imageUrl: readOptionalString(json, const ['imageUrl', 'imgUrl']),
    memo: readOptionalString(json, const ['memo']),
    placeName: readOptionalString(json, const ['placeName']),
    description: readOptionalString(json, const ['plantInfo', 'description']),
  );
}

List<JsonMap> _readObjectList(
  JsonMap json, {
  required String key,
  required String context,
}) {
  final value = json[key];

  if (value == null) {
    return const [];
  }

  if (value is! List) {
    throw ApiException(message: '$context 응답이 목록 형식이 아닙니다.');
  }

  return [
    for (final (index, item) in value.indexed)
      _requireJsonMap(item, context: '$context ${index + 1}번째 항목'),
  ];
}

JsonMap _requireJsonMap(Object? value, {required String context}) {
  if (value is JsonMap) {
    return value;
  }

  throw ApiException(message: '$context 응답이 JSON object 형식이 아닙니다.');
}
