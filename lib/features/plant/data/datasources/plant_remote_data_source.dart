import 'dart:convert';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:dio/dio.dart';

class PlantRemoteDataSource {
  const PlantRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Object?> getPlants({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get<Object?>(
        '/plants',
        queryParameters: {'page': page, 'size': size},
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> createPlant(CreatePlantRequest request) async {
    try {
      await _dio.post<Object?>(
        '/plants',
        data: FormData.fromMap({
          'plant': MultipartFile.fromString(
            jsonEncode(request.toJson()),
            contentType: DioMediaType('application', 'json'),
          ),
        }),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> getPlant({
    required String plantId,
    required String placeId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/plants/$plantId',
        queryParameters: {'placeId': placeId},
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> getPlantEditInfo({
    required String plantId,
    required String placeId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/plants/$plantId/edit',
        queryParameters: {'placeId': placeId},
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> updatePlant({
    required String plantId,
    required String placeId,
    required UpdatePlantRequest request,
  }) async {
    try {
      await _dio.put<Object?>(
        '/plants/$plantId',
        queryParameters: {'placeId': placeId},
        data: FormData.fromMap({
          'plant': MultipartFile.fromString(
            jsonEncode(request.toJson()),
            contentType: DioMediaType('application', 'json'),
          ),
        }),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> deletePlant({
    required String plantId,
    required String placeId,
  }) async {
    try {
      await _dio.delete<Object?>(
        '/plants/$plantId',
        queryParameters: {'placeId': placeId},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
