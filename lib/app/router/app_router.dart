import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/auth_route_policy.dart';
import 'package:commonplant_frontend/app/router/redirect_notifier.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
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
    authSessionReader: ref.watch(useRemoteApiProvider)
        ? () => ref.read(authSessionControllerProvider)
        : null,
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

            // API 비사용 화면 확인 모드에는 인증 gate를 적용하지 않는다.
            // 온보딩 완료 뒤에도 로그인 선택과 가입 화면을 확인할 수 있다.
            if (authSessionReader == null &&
                onboardingCompletion?.value == true) {
              return state.uri.path == AppRoutePaths.onboarding
                  ? AppRoutePaths.loginLocation(
                      redirect: state.uri.queryParameters['redirect'],
                    )
                  : null;
            }

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
