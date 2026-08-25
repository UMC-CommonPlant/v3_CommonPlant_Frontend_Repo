enum SocialAuthProvider {
  kakao('KAKAO'),
  google('GOOGLE'),
  apple('APPLE');

  const SocialAuthProvider(this.apiValue);

  final String apiValue;
}

class SocialAuthCredential {
  const SocialAuthCredential({required this.provider, required this.token});

  final SocialAuthProvider provider;
  final String token;
}

abstract interface class SocialAuthCredentialGateway {
  Future<SocialAuthCredential> authorize(SocialAuthProvider provider);
}

class SocialAuthNotConfiguredException implements Exception {
  const SocialAuthNotConfiguredException();
}
