import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/auth_route_policy.dart';
import 'package:commonplant_frontend/app/router/redirect_notifier.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef AuthSessionReader = AsyncValue<AuthSessionState> Function();
typedef OnboardingCompletionReader = AsyncValue<bool> Function();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authSessionControllerProvider, (previous, next) {
    refreshNotifier.refresh();
  });
  ref.listen(onboardingControllerProvider, (previous, next) {
    refreshNotifier.refresh();
  });

  final router = createAppRouter(
    authSessionReader: () => ref.read(authSessionControllerProvider),
    onboardingCompletionReader: () => ref.read(onboardingControllerProvider),
    refreshListenable: refreshNotifier,
  );
  ref.onDispose(router.dispose);

  return router;
});

GoRouter createAppRouter({
  String initialLocation = AppRoutePaths.home,
  AuthSessionReader? authSessionReader,
  OnboardingCompletionReader? onboardingCompletionReader,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: buildAppRoutes(),
    refreshListenable: refreshListenable,
    redirect: authSessionReader == null && onboardingCompletionReader == null
        ? null
        : (context, state) {
            final authSession = authSessionReader?.call();
            final onboardingCompletion = onboardingCompletionReader?.call();

            return authRedirectLocation(
              session: authSession?.value,
              isChecking: authSession?.isLoading ?? false,
              hasCompletedOnboarding:
                  onboardingCompletionReader == null ||
                  onboardingCompletion?.value == true,
              isCheckingOnboarding: onboardingCompletion?.isLoading ?? false,
              currentUri: state.uri,
            );
          },
  );
}
