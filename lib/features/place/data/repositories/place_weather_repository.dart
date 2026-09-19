import 'dart:async';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/datasources/weather_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/data/mappers/place_weather_mapper.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:dio/dio.dart';

class PlaceWeatherRepository {
  PlaceWeatherRepository(this._source, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final WeatherRemoteDataSource _source;
  final DateTime Function() _now;

  Future<PlaceWeather> fetch(WeatherGrid grid, CancelToken cancelToken) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      if (cancelToken.isCancelled) throw _cancelled;
      try {
        return await _attempt(grid, cancelToken);
      } on ApiException catch (error) {
        if (cancelToken.isCancelled) throw _cancelled;
        if (error.kind == ApiFailureKind.cancelled || attempt == 2) rethrow;
      }
    }
    throw StateError('날씨 조회 시도 횟수를 벗어났습니다.');
  }

  Future<PlaceWeather> _attempt(
    WeatherGrid grid,
    CancelToken cancellation,
  ) async {
    final now = _now();
    final observationRequest = WeatherRequest.latest(
      product: WeatherProduct.observation,
      grid: grid,
      now: now,
    );
    final forecastRequest = WeatherRequest.latest(
      product: WeatherProduct.forecast,
      grid: grid,
      now: now,
    );
    final attemptToken = CancelToken();
    final deadline = Completer<PlaceWeather>();
    final timer = Timer(const Duration(seconds: 5), () {
      deadline.completeError(
        const ApiException(
          message: '날씨 요청 시간이 초과됐습니다.',
          kind: ApiFailureKind.timeout,
        ),
      );
      attemptToken.cancel();
    });
    try {
      // 두 요청을 병렬 실행하되, 조회 시도 전체가 같은 5초 예산을 사용한다.
      final request =
          Future.wait<Object?>([
            _source.fetch(observationRequest, attemptToken),
            _source.fetch(forecastRequest, attemptToken),
          ], eagerError: true).then(
            (responses) => placeWeatherFromResponses(
              observation: responses[0],
              forecast: responses[1],
              observationRequest: observationRequest,
              forecastRequest: forecastRequest,
            ),
          );
      return await Future.any<PlaceWeather>([
        request,
        deadline.future,
        cancellation.whenCancel.then<PlaceWeather>((_) => throw _cancelled),
      ]);
    } finally {
      timer.cancel();
      attemptToken.cancel();
    }
  }
}

const _cancelled = ApiException(
  message: '날씨 조회가 취소됐습니다.',
  kind: ApiFailureKind.cancelled,
);
