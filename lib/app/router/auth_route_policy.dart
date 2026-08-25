import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';

String? authRedirectLocation({
  required AuthSessionState? session,
  required bool isChecking,
  required Uri currentUri,
}) {
  if (isChecking) {
    return null;
  }

  final currentPath = currentUri.path;
  final isPublicRoute =
      currentPath == AppRoutePaths.onboarding ||
      currentPath == AppRoutePaths.login;
  final isSignupRoute =
      currentPath == AppRoutePaths.profileSetup ||
      currentPath == AppRoutePaths.terms;
  final resolvedSession = session ?? const AuthSessionState.unauthenticated();

  return switch (resolvedSession.status) {
    AuthSessionStatus.unauthenticated =>
      isPublicRoute
          ? null
          : AppRoutePaths.loginLocation(redirect: currentUri.toString()),
    AuthSessionStatus.signupRequired =>
      isSignupRoute ? null : AppRoutePaths.profileSetup,
    AuthSessionStatus.authenticated =>
      isPublicRoute || isSignupRoute ? _authenticatedTarget(currentUri) : null,
  };
}

String _authenticatedTarget(Uri currentUri) {
  if (currentUri.path == AppRoutePaths.login) {
    final redirect = currentUri.queryParameters['redirect'];
    if (redirect != null && redirect.startsWith('/')) {
      return redirect;
    }
  }

  return AppRoutePaths.home;
}
