import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/core/network/auth_token_writer.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authTokenWriterProvider),
  );
});

class AuthRepository {
  const AuthRepository(this._remoteDataSource, this._tokenWriter);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenWriter _tokenWriter;

  Future<AuthResult> login(LoginRequest request) async {
    final attempt = _tokenWriter.beginAttempt();
    final data = await _remoteDataSource.login(request);
    final result = loginAuthResultFromJson(
      jsonObjectFromResponse(data, context: '로그인'),
    );

    await _saveIfAuthenticated(result, attempt);
    _tokenWriter.checkCurrentAttempt(attempt);

    return result;
  }

  Future<AuthenticatedResult> refresh(RefreshRequest request) async {
    final attempt = _tokenWriter.beginAttempt();
    try {
      final data = await _remoteDataSource.refresh(request);
      final result = refreshAuthResultFromJson(
        jsonObjectFromResponse(data, context: '인증 갱신'),
        existingRefreshToken: request.refreshToken,
      );

      await _saveIfAuthenticated(result, attempt);
      _tokenWriter.checkCurrentAttempt(attempt);

      return result;
    } catch (_) {
      // 새 로그인·로그아웃이 시작됐다면 그 시도의 토큰을 지우지 않는다.
      _tokenWriter.checkCurrentAttempt(attempt);
      await _tokenWriter.clear();
      rethrow;
    }
  }

  Future<AuthResult> register(
    RegisterRequest request, {
    MultipartFile? image,
  }) async {
    final attempt = _tokenWriter.beginAttempt();
    final data = await _remoteDataSource.register(request, image: image);
    final result = registerAuthResultFromJson(
      jsonObjectFromResponse(data, context: '회원가입'),
    );

    await _saveIfAuthenticated(result, attempt);
    _tokenWriter.checkCurrentAttempt(attempt);

    return result;
  }

  Future<void> _saveIfAuthenticated(AuthResult result, int attempt) async {
    _tokenWriter.checkCurrentAttempt(attempt);
    if (result case AuthenticatedResult(
      :final accessToken,
      :final refreshToken,
    )) {
      await _tokenWriter.saveTokens(
        attempt: attempt,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }
}
