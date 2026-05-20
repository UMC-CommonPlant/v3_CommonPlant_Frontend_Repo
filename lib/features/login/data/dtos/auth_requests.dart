class LoginRequest {
  const LoginRequest({required this.provider, required this.token});

  final String provider;
  final String token;

  Map<String, Object?> toJson() {
    return {'provider': provider, 'token': token};
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.signupToken,
    required this.name,
    this.introduction,
    this.imgUrl,
  });

  final String signupToken;
  final String name;
  final String? introduction;
  final String? imgUrl;

  Map<String, Object?> toJson() {
    return {
      'signupToken': signupToken,
      'name': name,
      if (introduction != null) 'introduction': introduction,
      if (imgUrl != null) 'imgUrl': imgUrl,
    };
  }
}
