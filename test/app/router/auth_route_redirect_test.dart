import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('실제 앱 router는 API 모드의 빈 세션을 로그인으로 보낸다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          authTokenStoreProvider.overrideWithValue(_EmptyAuthTokenStore()),
          onboardingLocalStoreProvider.overrideWithValue(
            TestOnboardingLocalStore(completed: true),
          ),
        ],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text('My place'), findsNothing);
  });

  testWidgets('온보딩 완료 값이 없으면 인증 확인보다 온보딩을 먼저 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          authTokenStoreProvider.overrideWithValue(_EmptyAuthTokenStore()),
          onboardingLocalStoreProvider.overrideWithValue(
            TestOnboardingLocalStore(),
          ),
        ],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식물을 내 공간으로,\n공간은 내 폰으로'), findsOneWidget);
    expect(find.text('카카오로 로그인'), findsNothing);
  });

  testWidgets('비인증 사용자는 보호 route에서 로그인으로 이동한다', (tester) async {
    final authSession = ValueNotifier<AsyncValue<AuthSessionState>>(
      const AsyncData(AuthSessionState.unauthenticated()),
    );
    addTearDown(authSession.dispose);
    final router = _routerWithAuth(authSession);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['redirect'],
      AppRoutePaths.home,
    );
  });

  testWidgets('회원가입 필요 사용자는 프로필 설정으로 이동한다', (tester) async {
    final authSession = ValueNotifier<AsyncValue<AuthSessionState>>(
      const AsyncData(
        AuthSessionState.signupRequired(signupToken: 'signup-token'),
      ),
    );
    addTearDown(authSession.dispose);
    final router = _routerWithAuth(authSession);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutePaths.profileSetup,
    );
  });

  testWidgets('인증 사용자는 로그인 route의 보존 위치로 복귀한다', (tester) async {
    final authSession = ValueNotifier<AsyncValue<AuthSessionState>>(
      const AsyncData(AuthSessionState.authenticated()),
    );
    addTearDown(authSession.dispose);
    final router = createAppRouter(
      initialLocation: AppRoutePaths.loginLocation(
        redirect: AppRoutePaths.placeCreate,
      ),
      authSessionReader: () => authSession.value,
      refreshListenable: authSession,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutePaths.placeCreate,
    );
  });

  testWidgets('인증 사용자는 온보딩 route의 보존 위치로 복귀한다', (tester) async {
    final authSession = ValueNotifier<AsyncValue<AuthSessionState>>(
      const AsyncData(AuthSessionState.authenticated()),
    );
    addTearDown(authSession.dispose);
    final router = createAppRouter(
      initialLocation: AppRoutePaths.onboardingLocation(
        redirect: AppRoutePaths.placeCreate,
      ),
      authSessionReader: () => authSession.value,
      onboardingCompletionReader: () => const AsyncData(true),
      refreshListenable: authSession,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutePaths.placeCreate,
    );
  });

  testWidgets('최초 보호 route는 온보딩과 로그인을 지나도록 위치를 보존한다', (tester) async {
    final authSession = ValueNotifier<AsyncValue<AuthSessionState>>(
      const AsyncData(AuthSessionState.unauthenticated()),
    );
    final onboardingCompletion = ValueNotifier<AsyncValue<bool>>(
      const AsyncData(false),
    );
    addTearDown(authSession.dispose);
    addTearDown(onboardingCompletion.dispose);
    final router = createAppRouter(
      initialLocation: AppRoutePaths.placeCreate,
      authSessionReader: () => authSession.value,
      onboardingCompletionReader: () => onboardingCompletion.value,
      refreshListenable: Listenable.merge([authSession, onboardingCompletion]),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutePaths.onboarding,
    );
    expect(
      router.routeInformationProvider.value.uri.queryParameters['redirect'],
      AppRoutePaths.placeCreate,
    );

    onboardingCompletion.value = const AsyncData(true);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutePaths.login);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['redirect'],
      AppRoutePaths.placeCreate,
    );
  });

  testWidgets('세션 확인 완료 시 router가 인증 상태를 다시 평가한다', (tester) async {
    final authSession = ValueNotifier<AsyncValue<AuthSessionState>>(
      const AsyncLoading(),
    );
    addTearDown(authSession.dispose);
    final router = _routerWithAuth(authSession);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routerApp(router));
    await tester.pump();
    expect(find.text('My place'), findsOneWidget);

    authSession.value = const AsyncData(AuthSessionState.unauthenticated());
    await tester.pumpAndSettle();

    expect(find.text('카카오로 로그인'), findsOneWidget);
  });

  testWidgets('활성 화면의 인증이 만료되면 로그인으로 이동하고 이유를 안내한다', (tester) async {
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(true),
        authTokenStoreProvider.overrideWithValue(
          _MemoryAuthTokenStore(accessToken: 'access', refreshToken: 'refresh'),
        ),
        onboardingLocalStoreProvider.overrideWithValue(
          TestOnboardingLocalStore(completed: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);
    final activeSession = container.read(userDataSessionProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      AppRoutePaths.home,
    );
    expect(find.text('카카오로 로그인'), findsNothing);

    await container
        .read(authSessionControllerProvider.notifier)
        .expireSession(activeSession);
    await tester.pumpAndSettle();

    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text(sessionExpiredMessage), findsOneWidget);
    expect(find.text('My place'), findsNothing);
  });
}

GoRouter _routerWithAuth(
  ValueNotifier<AsyncValue<AuthSessionState>> authSession,
) {
  return createAppRouter(
    authSessionReader: () => authSession.value,
    refreshListenable: authSession,
  );
}

Widget _routerApp(GoRouter router) {
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

class _EmptyAuthTokenStore implements AuthTokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class _MemoryAuthTokenStore implements AuthTokenStore {
  _MemoryAuthTokenStore({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
