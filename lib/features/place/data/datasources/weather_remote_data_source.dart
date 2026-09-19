import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:dio/dio.dart';

abstract interface class WeatherRemoteDataSource {
  Future<Object?> fetch(WeatherRequest request, CancelToken cancelToken);
}

class DioWeatherRemoteDataSource implements WeatherRemoteDataSource {
  const DioWeatherRemoteDataSource(this._dio, {required String serviceKey})
    : _serviceKey = serviceKey;

  final Dio _dio;
  final String _serviceKey;

  @override
  Future<Object?> fetch(WeatherRequest request, CancelToken cancelToken) async {
    if (_serviceKey.trim().isEmpty) {
      throw const ApiException(
        message: '공공데이터 날씨 인증키가 설정되지 않았습니다.',
        kind: ApiFailureKind.validation,
      );
    }
    try {
      final response = await _dio.get<Object?>(
        '/${request.product.endpoint}',
        queryParameters: {
          ...request.toQueryParameters(),
          'serviceKey': _serviceKey.trim(),
        },
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (error) {
      final failure = ApiException.fromDio(error);
      throw ApiException(
        message: '날씨 요청에 실패했습니다.',
        kind: failure.kind,
        statusCode: failure.statusCode,
      );
    }
  }
}
