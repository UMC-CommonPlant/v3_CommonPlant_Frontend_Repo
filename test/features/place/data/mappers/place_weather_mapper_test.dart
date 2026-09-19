import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/data/mappers/place_weather_mapper.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:flutter_test/flutter_test.dart';

import '../weather_fixture.dart';

void main() {
  final grid = WeatherGrid(nx: 60, ny: 127);
  final now = DateTime.parse('2026-09-20T09:50:00+09:00');
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
  late Map<String, Object?> observation;
  late Map<String, Object?> forecast;
  setUp(() {
    observation = weatherResponse(observationRequest);
    forecast = weatherResponse(forecastRequest);
  });
  PlaceWeather parse() => placeWeatherFromResponses(
    observation: observation,
    forecast: forecast,
    observationRequest: observationRequest,
    forecastRequest: forecastRequest,
  );

  test('관측값과 별도 시각의 하늘상태 예보를 보존한다', () {
    final weather = parse();
    expect(weather.temperatureCelsius, 23.5);
    expect(weather.humidityPercent, 65);
    expect(weather.precipitation, WeatherPrecipitation.none);
    expect(weather.sky, WeatherSky.partlyCloudy);
    expect(weather.observedAt, DateTime.parse('2026-09-20T09:00:00+09:00'));
    expect(
      weather.forecastIssuedAt,
      DateTime.parse('2026-09-20T09:30:00+09:00'),
    );
    expect(weather.skyForecastAt, DateTime.parse('2026-09-20T10:00:00+09:00'));
  });

  for (final value in ['-999', '900', 'NaN', 'Infinity', null, '']) {
    test('결측·유효하지 않은 관측값 $value 를 실제 날씨로 사용하지 않는다', () {
      weatherItems(observation).first['obsrValue'] = value;
      expect(parse, throwsA(isA<ApiException>()));
    });
  }
  test('습도 범위와 강수 코드를 검증한다', () {
    weatherItems(observation)[1]['obsrValue'] = '101';
    expect(parse, throwsA(isA<ApiException>()));
    weatherItems(observation)[1]['obsrValue'] = '65';
    weatherItems(observation)[2]['obsrValue'] = '1.5';
    expect(parse, throwsA(isA<ApiException>()));
  });
  test('다른 격자나 발표 시각 응답을 거절한다', () {
    weatherItems(observation).first['nx'] = 61;
    expect(parse, throwsA(isA<ApiException>()));
    weatherItems(observation).first['nx'] = 60;
    weatherItems(forecast).first['baseTime'] = '0830';
    expect(parse, throwsA(isA<ApiException>()));
  });
  test('필수 항목 누락이나 잘린 페이지를 성공으로 취급하지 않는다', () {
    weatherItems(observation).first['category'] = 'RN1';
    expect(parse, throwsA(isA<ApiException>()));
    observation = weatherResponse(observationRequest);
    ((observation['response'] as Map)['body'] as Map)['totalCount'] = 8;
    expect(parse, throwsA(isA<ApiException>()));
  });
  test('중복 항목과 알려지지 않은 하늘상태를 거절한다', () {
    weatherItems(observation)[1]['category'] = 'T1H';
    expect(parse, throwsA(isA<ApiException>()));
    observation = weatherResponse(observationRequest);
    weatherItems(forecast).first['fcstValue'] = '2';
    expect(parse, throwsA(isA<ApiException>()));
  });
  test('정렬되지 않은 예보에서 요청 이후 가장 가까운 시간을 선택한다', () {
    final items = weatherItems(forecast);
    items.add({...items.first, 'fcstTime': '1100', 'fcstValue': '4'});
    items.add({...items.first, 'fcstTime': '1000', 'fcstValue': '1'});
    items.first['fcstTime'] = '1200';
    ((forecast['response'] as Map)['body'] as Map)['totalCount'] = items.length;
    expect(parse().sky, WeatherSky.clear);
    expect(parse().skyForecastAt, DateTime.parse('2026-09-20T10:00:00+09:00'));
  });
  test('잘못된 날짜와 만료된 예보를 거절한다', () {
    weatherItems(forecast).first['fcstDate'] = '20260231';
    expect(parse, throwsA(isA<ApiException>()));
    forecast = weatherResponse(forecastRequest);
    weatherItems(forecast).first['fcstTime'] = '0900';
    expect(parse, throwsA(isA<ApiException>()));
  });
  test('HTTP 성공이어도 공공데이터 오류 코드를 검사하고 원문은 숨긴다', () {
    observation = {
      'response': {
        'header': {'resultCode': '30', 'resultMsg': 'SECRET'},
      },
    };
    expect(
      parse,
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', '30')
            .having((e) => e.toString(), 'message', isNot(contains('SECRET'))),
      ),
    );
  });
}
