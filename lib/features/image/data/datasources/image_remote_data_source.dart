import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ImageRemoteDataSource {
  const ImageRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Object?> getDownloadUrl(String key) async {
    try {
      final response = await _dio.get<Object?>(
        '/s3/images',
        queryParameters: {'key': key},
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> uploadImages(List<MultipartFile> images) async {
    try {
      final response = await _dio.post<Object?>(
        '/s3/images',
        data: FormData.fromMap({'images': images}),
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Object?> updateImage({
    required String key,
    required MultipartFile image,
  }) async {
    try {
      final response = await _dio.put<Object?>(
        '/s3/images',
        queryParameters: {'key': key},
        data: FormData.fromMap({'image': image}),
      );

      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> deleteImage(String key) async {
    try {
      await _dio.delete<Object?>('/s3/images', queryParameters: {'key': key});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
