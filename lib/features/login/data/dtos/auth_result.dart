import 'package:commonplant_frontend/core/network/api_response_parser.dart';

sealed class AuthResult {
  const AuthResult();
}

class AuthenticatedResult extends AuthResult {
  const AuthenticatedResult({
    required this.accessToken,
    required this.refreshToken,
    this.newUser = false,
  });

  final String accessToken;
  final String refreshToken;
  final bool newUser;
}

class SignupRequiredResult extends AuthResult {
  const SignupRequiredResult({
    required this.signupToken,
    this.newUser = true,
    this.suggestedName,
    this.suggestedImgUrl,
  });

  final String signupToken;
  final bool newUser;
  final String? suggestedName;
  final String? suggestedImgUrl;
}

AuthResult authResultFromJson(JsonMap json) {
  final object = json['isNewUser'] == null && json['newUser'] == null
      ? unwrapJsonObject(json, context: 'Auth')
      : json;
  final isNewUser = object['newUser'] == true || object['isNewUser'] == true;

  if (isNewUser == true || object['signupToken'] != null) {
    return SignupRequiredResult(
      signupToken: readRequiredString(object, const [
        'signupToken',
      ], 'signupToken'),
      newUser: true,
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
    newUser: false,
  );
}
