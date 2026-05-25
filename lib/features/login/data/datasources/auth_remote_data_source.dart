import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/login/data/dtos/auth_requests.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Object?> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/login',
        data: request.toJson(),
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/register',
        data: request.toJson(),
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
