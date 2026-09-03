import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';

sealed class AuthResult {
  const AuthResult();
}

class AuthenticatedResult extends AuthResult {
  const AuthenticatedResult({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

class SignupRequiredResult extends AuthResult {
  const SignupRequiredResult({
    required this.signupToken,
    this.suggestedName,
    this.suggestedImgUrl,
  });

  final String signupToken;
  final String? suggestedName;
  final String? suggestedImgUrl;
}

AuthResult loginAuthResultFromJson(JsonMap json) {
  final object = json['isNewUser'] == null && json['newUser'] == null
      ? unwrapJsonObject(json, context: 'Auth')
      : json;
  final isNewUser = readOptionalBool(object, const ['isNewUser', 'newUser']);

  if (isNewUser == null) {
    throw const ApiException(message: '로그인 응답에 isNewUser 필드가 없습니다.');
  }

  if (isNewUser) {
    return SignupRequiredResult(
      signupToken: readRequiredString(object, const [
        'signupToken',
      ], 'signupToken'),
      suggestedName: readOptionalString(object, const [
        'suggestedName',
        'name',
      ]),
      suggestedImgUrl: readOptionalString(object, const [
        'suggestedImgUrl',
        'imgUrl',
        'imageUrl',
      ]),
    );
  }

  return AuthenticatedResult(
    accessToken: readRequiredString(object, const [
      'accessToken',
    ], 'accessToken'),
    refreshToken: readRequiredString(object, const [
      'refreshToken',
    ], 'refreshToken'),
  );
}

AuthenticatedResult registerAuthResultFromJson(JsonMap json) {
  final object = unwrapJsonObject(json, context: 'Auth register');

  return AuthenticatedResult(
    accessToken: readRequiredString(object, const [
      'accessToken',
    ], 'accessToken'),
    refreshToken: readRequiredString(object, const [
      'refreshToken',
    ], 'refreshToken'),
  );
}
