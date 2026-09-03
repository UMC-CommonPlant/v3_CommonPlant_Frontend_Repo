import 'dart:async';

import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/auth_token_writer.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:commonplant_frontend/features/login/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

class _MemoryAuthTokenStore implements AuthTokenStore {
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
