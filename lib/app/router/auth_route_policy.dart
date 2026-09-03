import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';

String? authRedirectLocation({
  required AuthSessionState? session,
  required bool isChecking,
  bool hasCompletedOnboarding = true,
  bool isCheckingOnboarding = false,
  required Uri currentUri,
}) {
  if (isCheckingOnboarding) {
    return null;
  }

  final currentPath = currentUri.path;
  if (!hasCompletedOnboarding) {
    if (currentPath == AppRoutePaths.onboarding) {
      return null;
    }

    return AppRoutePaths.onboardingLocation(
      redirect: _preservedRedirect(currentUri),
    );
  }

  if (isChecking) {
    return null;
  }

  final isPublicRoute = currentPath == AppRoutePaths.login;
  final isEntryRoute = isPublicRoute || currentPath == AppRoutePaths.onboarding;
  final isSignupRoute =
      currentPath == AppRoutePaths.profileSetup ||
      currentPath == AppRoutePaths.terms;
  final resolvedSession = session ?? const AuthSessionState.unauthenticated();

  return switch (resolvedSession.status) {
    AuthSessionStatus.unauthenticated =>
      isPublicRoute
          ? null
          : AppRoutePaths.loginLocation(
              redirect: _preservedRedirect(currentUri),
            ),
    AuthSessionStatus.signupRequired =>
      isSignupRoute ? null : AppRoutePaths.profileSetup,
    AuthSessionStatus.authenticated =>
      isEntryRoute || isSignupRoute ? _authenticatedTarget(currentUri) : null,
  };
}

String _authenticatedTarget(Uri currentUri) {
  if (currentUri.path == AppRoutePaths.login ||
      currentUri.path == AppRoutePaths.onboarding) {
    final redirect = _preservedRedirect(currentUri);
    if (redirect != null) {
      return redirect;
    }
  }

  return AppRoutePaths.home;
}

String? _preservedRedirect(Uri currentUri) {
  if (currentUri.path == AppRoutePaths.login ||
      currentUri.path == AppRoutePaths.onboarding) {
    final redirect = currentUri.queryParameters['redirect'];
    return redirect != null && redirect.startsWith('/') ? redirect : null;
  }

  return currentUri.toString();
}
