import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';

UserProfile userProfileFromJson(JsonMap json) {
  return UserProfile(
    id: readRequiredString(json, const ['id', 'userId', 'nanoId'], '사용자 ID'),
    name: readRequiredString(json, const ['name'], '사용자 이름'),
    email: readOptionalString(json, const ['email']),
    provider: readOptionalString(json, const ['provider']),
    imgUrl: readOptionalString(json, const ['imgUrl', 'imageUrl']),
    introduction: readOptionalString(json, const ['introduction']),
  );
}
