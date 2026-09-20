import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';

enum PlaceWeatherSymbol { sunny, partlyCloudy, cloudy, rain, sleet, snow }

/// 관측과 예보를 구분해 화면에 전달하는 표시 모델. 원본 API 값은 받지 않는다.
class PlaceWeatherDisplay {
  const PlaceWeatherDisplay({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.symbol,
    required this.observationTime,
    required this.conditionTime,
  });

  factory PlaceWeatherDisplay.fromWeather(PlaceWeather weather) {
    final (symbol, label) = switch (weather.precipitation) {
      WeatherPrecipitation.none => switch (weather.sky) {
        WeatherSky.clear => (PlaceWeatherSymbol.sunny, '맑음 예보'),
        WeatherSky.partlyCloudy => (
          PlaceWeatherSymbol.partlyCloudy,
          '구름 많음 예보',
        ),
        WeatherSky.overcast => (PlaceWeatherSymbol.cloudy, '흐림 예보'),
      },
      WeatherPrecipitation.rain => (PlaceWeatherSymbol.rain, '비'),
      WeatherPrecipitation.rainAndSnow => (PlaceWeatherSymbol.sleet, '비·눈'),
      WeatherPrecipitation.snow => (PlaceWeatherSymbol.snow, '눈'),
      WeatherPrecipitation.shower => (PlaceWeatherSymbol.rain, '소나기'),
      WeatherPrecipitation.drizzle => (PlaceWeatherSymbol.rain, '빗방울'),
      WeatherPrecipitation.drizzleAndSnow => (
        PlaceWeatherSymbol.sleet,
        '빗방울·눈날림',
      ),
      WeatherPrecipitation.snowFlurry => (PlaceWeatherSymbol.snow, '눈날림'),
    };
    final observation = '관측 ${_koreanTime(weather.observedAt)}';
    return PlaceWeatherDisplay(
      temperature: '${_number(weather.temperatureCelsius)}℃',
      humidity: '${_number(weather.humidityPercent)}%',
      condition: label,
      symbol: symbol,
      observationTime: observation,
      conditionTime: weather.precipitation == WeatherPrecipitation.none
          ? '예보 ${_koreanTime(weather.skyForecastAt)}'
          : observation,
    );
  }

  final String temperature;
  final String humidity;
  final String condition;
  final PlaceWeatherSymbol symbol;
  final String observationTime;
  final String conditionTime;
}

String _number(double value) => value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

String _koreanTime(DateTime value) {
  final time = value.toUtc().add(const Duration(hours: 9));
  return '${time.month}/${time.day} '
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
