import 'dart:async';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/auth_token_writer.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository.refresh', () {
    for (final rotated in [false, true]) {
      test('갱신 성공 시 ${rotated ? '회전한' : '기존'} refreshToken을 저장한다', () async {
        final dataSource = _RefreshAuthRemoteDataSource(
          result: {
            'result': {
              'accessToken': 'renewed-access',
              if (rotated) 'refreshToken': 'rotated-refresh',
            },
          },
        );
        final store = _MemoryAuthTokenStore();
        final repository = AuthRepository(dataSource, AuthTokenWriter(store));

        final result = await repository.refresh(
          const RefreshRequest(refreshToken: 'existing-refresh'),
        );

        expect(dataSource.latestRequest?.refreshToken, 'existing-refresh');
        expect(result.accessToken, 'renewed-access');
        expect(
          result.refreshToken,
          rotated ? 'rotated-refresh' : 'existing-refresh',
        );
        expect(store.accessToken, result.accessToken);
        expect(store.refreshToken, result.refreshToken);
        expect(store.saveCalls, 1);
        expect(store.clearCalls, 0);
      });
    }

    for (final invalid in <Object?>[
      [],
      '"invalid-response"',
      {},
      {'accessToken': ' '},
      {'accessToken': 'new-access', 'refreshToken': false},
    ]) {
      test('잘못된 갱신 응답 $invalid 값은 저장하지 않고 이전 토큰을 지운다', () async {
        final store = _MemoryAuthTokenStore()
          ..accessToken = 'old-access'
          ..refreshToken = 'old-refresh';
        final repository = AuthRepository(
          _RefreshAuthRemoteDataSource(result: invalid),
          AuthTokenWriter(store),
        );

        await expectLater(
          repository.refresh(const RefreshRequest(refreshToken: 'old-refresh')),
          throwsA(isA<ApiException>()),
        );

        expect(store.saveCalls, 0);
        expect(store.clearCalls, 1);
        expect(store.accessToken, isNull);
        expect(store.refreshToken, isNull);
      });
    }

    test('갱신 HTTP 실패는 이전 토큰 정리 후 원래 오류를 전달한다', () async {
      const error = ApiException(message: 'refresh rejected', statusCode: 401);
      final store = _MemoryAuthTokenStore()
        ..accessToken = 'old-access'
        ..refreshToken = 'old-refresh';
      final repository = AuthRepository(
        _RefreshAuthRemoteDataSource(error: error),
        AuthTokenWriter(store),
      );

      await expectLater(
        repository.refresh(const RefreshRequest(refreshToken: 'old-refresh')),
        throwsA(same(error)),
      );

      expect(store.saveCalls, 0);
      expect(store.clearCalls, 1);
      expect(store.accessToken, isNull);
      expect(store.refreshToken, isNull);
    });

    test('갱신 token 저장 도중 실패해도 부분 저장 토큰을 정리한다', () async {
      final store = _FailingTokenStore()..refreshToken = 'old-refresh';
      final repository = AuthRepository(
        _RefreshAuthRemoteDataSource(),
        AuthTokenWriter(store),
      );

      await expectLater(
        repository.refresh(const RefreshRequest(refreshToken: 'old-refresh')),
        throwsA(isA<StateError>()),
      );

      expect(store.clearCalls, 1);
      expect(store.accessToken, isNull);
      expect(store.refreshToken, isNull);
    });

    test('로그아웃 뒤 늦게 도착한 갱신 응답은 토큰을 되살리지 않는다', () async {
      final response = Completer<Object?>();
      final dataSource = _RefreshAuthRemoteDataSource(response: response);
      final store = _MemoryAuthTokenStore();
      final writer = AuthTokenWriter(store);
      final repository = AuthRepository(dataSource, writer);
      final refreshing = repository
          .refresh(const RefreshRequest(refreshToken: 'old-refresh'))
          .then<Object>((result) => result, onError: (Object error) => error);
      await dataSource.started.future;

      await writer.clear();
      response.complete({'accessToken': 'renewed-access'});

      expect(await refreshing, isA<StateError>());
      expect(store.saveCalls, 0);
      expect(store.clearCalls, 1);
      expect(store.accessToken, isNull);
      expect(store.refreshToken, isNull);
    });

    for (final fails in [false, true]) {
      test('새 로그인 뒤 늦은 갱신 ${fails ? '실패' : '성공'}는 새 토큰을 지우지 않는다', () async {
        final response = Completer<Object?>();
        final dataSource = _RefreshAuthRemoteDataSource(response: response);
        final store = _MemoryAuthTokenStore();
        final repository = AuthRepository(dataSource, AuthTokenWriter(store));
        final refreshing = repository
            .refresh(const RefreshRequest(refreshToken: 'old-refresh'))
            .then<Object>((result) => result, onError: (Object error) => error);
        await dataSource.started.future;

        await repository.login(
          const LoginRequest(provider: 'KAKAO', token: 'B'),
        );
        if (fails) {
          response.completeError(const ApiException(message: 'late failure'));
        } else {
          response.complete({'accessToken': 'renewed-access'});
        }

        expect(await refreshing, isA<StateError>());
        expect(store.clearCalls, 0);
        expect(store.accessToken, 'B-access');
        expect(store.refreshToken, 'B-refresh');
      });
    }

    for (final logsOut in [false, true]) {
      test('갱신 저장 중 ${logsOut ? '로그아웃' : '새 로그인'}이 시작되면 늦은 저장을 정리한다', () async {
        final store = _DelayedTokenStore();
        final writer = AuthTokenWriter(store);
        final repository = AuthRepository(
          _RefreshAuthRemoteDataSource(),
          writer,
        );
        final refreshing = repository
            .refresh(const RefreshRequest(refreshToken: 'old-refresh'))
            .then<Object>((result) => result, onError: (Object error) => error);
        await store.saveStarted.future;

        final next = logsOut
            ? writer.clear()
            : repository.login(
                const LoginRequest(provider: 'KAKAO', token: 'B'),
              );
        store.saveBarrier.complete();
        await next;

        expect(await refreshing, isA<StateError>());
        expect(store.accessToken, logsOut ? null : 'B-access');
        expect(store.refreshToken, logsOut ? null : 'B-refresh');
        expect(store.clearCalls, logsOut ? 1 : 0);
      });
    }

    test('갱신 실패의 느린 토큰 삭제 뒤 시작한 새 로그인 저장을 보존한다', () async {
      final store = _DelayedClearTokenStore()
        ..accessToken = 'old-access'
        ..refreshToken = 'old-refresh';
      final repository = AuthRepository(
        _RefreshAuthRemoteDataSource(
          error: const ApiException(message: 'failure'),
        ),
        AuthTokenWriter(store),
      );
      final refreshing = repository
          .refresh(const RefreshRequest(refreshToken: 'old-refresh'))
          .then<Object>((result) => result, onError: (Object error) => error);
      await store.clearStarted.future;

      final login = repository.login(
        const LoginRequest(provider: 'KAKAO', token: 'B'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(store.saveCalls, 0);
      store.clearBarrier.complete();
      expect(await refreshing, isA<ApiException>());
      await login;

      expect(store.clearCalls, 1);
      expect(store.accessToken, 'B-access');
      expect(store.refreshToken, 'B-refresh');
    });
  });

  test('A의 토큰 저장이 늦어도 나중에 시작한 B의 토큰을 보존한다', () async {
    final tokenStore = _DelayedTokenStore();
    final repository = AuthRepository(
      _LoginAuthRemoteDataSource(),
      AuthTokenWriter(tokenStore),
    );
    final loginA = repository
        .login(const LoginRequest(provider: 'KAKAO', token: 'A'))
        .then<Object>((result) => result, onError: (Object error) => error);
    await tokenStore.saveStarted.future;

    final loginB = repository.login(
      const LoginRequest(provider: 'KAKAO', token: 'B'),
    );
    await Future<void>.delayed(Duration.zero);
    tokenStore.saveBarrier.complete();
    await loginB;

    expect(tokenStore.accessToken, 'B-access');
    expect(tokenStore.refreshToken, 'B-refresh');
    expect(await loginA, isA<StateError>());
  });

  test('로그아웃 전에 시작된 저장이 끝나도 토큰을 되살리지 않는다', () async {
    final tokenStore = _DelayedTokenStore();
    final writer = AuthTokenWriter(tokenStore);
    final repository = AuthRepository(_LoginAuthRemoteDataSource(), writer);
    final loginA = repository
        .login(const LoginRequest(provider: 'KAKAO', token: 'A'))
        .then<Object>((result) => result, onError: (Object error) => error);
    await tokenStore.saveStarted.future;

    final clearing = writer.clear();
    await Future<void>.delayed(Duration.zero);
    tokenStore.saveBarrier.complete();
    await clearing;
    final resultA = await loginA;

    expect(tokenStore.accessToken, isNull);
    expect(tokenStore.refreshToken, isNull);
    expect(resultA, isA<StateError>());
  });

  group('AuthRepository.register', () {
    test('선택한 image를 전달하고 성공 응답 token을 저장한다', () async {
      final dataSource = _RegisterAuthRemoteDataSource();
      final tokenStore = _MemoryAuthTokenStore();
      final repository = AuthRepository(
        dataSource,
        AuthTokenWriter(tokenStore),
      );
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'profile.png',
      );

      final result = await repository.register(
        const RegisterRequest(signupToken: 'signup-token', name: '커먼'),
        image: image,
      );

      expect(dataSource.latestImage, same(image));
      expect(result, isA<AuthenticatedResult>());
      expect(tokenStore.accessToken, 'access-token');
      expect(tokenStore.refreshToken, 'refresh-token');
    });
  });
}

class _LoginAuthRemoteDataSource extends AuthRemoteDataSource {
  _LoginAuthRemoteDataSource() : super(Dio());

  @override
  Future<Object?> login(LoginRequest request) async => {
    'result': {
      'accessToken': '${request.token}-access',
      'refreshToken': '${request.token}-refresh',
      'isNewUser': false,
    },
  };
}

class _DelayedTokenStore extends _MemoryAuthTokenStore {
  final saveStarted = Completer<void>();
  final saveBarrier = Completer<void>();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken == 'A-access') {
      saveStarted.complete();
      await saveBarrier.future;
    }
    await super.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

class _RegisterAuthRemoteDataSource extends AuthRemoteDataSource {
  _RegisterAuthRemoteDataSource() : super(Dio());

  MultipartFile? latestImage;

  @override
  Future<Object?> register(
    RegisterRequest request, {
    MultipartFile? image,
  }) async {
    latestImage = image;

    return {
      'result': {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'isNewUser': true,
      },
    };
  }
}

class _RefreshAuthRemoteDataSource extends _LoginAuthRemoteDataSource {
  _RefreshAuthRemoteDataSource({
    this.result = const {
      'accessToken': 'A-access',
      'refreshToken': 'A-refresh',
    },
    this.error,
    this.response,
  });

  final Object? result;
  final Object? error;
  final Completer<Object?>? response;
  final started = Completer<void>();
  RefreshRequest? latestRequest;

  @override
  Future<Object?> refresh(RefreshRequest request) async {
    latestRequest = request;
    started.complete();
    if (error != null) throw error!;
    return response?.future ?? result;
  }
}

class _FailingTokenStore extends _MemoryAuthTokenStore {
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    throw StateError('token storage failure');
  }
}

class _DelayedClearTokenStore extends _MemoryAuthTokenStore {
  final clearStarted = Completer<void>();
  final clearBarrier = Completer<void>();

  @override
  Future<void> clear() async {
    clearStarted.complete();
    await clearBarrier.future;
    await super.clear();
  }
}

class _MemoryAuthTokenStore implements AuthTokenStore {
  String? accessToken;
  String? refreshToken;
  int saveCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls++;
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
    saveCalls++;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
