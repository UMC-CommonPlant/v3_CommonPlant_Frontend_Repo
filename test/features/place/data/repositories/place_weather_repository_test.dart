import 'dart:async';

import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/features/place/data/datasources/weather_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_weather_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../weather_fixture.dart';

void main() {
  final grid = WeatherGrid(nx: 60, ny: 127);
  final now = DateTime.parse('2026-09-20T09:50:00+09:00');
  for (var successAttempt = 1; successAttempt <= 3; successAttempt++) {
    test('$successAttempt 번째 성공 즉시 멈추고 두 endpoint만 병렬 조회한다', () async {
      final source = _Source(
        List.generate(
          successAttempt,
          (i) => i + 1 == successAttempt ? 'success' : 'error',
        ),
      );
      final repository = PlaceWeatherRepository(source, now: () => now);
      final result = await repository.fetch(grid, CancelToken());
      expect(result.temperatureCelsius, 23.5);
      expect(source.requests.length, successAttempt * 2);
      expect(source.tokens.every((token) => token.isCancelled), isTrue);
    });
  }

  testWidgets('매 시도 5초·총 15초 후 실패하고 늦은 결과를 무시한다', (tester) async {
    final source = _Source(['hang', 'hang', 'hang']);
    final repository = PlaceWeatherRepository(source, now: () => now);
    final pending = repository.fetch(grid, CancelToken());
    final assertion = expectLater(
      pending,
      throwsA(
        isA<ApiException>().having(
          (error) => error.kind,
          'kind',
          ApiFailureKind.timeout,
        ),
      ),
    );
    await tester.pump();
    expect(source.requests.length, 2);
    await tester.pump(const Duration(milliseconds: 4999));
    expect(source.requests.length, 2);
    await tester.pump(const Duration(milliseconds: 1));
    expect(source.requests.length, 4);
    await tester.pump(const Duration(seconds: 5));
    expect(source.requests.length, 6);
    await tester.pump(const Duration(seconds: 5));
    await assertion;
    expect(source.tokens.every((token) => token.isCancelled), isTrue);
    source.completePending();
    await tester.pump(const Duration(minutes: 1));
    expect(source.requests.length, 6);
  });

  testWidgets('timeout·오류 뒤 세 번째 성공도 총 3회 안에 끝난다', (tester) async {
    final source = _Source(['hang', 'error', 'success']);
    final repository = PlaceWeatherRepository(source, now: () => now);
    final pending = repository.fetch(grid, CancelToken());
    await tester.pump(const Duration(seconds: 5));
    expect((await pending).humidityPercent, 65);
    expect(source.requests.length, 6);
    source.completePending();
    await tester.pump();
  });

  test('모두 오류면 멈추고 새 수동 조회는 시도 예산을 초기화한다', () async {
    final source = _Source(['error', 'error', 'error', 'success']);
    final repository = PlaceWeatherRepository(source, now: () => now);
    await expectLater(
      repository.fetch(grid, CancelToken()),
      throwsA(isA<ApiException>()),
    );
    expect(source.requests.length, 6);
    expect((await repository.fetch(grid, CancelToken())).humidityPercent, 65);
    expect(source.requests.length, 8);
  });

  testWidgets('진행 중 취소는 두 요청을 종료하고 자동 재시도하지 않는다', (tester) async {
    final source = _Source(['hang']);
    final repository = PlaceWeatherRepository(source, now: () => now);
    final cancellation = CancelToken();
    final pending = repository.fetch(grid, cancellation);
    final assertion = expectLater(
      pending,
      throwsA(
        isA<ApiException>().having(
          (error) => error.kind,
          'kind',
          ApiFailureKind.cancelled,
        ),
      ),
    );
    cancellation.cancel();
    await tester.pump();
    await assertion;
    expect(source.tokens.every((token) => token.isCancelled), isTrue);
    await tester.pump(const Duration(seconds: 20));
    expect(source.requests.length, 2);
    source.completePending();
    await tester.pump();
  });

  test('조회 전 취소는 요청을 보내지 않는다', () async {
    final source = _Source(['success']);
    final repository = PlaceWeatherRepository(source, now: () => now);
    await expectLater(
      repository.fetch(grid, CancelToken()..cancel()),
      throwsA(isA<ApiException>()),
    );
    expect(source.requests, isEmpty);
  });
}

class _Source implements WeatherRemoteDataSource {
  _Source(this.behaviors);
  final List<String> behaviors;
  final requests = <WeatherRequest>[];
  final tokens = <CancelToken>[];
  final pending = <(WeatherRequest, Completer<Object?>)>[];

  @override
  Future<Object?> fetch(WeatherRequest request, CancelToken token) async {
    final attempt = requests.length ~/ 2;
    requests.add(request);
    tokens.add(token);
    switch (behaviors[attempt]) {
      case 'error':
        throw const ApiException(
          message: '일시 오류',
          kind: ApiFailureKind.network,
        );
      case 'hang':
        final completer = Completer<Object?>();
        pending.add((request, completer));
        return completer.future;
      default:
        return weatherResponse(request);
    }
  }

  void completePending() {
    for (final entry in pending) {
      entry.$2.complete(weatherResponse(entry.$1));
    }
  }
}
