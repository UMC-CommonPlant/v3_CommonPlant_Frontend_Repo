import 'dart:convert';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:dio/dio.dart';

class UserRemoteDataSource {
  const UserRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Object?> getMe() async {
    try {
      final response = await _dio.get<Object?>('/users');

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> searchUsers(String keyword) async {
    try {
      final response = await _dio.get<Object?>(
        '/users/${Uri.encodeComponent(keyword)}',
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> updateMe(
    UpdateUserRequest request, {
    MultipartFile? image,
  }) async {
    try {
      final response = await _dio.put<Object?>(
        '/users',
        data: FormData.fromMap({
          'user': MultipartFile.fromString(
            jsonEncode(request.toJson()),
            contentType: DioMediaType('application', 'json'),
          ),
          if (image != null) 'image': image,
        }),
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> deleteMe() async {
    try {
      final response = await _dio.delete<Object?>('/users');

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
