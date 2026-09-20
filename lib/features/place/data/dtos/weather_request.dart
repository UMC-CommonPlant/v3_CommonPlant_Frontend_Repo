import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';

enum WeatherProduct {
  observation('getUltraSrtNcst'),
  forecast('getUltraSrtFcst');

  const WeatherProduct(this.endpoint);
  final String endpoint;
}

/// 발표시각은 KST이며 단말의 시간대 설정에 영향을 받지 않는다.
class WeatherRequest {
  WeatherRequest.latest({
    required this.product,
    required this.grid,
    required DateTime now,
  }) : requestedAt = now.toUtc() {
    // 공식 가이드: 실황 HH:00은 HH:10 이후, 예보 HH:30은 HH:45 이후 제공.
    final koreanTime = requestedAt.add(const Duration(hours: 9));
    final available = koreanTime.subtract(
      Duration(minutes: product == WeatherProduct.observation ? 10 : 45),
    );
    final koreanBase = DateTime.utc(
      available.year,
      available.month,
      available.day,
      available.hour,
      product == WeatherProduct.observation ? 0 : 30,
    );
    baseAt = koreanBase.subtract(const Duration(hours: 9));
    baseDate =
        '${koreanBase.year}${_two(koreanBase.month)}${_two(koreanBase.day)}';
    baseTime = '${_two(koreanBase.hour)}${_two(koreanBase.minute)}';
  }

  final WeatherProduct product;
  final WeatherGrid grid;
  final DateTime requestedAt;
  late final DateTime baseAt;
  late final String baseDate;
  late final String baseTime;

  Map<String, Object> toQueryParameters() => {
    'pageNo': 1,
    'numOfRows': 1000,
    'dataType': 'JSON',
    'base_date': baseDate,
    'base_time': baseTime,
    'nx': grid.nx,
    'ny': grid.ny,
  };
}

String _two(int value) => value.toString().padLeft(2, '0');
