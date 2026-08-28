import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API 비사용 모드는 기존 화면 흐름을 위해 인증 상태로 시작한다', () async {
    final container = ProviderContainer(
      overrides: [useRemoteApiProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.authenticated);
  });

  test('API 모드는 저장된 access와 refresh token이 모두 있으면 세션을 복원한다', () async {
    final tokenStore = _MemoryAuthTokenStore(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    final container = _remoteContainer(tokenStore);
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.authenticated);
    expect(tokenStore.clearCalls, 0);
    expect(container.read(userDataSessionProvider).isActive, isTrue);
  });

  test('API 모드는 token이 없으면 비인증 상태로 시작한다', () async {
    final container = _remoteContainer(_MemoryAuthTokenStore());
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.unauthenticated);
    expect(container.read(userDataSessionProvider).isActive, isFalse);
  });

  test('불완전한 token 쌍은 삭제하고 비인증 상태로 복구한다', () async {
    final tokenStore = _MemoryAuthTokenStore(accessToken: 'access-token');
    final container = _remoteContainer(tokenStore);
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.status, AuthSessionStatus.unauthenticated);
    expect(tokenStore.clearCalls, 1);
    expect(tokenStore.accessToken, isNull);
  });

  test('신규 사용자 로그인 결과에서 회원가입 진행 정보를 보존한다', () async {
    final container = _remoteContainer(_MemoryAuthTokenStore());
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);

    container
        .read(authSessionControllerProvider.notifier)
        .applyAuthResult(
          const SignupRequiredResult(
            signupToken: 'signup-token',
            suggestedName: '커먼',
            suggestedImgUrl: 'https://example.com/profile.png',
          ),
        );

    final session = container.read(authSessionControllerProvider).requireValue;
    expect(session.status, AuthSessionStatus.signupRequired);
    expect(session.signupToken, 'signup-token');
    expect(session.suggestedName, '커먼');
    expect(session.suggestedImgUrl, 'https://example.com/profile.png');
    expect(container.read(userDataSessionProvider).isActive, isFalse);
  });

  test('인증 상태가 같아도 로그인 결과마다 새로운 데이터 세션을 시작한다', () async {
    final container = _remoteContainer(_MemoryAuthTokenStore());
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);
    final controller = container.read(authSessionControllerProvider.notifier);
    const result = AuthenticatedResult(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    controller.applyAuthResult(result);
    final first = container.read(userDataSessionProvider);
    controller.applyAuthResult(result);
    final second = container.read(userDataSessionProvider);

    expect(second.generation, greaterThan(first.generation));
    expect(second.isActive, isTrue);
    controller.applyAuthResult(
      const SignupRequiredResult(signupToken: 'signup'),
    );
    expect(container.read(userDataSessionProvider).isActive, isFalse);
  });

  test('토큰 삭제가 지연되어도 즉시 세션을 차단하고 늦은 완료가 B를 지우지 않는다', () async {
    final barrier = Completer<void>();
    final store = _MemoryAuthTokenStore(
      accessToken: 'A',
      refreshToken: 'A',
      clearBarrier: barrier,
    );
    final container = _remoteContainer(store);
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);
    final controller = container.read(authSessionControllerProvider.notifier);

    final clearing = controller.clearSession();
    expect(container.read(userDataSessionProvider).isActive, isFalse);
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isUnauthenticated,
      isTrue,
    );
    controller.applyAuthResult(
      const AuthenticatedResult(accessToken: 'B', refreshToken: 'B'),
    );
    final sessionB = container.read(userDataSessionProvider);
    barrier.complete();
    await clearing;

    expect(container.read(userDataSessionProvider), same(sessionB));
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isAuthenticated,
      isTrue,
    );
  });

  test('늦은 시작 토큰 조회 결과는 새 로그인 데이터 세션을 다시 바꾸지 않는다', () async {
    final barrier = Completer<String?>();
    final store = _MemoryAuthTokenStore(
      accessBarrier: barrier,
      refreshToken: 'A',
    );
    final container = _remoteContainer(store);
    addTearDown(container.dispose);
    container.read(authSessionControllerProvider.future).ignore();
    final controller = container.read(authSessionControllerProvider.notifier);
    await controller.clearSession();
    await store.saveTokens(accessToken: 'B', refreshToken: 'B');
    controller.applyAuthResult(
      const AuthenticatedResult(accessToken: 'B', refreshToken: 'B'),
    );
    final sessionB = container.read(userDataSessionProvider);

    barrier.complete('A');
    await container.pump();

    expect(container.read(userDataSessionProvider), same(sessionB));
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isAuthenticated,
      isTrue,
    );
  });

  test('토큰 삭제 오류가 나도 현재 앱의 사용자 데이터 세션은 닫힌다', () async {
    final store = _MemoryAuthTokenStore(
      accessToken: 'A',
      refreshToken: 'A',
      clearError: StateError('storage error'),
    );
    final container = _remoteContainer(store);
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);

    await expectLater(
      container.read(authSessionControllerProvider.notifier).clearSession(),
      throwsStateError,
    );

    expect(container.read(userDataSessionProvider).isActive, isFalse);
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isUnauthenticated,
      isTrue,
    );
    expect(store.accessToken, 'A');
  });
}

ProviderContainer _remoteContainer(AuthTokenStore tokenStore) {
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(tokenStore),
    ],
  );
}

class _MemoryAuthTokenStore implements AuthTokenStore {
  _MemoryAuthTokenStore({
    this.accessToken,
    this.refreshToken,
    this.clearBarrier,
    this.accessBarrier,
    this.clearError,
  });

  String? accessToken;
  String? refreshToken;
  int clearCalls = 0;
  final Completer<void>? clearBarrier;
  final Completer<String?>? accessBarrier;
  final Object? clearError;

  @override
  Future<void> clear() async {
    clearCalls++;
    if (clearError != null) throw clearError!;
    accessToken = null;
    refreshToken = null;
    await clearBarrier?.future;
  }

  @override
  Future<String?> readAccessToken() async =>
      accessBarrier?.future ?? accessToken;

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
