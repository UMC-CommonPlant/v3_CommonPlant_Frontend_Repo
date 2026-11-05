import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_controller.dart';
import 'package:commonplant_frontend/features/login/presentation/providers/auth_session_state.dart';
import 'package:dio/dio.dart';
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

  for (final rotated in [false, true]) {
    test('refresh-only 갱신 후 token을 저장하고 세션을 시작한다 (회전 $rotated)', () async {
      final store = _MemoryAuthTokenStore(refreshToken: 'refresh-only');
      final source = _RefreshRemoteDataSource(
        response: {
          'result': {
            'accessToken': 'new-access',
            if (rotated) 'refreshToken': 'rotated-refresh',
          },
        },
      );
      final container = _remoteContainer(store, source: source);
      addTearDown(container.dispose);

      final session = await container.read(
        authSessionControllerProvider.future,
      );

      expect(source.requests.single.refreshToken, 'refresh-only');
      expect(store.accessToken, 'new-access');
      expect(store.refreshToken, rotated ? 'rotated-refresh' : 'refresh-only');
      expect(store.saveCalls, 1);
      expect(store.clearCalls, 0);
      expect(session.isAuthenticated, isTrue);
      expect(container.read(userDataSessionProvider).isActive, isTrue);
    });
  }

  test('refresh 응답과 token 저장이 끝날 때까지 checking과 비활성 데이터를 유지한다', () async {
    final response = Completer<Object?>();
    final saving = Completer<void>();
    final store = _MemoryAuthTokenStore(
      refreshToken: 'refresh-only',
      saveBarrier: saving,
    );
    final source = _RefreshRemoteDataSource(responseBarrier: response);
    final container = _remoteContainer(store, source: source);
    addTearDown(container.dispose);
    final startup = container.read(authSessionControllerProvider.future);
    await source.started.future;
    expect(container.read(authSessionControllerProvider).isLoading, isTrue);
    expect(container.read(userDataSessionProvider).isActive, isFalse);
    expect(store.clearCalls, 0);

    response.complete({
      'result': {'accessToken': 'new-access'},
    });
    await store.saveStarted.future;
    expect(container.read(authSessionControllerProvider).isLoading, isTrue);
    expect(container.read(userDataSessionProvider).isActive, isFalse);
    saving.complete();

    expect((await startup).isAuthenticated, isTrue);
    expect(container.read(userDataSessionProvider).isActive, isTrue);
  });

  for (final error in [
    const ApiException(message: 'expired', statusCode: 401, code: 'A004'),
    const ApiException(message: 'mismatch', statusCode: 401, code: 'A012'),
    const ApiException(message: 'network', kind: ApiFailureKind.network),
  ]) {
    test('refresh 실패는 한 번만 요청하고 token 정리 후 로그인으로 복귀한다 ($error)', () async {
      final store = _MemoryAuthTokenStore(refreshToken: 'refresh-only');
      final source = _RefreshRemoteDataSource(error: error);
      final container = _remoteContainer(store, source: source);
      addTearDown(container.dispose);

      final session = await container.read(
        authSessionControllerProvider.future,
      );

      expect(session.isUnauthenticated, isTrue);
      expect(source.requests, hasLength(1));
      expect(store.clearCalls, 1);
      expect(store.saveCalls, 0);
      expect(store.accessToken, isNull);
      expect(store.refreshToken, isNull);
      expect(container.read(userDataSessionProvider).isActive, isFalse);
    });
  }

  test('잘못된 refresh 응답도 인증하지 않고 부분 token을 삭제한다', () async {
    final store = _MemoryAuthTokenStore(refreshToken: 'refresh-only');
    final container = _remoteContainer(
      store,
      source: _RefreshRemoteDataSource(
        response: {
          'result': {'accessToken': 123},
        },
      ),
    );
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.isUnauthenticated, isTrue);
    expect(store.saveCalls, 0);
    expect(store.clearCalls, 1);
  });

  test('refresh token 저장 실패는 남은 token을 삭제하고 인증하지 않는다', () async {
    final store = _MemoryAuthTokenStore(
      refreshToken: 'refresh-only',
      saveError: StateError('storage error'),
    );
    final container = _remoteContainer(
      store,
      source: _RefreshRemoteDataSource(),
    );
    addTearDown(container.dispose);

    final session = await container.read(authSessionControllerProvider.future);

    expect(session.isUnauthenticated, isTrue);
    expect(store.clearCalls, 1);
    expect(store.accessToken, isNull);
    expect(store.refreshToken, isNull);
    expect(container.read(userDataSessionProvider).isActive, isFalse);
  });

  for (final failure in [false, true]) {
    test('로그아웃 뒤 도착한 refresh 결과는 새 계정 세션을 바꾸지 않는다 (실패 $failure)', () async {
      final response = Completer<Object?>();
      final source = _RefreshRemoteDataSource(responseBarrier: response);
      final store = _MemoryAuthTokenStore(refreshToken: 'A-refresh');
      final container = _remoteContainer(store, source: source);
      addTearDown(container.dispose);
      container.read(authSessionControllerProvider.future).ignore();
      await source.started.future;
      final controller = container.read(authSessionControllerProvider.notifier);
      await controller.clearSession();
      await store.saveTokens(
        accessToken: 'B-access',
        refreshToken: 'B-refresh',
      );
      controller.applyAuthResult(
        const AuthenticatedResult(
          accessToken: 'B-access',
          refreshToken: 'B-refresh',
        ),
      );
      final sessionB = container.read(userDataSessionProvider);

      if (failure) {
        response.completeError(const ApiException(message: 'expired'));
      } else {
        response.complete({
          'result': {'accessToken': 'A-access'},
        });
      }
      await container.pump();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(userDataSessionProvider), same(sessionB));
      expect(
        container
            .read(authSessionControllerProvider)
            .requireValue
            .isAuthenticated,
        isTrue,
      );
      expect(store.accessToken, 'B-access');
      expect(store.refreshToken, 'B-refresh');
      expect(store.saveCalls, 1);
      expect(store.clearCalls, 1);
    });
  }

  test('폐기된 앱 세션의 refresh 응답은 token을 저장하지 않는다', () async {
    final response = Completer<Object?>();
    final source = _RefreshRemoteDataSource(responseBarrier: response);
    final store = _MemoryAuthTokenStore(refreshToken: 'refresh-only');
    final container = _remoteContainer(store, source: source);
    container.read(authSessionControllerProvider.future).ignore();
    await source.started.future;
    container.dispose();

    response.complete({
      'result': {'accessToken': 'new-access'},
    });
    await Future<void>.delayed(Duration.zero);

    expect(store.saveCalls, 0);
    expect(store.clearCalls, 0);
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

  test('인증 만료는 즉시 세션을 닫고 재로그인 안내를 남긴다', () async {
    final barrier = Completer<void>();
    final store = _MemoryAuthTokenStore(
      accessToken: 'A',
      refreshToken: 'A',
      clearBarrier: barrier,
    );
    final container = _remoteContainer(store);
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);
    final sessionA = container.read(userDataSessionProvider);

    final expiring = container
        .read(authSessionControllerProvider.notifier)
        .expireSession(sessionA);

    expect(container.read(userDataSessionProvider).isActive, isFalse);
    final expiredState = container
        .read(authSessionControllerProvider)
        .requireValue;
    expect(expiredState.isUnauthenticated, isTrue);
    expect(expiredState.endReason, AuthSessionEndReason.expired);
    expect(expiredState.noticeMessage, isNotNull);

    container
        .read(authSessionControllerProvider.notifier)
        .applyAuthResult(
          const AuthenticatedResult(accessToken: 'B', refreshToken: 'B'),
        );
    final sessionB = container.read(userDataSessionProvider);
    barrier.complete();
    await expiring;

    expect(container.read(userDataSessionProvider), same(sessionB));
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isAuthenticated,
      isTrue,
    );
  });

  test('이전 계정 세션의 만료 요청은 현재 계정과 저장 토큰을 건드리지 않는다', () async {
    final store = _MemoryAuthTokenStore(accessToken: 'A', refreshToken: 'A');
    final container = _remoteContainer(store);
    addTearDown(container.dispose);
    await container.read(authSessionControllerProvider.future);
    final sessionA = container.read(userDataSessionProvider);
    final controller = container.read(authSessionControllerProvider.notifier);

    controller.applyAuthResult(
      const AuthenticatedResult(accessToken: 'B', refreshToken: 'B'),
    );
    final sessionB = container.read(userDataSessionProvider);
    await controller.expireSession(sessionA);

    expect(container.read(userDataSessionProvider), same(sessionB));
    expect(
      container
          .read(authSessionControllerProvider)
          .requireValue
          .isAuthenticated,
      isTrue,
    );
    expect(store.clearCalls, 0);
  });
}

ProviderContainer _remoteContainer(
  AuthTokenStore tokenStore, {
  AuthRemoteDataSource? source,
}) {
  return ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authTokenStoreProvider.overrideWithValue(tokenStore),
      authRemoteDataSourceProvider.overrideWithValue(
        source ?? _RefreshRemoteDataSource(),
      ),
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
    this.saveBarrier,
    this.saveError,
  });

  String? accessToken;
  String? refreshToken;
  int clearCalls = 0;
  int saveCalls = 0;
  final saveStarted = Completer<void>();
  final Completer<void>? saveBarrier;
  final Object? saveError;
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
    saveCalls++;
    if (!saveStarted.isCompleted) saveStarted.complete();
    await saveBarrier?.future;
    this.accessToken = accessToken;
    if (saveError != null) throw saveError!;
    this.refreshToken = refreshToken;
  }
}

class _RefreshRemoteDataSource extends AuthRemoteDataSource {
  _RefreshRemoteDataSource({
    this.response = const {
      'result': {'accessToken': 'new-access'},
    },
    this.responseBarrier,
    this.error,
  }) : super(Dio());

  final Object? response;
  final Completer<Object?>? responseBarrier;
  final Object? error;
  final started = Completer<void>();
  final requests = <RefreshRequest>[];

  @override
  Future<Object?> refresh(RefreshRequest request) async {
    requests.add(request);
    if (!started.isCompleted) started.complete();
    if (error != null) throw error!;
    return responseBarrier?.future ?? response;
  }
}
