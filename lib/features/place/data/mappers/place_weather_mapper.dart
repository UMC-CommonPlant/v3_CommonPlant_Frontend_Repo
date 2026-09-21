import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';

PlaceWeather placeWeatherFromResponses({
  required Object? observation,
  required Object? forecast,
  required WeatherRequest observationRequest,
  required WeatherRequest forecastRequest,
}) {
  final readings = <String, double>{};
  for (final item in _items(observation, observationRequest)) {
    final category = item['category'];
    if (!const {'T1H', 'REH', 'PTY'}.contains(category)) continue;
    if (readings.containsKey(category)) throw _invalid();
    readings[category as String] = _number(item['obsrValue']);
  }
  final temperature = readings['T1H'];
  final humidity = readings['REH'];
  final precipitation = readings['PTY'];
  if (temperature == null || humidity == null || precipitation == null) {
    throw _invalid();
  }
  if (humidity < 0 ||
      humidity > 100 ||
      precipitation != precipitation.truncateToDouble() ||
      precipitation < 0 ||
      precipitation > 7) {
    throw _invalid();
  }

  final forecastItems = _items(forecast, forecastRequest);
  // 실제 초단기예보는 HH30 요청에 같은 시각대의 HH00을 반환하기도 한다.
  // 요청값으로 덮지 않고 응답의 발표시각을 보존한다. 근거: #307 작업 기록.
  final forecastBaseAt =
      forecastItems.first['baseTime'] == forecastRequest.baseTime
      ? forecastRequest.baseAt
      : forecastRequest.baseAt.subtract(const Duration(minutes: 30));
  final skies = <DateTime, WeatherSky>{};
  for (final item in forecastItems) {
    if (item['category'] != 'SKY') continue;
    final time = _koreanTimestamp(item['fcstDate'], item['fcstTime']);
    if (!time.isAfter(forecastBaseAt) ||
        time.isAfter(forecastBaseAt.add(const Duration(hours: 6)))) {
      throw _invalid();
    }
    final sky = switch (_number(item['fcstValue'])) {
      1 => WeatherSky.clear,
      3 => WeatherSky.partlyCloudy,
      4 => WeatherSky.overcast,
      _ => throw _invalid(),
    };
    if (skies.containsKey(time)) throw _invalid();
    skies[time] = sky;
  }
  final times =
      skies.keys
          .where((time) => !time.isBefore(forecastRequest.requestedAt))
          .toList()
        ..sort();
  if (times.isEmpty) throw _invalid();

  return PlaceWeather(
    temperatureCelsius: temperature,
    humidityPercent: humidity,
    precipitation: WeatherPrecipitation.values[precipitation.toInt()],
    observedAt: observationRequest.baseAt,
    sky: skies[times.first]!,
    skyForecastAt: times.first,
    forecastIssuedAt: forecastBaseAt,
  );
}

List<Map<String, Object?>> _items(Object? data, WeatherRequest request) {
  final response = _map(_map(data)['response']);
  final header = _map(response['header']);
  final code = header['resultCode'];
  if (code is! String) throw _invalid();
  if (code != '00') {
    // 원문/요청 URL에는 인증키가 포함될 수 있어 보존하지 않는다.
    throw ApiException(
      message: '기상청 날씨 정보를 조회하지 못했습니다.',
      code: RegExp(r'^\d{2}$').hasMatch(code) ? code : null,
      kind: ApiFailureKind.server,
    );
  }
  final body = _map(response['body']);
  final items = _map(body['items'])['item'];
  if (items is! List || items.isEmpty || body['totalCount'] != items.length) {
    throw _invalid();
  }
  final responseBaseTime = _map(items.first)['baseTime'];
  final sameHourForecast =
      request.product == WeatherProduct.forecast &&
      responseBaseTime == '${request.baseTime.substring(0, 2)}00';
  if (responseBaseTime != request.baseTime && !sameHourForecast) {
    throw _invalid();
  }
  return items.map((raw) {
    final item = _map(raw);
    if (item['baseDate'] != request.baseDate ||
        item['baseTime'] != responseBaseTime ||
        item['nx'] != request.grid.nx ||
        item['ny'] != request.grid.ny ||
        item['category'] is! String) {
      throw _invalid();
    }
    return item;
  }).toList();
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<String, Object?>) throw _invalid();
  return value;
}

double _number(Object? value) {
  final number = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value),
    _ => null,
  };
  // 공식 결측값 범위: +900 이상 또는 -900 이하.
  if (number == null || !number.isFinite || number.abs() >= 900) {
    throw _invalid();
  }
  return number;
}

DateTime _koreanTimestamp(Object? date, Object? time) {
  if (date is! String ||
      time is! String ||
      !RegExp(r'^\d{8}$').hasMatch(date) ||
      !RegExp(r'^\d{4}$').hasMatch(time)) {
    throw _invalid();
  }
  final year = int.parse(date.substring(0, 4));
  final month = int.parse(date.substring(4, 6));
  final day = int.parse(date.substring(6, 8));
  final hour = int.parse(time.substring(0, 2));
  final minute = int.parse(time.substring(2, 4));
  final value = DateTime.utc(year, month, day, hour, minute);
  if (value.year != year ||
      value.month != month ||
      value.day != day ||
      value.hour != hour ||
      minute != 0) {
    throw _invalid();
  }
  return value.subtract(const Duration(hours: 9));
}

ApiException _invalid() => const ApiException(
  message: '사용할 수 있는 날씨 정보가 없습니다.',
  kind: ApiFailureKind.server,
);
