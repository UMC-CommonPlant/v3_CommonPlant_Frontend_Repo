import 'package:commonplant_frontend/core/network/api_exception.dart';

enum AuthSessionStatus { unauthenticated, signupRequired, authenticated }

enum AuthSessionEndReason { expired }

class AuthSessionState {
  const AuthSessionState._({
    required this.status,
    this.signupToken,
    this.suggestedName,
    this.suggestedImgUrl,
    this.endReason,
  });

  const AuthSessionState.unauthenticated({AuthSessionEndReason? reason})
    : this._(status: AuthSessionStatus.unauthenticated, endReason: reason);

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
  final AuthSessionEndReason? endReason;

  bool get isUnauthenticated => status == AuthSessionStatus.unauthenticated;

  bool get isSignupRequired => status == AuthSessionStatus.signupRequired;

  bool get isAuthenticated => status == AuthSessionStatus.authenticated;

  String? get noticeMessage => switch (endReason) {
    AuthSessionEndReason.expired => sessionExpiredMessage,
    null => null,
  };
}
