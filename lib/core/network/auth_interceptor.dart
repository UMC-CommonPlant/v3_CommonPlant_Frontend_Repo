import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._tokenStore);

  final AuthTokenStore _tokenStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStore.readAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
