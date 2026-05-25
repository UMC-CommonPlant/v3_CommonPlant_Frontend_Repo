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

AuthResult authResultFromJson(JsonMap json) {
  final object = json['isNewUser'] == null
      ? unwrapJsonObject(json, context: 'Auth')
      : json;
  final isNewUser = object['isNewUser'];

  if (isNewUser == true || object['signupToken'] != null) {
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
