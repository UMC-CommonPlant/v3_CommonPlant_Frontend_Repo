import 'dart:convert';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:dio/dio.dart';

class PlaceRemoteDataSource {
  const PlaceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Object?> getMyGarden() async {
    try {
      final response = await _dio.get<Object?>('/place/myGarden');

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> getUserPlaces() async {
    try {
      final response = await _dio.get<Object?>('/place/user');

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> getPlace(String code) async {
    try {
      final response = await _dio.get<Object?>('/place/$code');

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> createPlace(CreatePlaceRequest request) async {
    try {
      await _dio.post<Object?>(
        '/place/create',
        data: FormData.fromMap({
          'place': MultipartFile.fromString(
            jsonEncode(request.toJson()),
            contentType: DioMediaType('application', 'json'),
          ),
        }),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) async {
    try {
      await _dio.put<Object?>(
        '/place/update/$code',
        data: FormData.fromMap({
          'place': MultipartFile.fromString(
            jsonEncode(request.toJson()),
            contentType: DioMediaType('application', 'json'),
          ),
          if (image != null) 'image': image,
        }),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> deletePlace(String code) async {
    try {
      await _dio.delete<Object?>('/place/delete/$code');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
