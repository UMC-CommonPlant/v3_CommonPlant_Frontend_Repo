enum AuthSessionStatus { unauthenticated, signupRequired, authenticated }

class AuthSessionState {
  const AuthSessionState._({
    required this.status,
    this.signupToken,
    this.suggestedName,
    this.suggestedImgUrl,
  });

  const AuthSessionState.unauthenticated()
    : this._(status: AuthSessionStatus.unauthenticated);

  const AuthSessionState.signupRequired({
    required String signupToken,
    String? suggestedName,
    String? suggestedImgUrl,
  }) : this._(
         status: AuthSessionStatus.signupRequired,
         signupToken: signupToken,
         suggestedName: suggestedName,
         suggestedImgUrl: suggestedImgUrl,
       );

  const AuthSessionState.authenticated()
    : this._(status: AuthSessionStatus.authenticated);

  final AuthSessionStatus status;
  final String? signupToken;
  final String? suggestedName;
  final String? suggestedImgUrl;

  bool get isUnauthenticated => status == AuthSessionStatus.unauthenticated;

  bool get isSignupRequired => status == AuthSessionStatus.signupRequired;

  bool get isAuthenticated => status == AuthSessionStatus.authenticated;
}
