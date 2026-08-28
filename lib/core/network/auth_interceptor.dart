import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  const AuthInterceptor(
    this._tokenStore, {
    required this.isCurrentSession,
    required this.attachAccessToken,
  });

  final AuthTokenStore _tokenStore;
  final bool Function() isCurrentSession;
  final bool attachAccessToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!isCurrentSession()) {
      handler.reject(_sessionChanged(options));
      return;
    }

    try {
      final accessToken = attachAccessToken
          ? await _tokenStore.readAccessToken()
          : null;
      if (!isCurrentSession()) {
        handler.reject(_sessionChanged(options));
        return;
      }
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      handler.next(options);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!isCurrentSession()) {
      handler.reject(_sessionChanged(response.requestOptions));
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      isCurrentSession() ? err : _sessionChanged(err.requestOptions),
    );
  }
}

DioException _sessionChanged(RequestOptions options) => DioException(
  requestOptions: options,
  type: DioExceptionType.cancel,
  message: '사용자 세션이 변경되어 요청을 취소했습니다.',
);
