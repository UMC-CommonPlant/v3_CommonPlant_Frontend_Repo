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
  // 실제 키가 있으면 잘못된 값도 호환 키로 대체하지 않는다.
  final isNewUser = object.containsKey('isNewUser')
      ? object['isNewUser']
      : object['newUser'];

  if (isNewUser is! bool) {
    throw const ApiException(message: '로그인 응답의 isNewUser가 bool이 아닙니다.');
  }

  if (isNewUser) {
    return SignupRequiredResult(
      signupToken: _readAuthToken(object, 'signupToken'),
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
    accessToken: _readAuthToken(object, 'accessToken'),
    refreshToken: _readAuthToken(object, 'refreshToken'),
  );
}

AuthenticatedResult registerAuthResultFromJson(JsonMap json) {
  final object = unwrapJsonObject(json, context: 'Auth register');

  return AuthenticatedResult(
    accessToken: _readAuthToken(object, 'accessToken'),
    refreshToken: _readAuthToken(object, 'refreshToken'),
  );
}

String _readAuthToken(JsonMap object, String key) {
  final value = object[key];
  if (value is! String || value.trim().isEmpty) {
    throw ApiException(message: '인증 응답의 $key가 비어 있거나 문자열이 아닙니다.');
  }
  return value.trim();
}
