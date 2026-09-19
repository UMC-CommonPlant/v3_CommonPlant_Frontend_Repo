import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final grid = WeatherGrid(nx: 60, ny: 127);
  for (final example in [
    (
      WeatherProduct.observation,
      '2026-01-01T00:09:59+09:00',
      '20251231',
      '2300',
    ),
    (
      WeatherProduct.observation,
      '2026-01-01T00:10:00+09:00',
      '20260101',
      '0000',
    ),
    (WeatherProduct.forecast, '2026-01-01T00:44:59+09:00', '20251231', '2330'),
    (WeatherProduct.forecast, '2026-01-01T00:45:00+09:00', '20260101', '0030'),
  ]) {
    test('제공 시각과 연도 경계 ${example.$1} ${example.$2}', () {
      final request = WeatherRequest.latest(
        product: example.$1,
        grid: grid,
        now: DateTime.parse(example.$2),
      );
      expect(request.baseDate, example.$3);
      expect(request.baseTime, example.$4);
      expect(request.toQueryParameters(), containsPair('dataType', 'JSON'));
      expect(request.toQueryParameters(), containsPair('nx', 60));
      expect(request.baseAt.isUtc, isTrue);
    });
  }

  test('격자 값 동등성과 범위를 검증한다', () {
    expect(grid, WeatherGrid(nx: 60, ny: 127));
    expect(grid.hashCode, WeatherGrid(nx: 60, ny: 127).hashCode);
    expect(() => WeatherGrid(nx: 0, ny: 127), throwsArgumentError);
    expect(() => WeatherGrid(nx: 60, ny: 254), throwsArgumentError);
  });
}
