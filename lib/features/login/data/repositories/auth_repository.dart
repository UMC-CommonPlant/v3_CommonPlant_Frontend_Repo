import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authTokenStoreProvider),
  );
});

class AuthRepository {
  const AuthRepository(this._remoteDataSource, this._tokenStore);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenStore _tokenStore;

  Future<AuthResult> login(LoginRequest request) async {
    final data = await _remoteDataSource.login(request);
    final result = authResultFromJson(
      jsonObjectFromResponse(data, context: '로그인'),
    );

    await _saveIfAuthenticated(result);

    return result;
  }

  Future<AuthResult> register(RegisterRequest request) async {
    final data = await _remoteDataSource.register(request);
    final result = authResultFromJson(
      jsonObjectFromResponse(data, context: '회원가입'),
    );

    await _saveIfAuthenticated(result);

    return result;
  }

  Future<void> _saveIfAuthenticated(AuthResult result) async {
    if (result case AuthenticatedResult(
      :final accessToken,
      :final refreshToken,
    )) {
      await _tokenStore.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }
}
