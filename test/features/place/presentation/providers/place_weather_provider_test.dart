import 'dart:async';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/data/datasources/weather_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_weather_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final grid = WeatherGrid(nx: 60, ny: 127);
  late _Repository repository;
  late ProviderContainer container;
  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [placeWeatherRepositoryProvider.overrideWithValue(repository)],
    );
    container.read(userDataSessionProvider.notifier).start();
  });
  tearDown(() => container.dispose());

  test('동일 격자 구독은 한 흐름을 공유하고 폐기 시 취소한다', () async {
    final first = container.listen(placeWeatherProvider(grid), (_, _) {});
    final second = container.listen(
      placeWeatherProvider(WeatherGrid(nx: 60, ny: 127)),
      (_, _) {},
    );
    await container.pump();
    expect(repository.tokens.length, 1);
    first.close();
    second.close();
    await container.pump();
    expect(repository.tokens.single.isCancelled, isTrue);
    repository.results.single.complete(_weather(23));
  });

  test('수동 무효화는 기존 조회를 취소하고 늦은 응답을 배제한다', () async {
    final subscription = container.listen(
      placeWeatherProvider(grid),
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.pump();
    container.invalidate(placeWeatherProvider(grid));
    await container.pump();
    expect(repository.tokens.first.isCancelled, isTrue);
    expect(repository.tokens.length, 2);
    repository.results.last.complete(_weather(25));
    expect(
      (await container.read(
        placeWeatherProvider(grid).future,
      )).temperatureCelsius,
      25,
    );
    repository.results.first.complete(_weather(10));
    await container.pump();
    expect(
      container
          .read(placeWeatherProvider(grid))
          .requireValue
          .temperatureCelsius,
      25,
    );
  });

  test('계정 변경과 로그아웃은 이전 좌표 조회를 취소한다', () async {
    final subscription = container.listen(
      placeWeatherProvider(grid),
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.pump();
    container.read(userDataSessionProvider.notifier).start();
    await container.pump();
    expect(repository.tokens.first.isCancelled, isTrue);
    expect(repository.tokens.length, 2);
    container.read(userDataSessionProvider.notifier).end();
    await container.pump();
    expect(repository.tokens.last.isCancelled, isTrue);
    expect(container.read(placeWeatherProvider(grid)).hasError, isTrue);
    for (final result in repository.results) {
      result.complete(_weather(10));
    }
    await container.pump();
    expect(container.read(placeWeatherProvider(grid)).hasError, isTrue);
  });

  testWidgets('Repository 3회 실패 뒤 Riverpod 자동 재시도를 중첩하지 않는다', (tester) async {
    final source = _ErrorSource();
    final errorContainer = ProviderContainer(
      overrides: [
        placeWeatherRepositoryProvider.overrideWithValue(
          PlaceWeatherRepository(source),
        ),
      ],
    );
    addTearDown(errorContainer.dispose);
    errorContainer.read(userDataSessionProvider.notifier).start();
    final subscription = errorContainer.listen(
      placeWeatherProvider(grid),
      (_, _) {},
    );
    addTearDown(subscription.close);
    await tester.pump();
    expect(errorContainer.read(placeWeatherProvider(grid)).hasError, isTrue);
    expect(source.calls, 6);
    await tester.pump(const Duration(minutes: 1));
    expect(source.calls, 6);
  });
}

PlaceWeather _weather(double temperature) => PlaceWeather(
  temperatureCelsius: temperature,
  humidityPercent: 65,
  precipitation: WeatherPrecipitation.none,
  observedAt: DateTime.utc(2026, 9, 20),
  sky: WeatherSky.clear,
  skyForecastAt: DateTime.utc(2026, 9, 20, 1),
  forecastIssuedAt: DateTime.utc(2026, 9, 20, 0, 30),
);

class _Repository extends Fake implements PlaceWeatherRepository {
  final tokens = <CancelToken>[];
  final results = <Completer<PlaceWeather>>[];
  @override
  Future<PlaceWeather> fetch(WeatherGrid grid, CancelToken token) {
    tokens.add(token);
    final result = Completer<PlaceWeather>();
    results.add(result);
    return result.future;
  }
}

class _ErrorSource implements WeatherRemoteDataSource {
  int calls = 0;
  @override
  Future<Object?> fetch(WeatherRequest request, CancelToken cancelToken) async {
    calls++;
    throw const ApiException(message: '오류');
  }
}
