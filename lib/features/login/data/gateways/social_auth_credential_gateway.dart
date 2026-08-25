import 'package:commonplant_frontend/features/login/domain/models/social_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialAuthCredentialGatewayProvider =
    Provider<SocialAuthCredentialGateway>(
      (ref) => const UnconfiguredSocialAuthCredentialGateway(),
    );

class UnconfiguredSocialAuthCredentialGateway
    implements SocialAuthCredentialGateway {
  const UnconfiguredSocialAuthCredentialGateway();

  @override
  Future<SocialAuthCredential> authorize(SocialAuthProvider provider) {
    throw const SocialAuthNotConfiguredException();
  }
}
