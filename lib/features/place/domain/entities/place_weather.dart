/// 기상청 동네예보 격자. 장소 API의 미확정 x/y 좌표와 구분한다.
class WeatherGrid {
  WeatherGrid({required this.nx, required this.ny}) {
    if (nx < 1 || nx > 149 || ny < 1 || ny > 253) {
      throw ArgumentError('기상청 격자 범위를 벗어났습니다.');
    }
  }

  final int nx;
  final int ny;

  @override
  bool operator ==(Object other) =>
      other is WeatherGrid && nx == other.nx && ny == other.ny;

  @override
  int get hashCode => Object.hash(nx, ny);
}

enum WeatherSky { clear, partlyCloudy, overcast }

enum WeatherPrecipitation {
  none,
  rain,
  rainAndSnow,
  snow,
  shower,
  drizzle,
  drizzleAndSnow,
  snowFlurry,
}

class PlaceWeather {
  const PlaceWeather({
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.precipitation,
    required this.observedAt,
    required this.sky,
    required this.skyForecastAt,
    required this.forecastIssuedAt,
  });

  final double temperatureCelsius;
  final double humidityPercent;
  final WeatherPrecipitation precipitation;
  final DateTime observedAt;
  final WeatherSky sky;
  final DateTime skyForecastAt;
  final DateTime forecastIssuedAt;
}
