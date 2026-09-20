import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_weather_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_view_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final grid = WeatherGrid(nx: 60, ny: 127);
  final gridB = WeatherGrid(nx: 61, ny: 128);
  test('장소 좌표가 없으면 판교역을 조회하고 같은 위치로 재시도한다', () async {
    final repository = _Repository();
    final container = _container(repository, grid, gridOverride: (_) => null);
    addTearDown(container.dispose);
    final subscription = container.listen(
      placeWeatherViewProvider('A'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final pangyo = WeatherGrid(nx: 62, ny: 123);
    expect(repository.grids, [pangyo]);
    expect(
      container.read(placeWeatherLocationProvider('A'))?.usesFallback,
      isTrue,
    );
    repository.pending.first.completeError(Exception('network'));
    await container.pump();
    container.read(placeWeatherViewProvider('A').notifier).retry();
    await container.pump();
    expect(repository.grids, [pangyo, pangyo]);
    repository.pending.last.complete(_weather(23));
    await container.pump();
    expect(
      container.read(placeWeatherViewProvider('A')).requireValue?.temperature,
      '23℃',
    );
  });
  test('실제 장소 격자가 판교역과 같아도 기본 위치 안내를 붙이지 않는다', () async {
    final repository = _Repository();
    final pangyo = WeatherGrid(nx: 62, ny: 123);
    final container = _container(repository, pangyo);
    addTearDown(container.dispose);
    expect(
      container.read(placeWeatherLocationProvider('A'))?.usesFallback,
      isFalse,
    );
    container.read(placeWeatherViewProvider('A'));
    expect(repository.grids, [pangyo]);
  });
  test('기본 위치 조회 중 장소 좌표가 생기면 전환하고 늦은 기본 응답을 무시한다', () async {
    final repository = _Repository();
    final selectedGrid = StateProvider<WeatherGrid?>((ref) => null);
    final container = _container(
      repository,
      grid,
      gridOverride: (ref) => ref.watch(selectedGrid),
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      placeWeatherViewProvider('A'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    container.read(selectedGrid.notifier).state = grid;
    await container.pump();
    expect(repository.grids, [WeatherGrid(nx: 62, ny: 123), grid]);
    expect(repository.tokens.first.isCancelled, isTrue);
    expect(
      container.read(placeWeatherLocationProvider('A'))?.usesFallback,
      isFalse,
    );
    repository.pending.last.complete(_weather(25));
    await container.pump();
    repository.pending.first.complete(_weather(10));
    await container.pump();
    expect(
      container.read(placeWeatherViewProvider('A')).requireValue?.temperature,
      '25℃',
    );
    container.read(selectedGrid.notifier).state = null;
    await container.pump();
    expect(repository.grids.last, WeatherGrid(nx: 62, ny: 123));
    expect(container.read(placeWeatherViewProvider('A')).hasValue, isFalse);
    expect(
      container.read(placeWeatherLocationProvider('A'))?.usesFallback,
      isTrue,
    );
  });
  test('로컬 모드는 격자가 주어져도 실제 API를 부르지 않는다', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        useRemoteApiProvider.overrideWithValue(false),
        placeWeatherGridProvider('A').overrideWithValue(grid),
        placeWeatherRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(placeWeatherViewProvider('A')).requireValue, isNull);
    expect(repository.pending, isEmpty);
  });
  test('실패 재조회는 원본 한 번만 시작하고 성공/로딩 중 다시 부르지 않는다', () async {
    final repository = _Repository();
    final container = _container(repository, grid);
    addTearDown(container.dispose);
    final subscription = container.listen(
      placeWeatherViewProvider('A'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final controller = container.read(placeWeatherViewProvider('A').notifier);
    controller.retry();
    expect(repository.pending.length, 1);
    repository.pending.first.completeError(Exception('network'));
    await container.pump();
    expect(container.read(placeWeatherViewProvider('A')).hasError, isTrue);
    controller.retry();
    controller.retry();
    await container.pump();
    expect(repository.pending.length, 2);
    expect(container.read(placeWeatherViewProvider('A')).isLoading, isTrue);
    repository.pending.last.complete(_weather(23));
    await container.pump();
    expect(
      container.read(placeWeatherViewProvider('A')).requireValue?.temperature,
      '23℃',
    );
    controller.retry();
    expect(repository.pending.length, 2);
  });
  test('격자 변경 후 이전 값은 숨기고 늦은 이전 응답을 무시한다', () async {
    final repository = _Repository();
    final selectedGrid = StateProvider<WeatherGrid>((ref) => grid);
    final container = _container(
      repository,
      grid,
      gridOverride: (ref) => ref.watch(selectedGrid),
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      placeWeatherViewProvider('A'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    container.read(selectedGrid.notifier).state = gridB;
    await container.pump();
    expect(repository.grids, [grid, gridB]);
    expect(repository.tokens.first.isCancelled, isTrue);
    repository.pending.last.complete(_weather(25));
    await container.pump();
    repository.pending.first.complete(_weather(10));
    await container.pump();
    expect(
      container.read(placeWeatherViewProvider('A')).requireValue?.temperature,
      '25℃',
    );
  });
  test('계정 변경 때 이전 성공값을 숨기고 새 값을 기다린다', () async {
    final repository = _Repository();
    final container = _container(repository, grid);
    addTearDown(container.dispose);
    final subscription = container.listen(
      placeWeatherViewProvider('A'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    repository.pending.first.complete(_weather(10));
    await container.pump();
    container.read(userDataSessionProvider.notifier).start();
    await container.pump();
    final state = container.read(placeWeatherViewProvider('A'));
    expect(state.isLoading, isTrue);
    expect(state.hasValue, isFalse);
    repository.pending.last.complete(_weather(20));
    await container.pump();
    expect(
      container.read(placeWeatherViewProvider('A')).requireValue?.temperature,
      '20℃',
    );
  });
}

ProviderContainer _container(
  _Repository repository,
  WeatherGrid grid, {
  WeatherGrid? Function(Ref)? gridOverride,
}) {
  final container = ProviderContainer(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      placeWeatherGridProvider('A').overrideWith(gridOverride ?? (ref) => grid),
      placeWeatherRepositoryProvider.overrideWithValue(repository),
    ],
  );
  container.read(userDataSessionProvider.notifier).start();
  return container;
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
  final pending = <Completer<PlaceWeather>>[];
  final grids = <WeatherGrid>[];
  final tokens = <CancelToken>[];
  @override
  Future<PlaceWeather> fetch(WeatherGrid grid, CancelToken token) {
    grids.add(grid);
    tokens.add(token);
    final result = Completer<PlaceWeather>();
    pending.add(result);
    return result.future;
  }
}
