import 'dart:typed_data';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/weather_api_client.dart';
import 'package:commonplant_frontend/features/place/data/datasources/weather_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final product in WeatherProduct.values) {
    test('$product 공식 HTTPS 경로·격자·JSON과 인코딩 한 번만 적용한다', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(weatherDioProvider, (_, _) {});
      addTearDown(subscription.close);
      final dio = container.read(weatherDioProvider);
      final adapter = _Adapter();
      dio.httpClientAdapter = adapter;
      final source = DioWeatherRemoteDataSource(dio, serviceKey: 'test+a/b=');
      await source.fetch(
        WeatherRequest.latest(
          product: product,
          grid: WeatherGrid(nx: 60, ny: 127),
          now: DateTime.utc(2026, 9, 20, 1),
        ),
        CancelToken(),
      );
      final options = adapter.options!;
      expect(options.uri.host, 'apis.data.go.kr');
      expect(options.uri.scheme, 'https');
      expect(
        options.uri.path,
        '/1360000/VilageFcstInfoService_2.0/${product.endpoint}',
      );
      expect(options.uri.queryParameters['serviceKey'], 'test+a/b=');
      expect(options.uri.queryParameters['nx'], '60');
      expect(options.uri.queryParameters['dataType'], 'JSON');
      expect(
        options.headers.keys.map((key) => key.toLowerCase()),
        isNot(anyOf(contains('authorization'), contains('cookie'))),
      );
      expect(dio.interceptors.whereType<LogInterceptor>(), isEmpty);
      expect(options.followRedirects, isFalse);
    });
  }
  test('빈 키는 요청하지 않고 HTTP 오류 원문과 URL을 노출하지 않는다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    addTearDown(dio.close);
    final adapter = _Adapter(statusCode: 500);
    dio.httpClientAdapter = adapter;
    final request = WeatherRequest.latest(
      product: WeatherProduct.observation,
      grid: WeatherGrid(nx: 60, ny: 127),
      now: DateTime.utc(2026, 9, 20, 1),
    );
    await expectLater(
      DioWeatherRemoteDataSource(
        dio,
        serviceKey: '',
      ).fetch(request, CancelToken()),
      throwsA(isA<ApiException>()),
    );
    expect(adapter.options, isNull);
    await expectLater(
      DioWeatherRemoteDataSource(
        dio,
        serviceKey: 'SECRET',
      ).fetch(request, CancelToken()),
      throwsA(
        isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiFailureKind.server)
            .having((e) => e.cause, 'cause', isNull)
            .having((e) => e.toString(), 'message', isNot(contains('SECRET'))),
      ),
    );
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter({this.statusCode = 200});
  final int statusCode;
  RequestOptions? options;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
