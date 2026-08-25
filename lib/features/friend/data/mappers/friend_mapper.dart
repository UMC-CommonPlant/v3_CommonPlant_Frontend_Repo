import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/friend/domain/entities/friend_invitation.dart';

List<FriendInvitation> friendInvitationsFromResponse(Object? data) {
  final response = jsonObjectFromResponse(data, context: '친구 요청 목록 조회');
  final result = response['result'];

  if (result is! JsonMap) {
    throw const ApiException(message: '친구 요청 목록 result가 응답에 없습니다.');
  }

  final requests = result['requests'];

  if (requests is! List) {
    throw const ApiException(message: '친구 요청 목록이 목록 형식이 아닙니다.');
  }

  return [
    for (final (index, request) in requests.indexed)
      friendInvitationFromJson(
        _requireJsonMap(request, context: '친구 요청 ${index + 1}번째 항목'),
      ),
  ];
}

FriendInvitation friendInvitationFromJson(JsonMap json) {
  final id = readOptionalInt(json, const ['friendId']);

  if (id == null) {
    throw const ApiException(message: '친구 요청 ID 필드가 응답에 없습니다: friendId');
  }

  return FriendInvitation(
    id: id,
    senderName: readRequiredString(json, const ['senderName'], '친구 요청 발신자 이름'),
    senderImageUrl: readOptionalString(json, const ['senderImgUrl']),
    placeCode: readRequiredString(json, const ['placeCode'], '친구 요청 장소 코드'),
    placeName: readRequiredString(json, const ['placeName'], '친구 요청 장소 이름'),
    placeAddress: readRequiredString(json, const [
      'placeAddress',
    ], '친구 요청 장소 주소'),
    status: readRequiredString(json, const ['status'], '친구 요청 상태'),
  );
}

JsonMap _requireJsonMap(Object? value, {required String context}) {
  if (value is JsonMap) {
    return value;
  }

  throw ApiException(message: '$context 응답이 JSON object 형식이 아닙니다.');
}
