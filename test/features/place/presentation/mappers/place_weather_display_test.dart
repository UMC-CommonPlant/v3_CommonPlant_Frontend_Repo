import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_weather_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('기온·습도와 날짜를 포함한 KST 관측/예보 시각을 구분한다', () {
    final display = PlaceWeatherDisplay.fromWeather(_weather());
    expect(display.temperature, '-2.5℃');
    expect(display.humidity, '65%');
    expect(display.condition, '맑음 예보');
    expect(display.observationTime, '관측 12/31 23:00');
    expect(display.conditionTime, '예보 1/1 00:00');
  });
  for (final (sky, symbol, label) in [
    (WeatherSky.clear, PlaceWeatherSymbol.sunny, '맑음 예보'),
    (WeatherSky.partlyCloudy, PlaceWeatherSymbol.partlyCloudy, '구름 많음 예보'),
    (WeatherSky.overcast, PlaceWeatherSymbol.cloudy, '흐림 예보'),
  ]) {
    test('$sky 하늘상태는 예보로 표시한다', () {
      final display = PlaceWeatherDisplay.fromWeather(_weather(sky: sky));
      expect(display.symbol, symbol);
      expect(display.condition, label);
    });
  }
  for (final (precipitation, symbol, label) in [
    (WeatherPrecipitation.rain, PlaceWeatherSymbol.rain, '비'),
    (WeatherPrecipitation.rainAndSnow, PlaceWeatherSymbol.sleet, '비·눈'),
    (WeatherPrecipitation.snow, PlaceWeatherSymbol.snow, '눈'),
    (WeatherPrecipitation.shower, PlaceWeatherSymbol.rain, '소나기'),
    (WeatherPrecipitation.drizzle, PlaceWeatherSymbol.rain, '빗방울'),
    (WeatherPrecipitation.drizzleAndSnow, PlaceWeatherSymbol.sleet, '빗방울·눈날림'),
    (WeatherPrecipitation.snowFlurry, PlaceWeatherSymbol.snow, '눈날림'),
  ]) {
    test('$precipitation 관측은 맑음 예보보다 우선한다', () {
      final display = PlaceWeatherDisplay.fromWeather(
        _weather(precipitation: precipitation),
      );
      expect(display.symbol, symbol);
      expect(display.condition, label);
      expect(display.conditionTime, display.observationTime);
    });
  }
}

PlaceWeather _weather({
  WeatherSky sky = WeatherSky.clear,
  WeatherPrecipitation precipitation = WeatherPrecipitation.none,
}) => PlaceWeather(
  temperatureCelsius: -2.5,
  humidityPercent: 65,
  precipitation: precipitation,
  observedAt: DateTime.utc(2026, 12, 31, 14),
  sky: sky,
  skyForecastAt: DateTime.utc(2026, 12, 31, 15),
  forecastIssuedAt: DateTime.utc(2026, 12, 31, 14, 30),
);
