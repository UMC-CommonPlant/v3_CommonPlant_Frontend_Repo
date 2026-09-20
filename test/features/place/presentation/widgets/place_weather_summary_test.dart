import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/theme/app_theme.dart';
import 'package:commonplant_frontend/features/place/data/datasources/weather_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/weather_request.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_weather_repository.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_weather.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_weather_view_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_detail_header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';
import '../../data/weather_fixture.dart';

void main() {
  testWidgets('로컬 모드는 준비 상태만 보여 주고 조회·재호출하지 않는다', (tester) async {
    final source = _Source();
    await tester.pumpWidget(_app(source, connected: false, remote: false));
    await tester.pumpAndSettle();
    expect(find.text('날씨 정보 준비 중'), findsOneWidget);
    expect(find.byTooltip('날씨 다시 불러오기'), findsNothing);
    expect(source.calls, 0);
    expect(find.text('판교역 기준'), findsNothing);
    expect(find.text('9.3 / 5'), findsNothing);
    expect(find.text('69%'), findsNothing);
  });

  testWidgets('좌표 누락 시 판교역 실황·예보를 요청하고 기본 위치를 표시한다', (tester) async {
    final source = _Source();
    await tester.pumpWidget(_app(source, connected: false));
    await tester.pumpAndSettle();
    expect(source.calls, 2);
    expect(source.grids, everyElement(WeatherGrid(nx: 62, ny: 123)));
    expect(find.text('판교역 기준'), findsOneWidget);
    expect(find.text('23.5℃'), findsOneWidget);
    expect(find.text('날씨 정보 준비 중'), findsNothing);
  });

  testWidgets('성공은 기온·습도·예보 이름·시각·출처와 접근성 이름을 표시한다', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(_Source()));
    await tester.pumpAndSettle();
    expect(find.text('23.5℃'), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('구름 많음 예보'), findsOneWidget);
    expect(find.text('관측 9/20 09:00'), findsOneWidget);
    expect(find.text('예보 9/20 10:00'), findsOneWidget);
    expect(find.text('기상청 · 지역 날씨'), findsOneWidget);
    expect(find.text('판교역 기준'), findsNothing);
    expect(find.bySemanticsLabel('기온 23.5℃'), findsOneWidget);
    expect(find.bySemanticsLabel('습도 65%'), findsOneWidget);
    expect(find.byTooltip('날씨 다시 불러오기'), findsNothing);
    semantics.dispose();
  });

  testWidgets('실제 5초/3회 흐름 뒤 같은 영역에 재호출을 표시하고 빠른 연속 탭을 막는다', (tester) async {
    final source = _Source(hang: true);
    await tester.pumpWidget(_app(source, connected: false));
    await tester.pump();
    final region = find.byKey(const ValueKey('place-weather-region'));
    final originalPosition = tester.getTopLeft(region);
    expect(find.text('날씨 불러오는 중'), findsOneWidget);
    expect(find.byTooltip('날씨 다시 불러오기'), findsNothing);
    for (var attempt = 0; attempt < 3; attempt++) {
      await tester.pump(const Duration(seconds: 5));
    }
    expect(source.calls, 6);
    expect(find.text('판교역 기준'), findsOneWidget);
    expect(tester.getTopLeft(region), originalPosition);
    final retry = find.byTooltip('날씨 다시 불러오기');
    expect(retry, findsOneWidget);
    expect(find.descendant(of: region, matching: retry), findsOneWidget);
    final hitSize = tester.getSize(retry);
    expect(hitSize.width, greaterThanOrEqualTo(48));
    expect(hitSize.height, greaterThanOrEqualTo(48));
    final action = tester
        .widget<IconButton>(
          find.byWidgetPredicate(
            (widget) => widget is IconButton && widget.tooltip == '날씨 다시 불러오기',
          ),
        )
        .onPressed!;
    action();
    action();
    await tester.pump();
    expect(source.calls, 8);
    expect(find.text('날씨 불러오는 중'), findsOneWidget);
    expect(retry, findsNothing);
    source.hang = false;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(source.calls, 10);
    expect(source.grids, everyElement(WeatherGrid(nx: 62, ny: 123)));
    expect(find.text('판교역 기준'), findsOneWidget);
    expect(find.text('23.5℃'), findsOneWidget);
    expect(tester.getTopLeft(region), originalPosition);
    source.completePending();
    await tester.pump();
  });

  testWidgets('3회 오류의 원문을 숨기고 탭으로 실패 조회만 다시 시작한다', (tester) async {
    final source = _Source(fail: true);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(source));
    await tester.pumpAndSettle();
    expect(source.calls, 6);
    expect(find.textContaining('SECRET'), findsNothing);
    expect(find.text('날씨를 불러오지 못했어요'), findsOneWidget);
    final button = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == '날씨 다시 불러오기',
    );
    final semanticsData = tester.getSemantics(button).getSemanticsData();
    expect(
      '${semanticsData.label} ${semanticsData.tooltip}',
      contains('날씨 다시 불러오기'),
    );
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    source.fail = false;
    await tester.tap(find.byTooltip('날씨 다시 불러오기'));
    await tester.pumpAndSettle();
    expect(source.calls, 8);
    expect(find.text('23.5℃'), findsOneWidget);
    semantics.dispose();
  });

  for (final width in [320.0, 375.0, 430.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('휴대폰 $width / 글씨 $scale 에서 성공·실패 overflow가 없다', (
        tester,
      ) async {
        configureTestViewport(tester, Size(width, 812));
        final source = _Source();
        await tester.pumpWidget(
          _app(source, textScale: scale, connected: false),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('23.5℃'), findsOneWidget);
        expect(find.text('아주 긴 장소 이름을 가진 옥상 정원'), findsOneWidget);
        // 완전히 다른 scope로 실패 화면도 검증한다.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _app(_Source(fail: true), textScale: scale, connected: false),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byTooltip('날씨 다시 불러오기'), findsOneWidget);
      });
    }
  }

  testWidgets('장소를 바꾸면 이전 요청을 취소하고 늦은 응답을 표시하지 않는다', (tester) async {
    final source = _Source(hang: true);
    final selected = ValueNotifier('A');
    addTearDown(selected.dispose);
    await tester.pumpWidget(_app(source, selected: selected));
    await tester.pump();
    selected.value = 'B';
    await tester.pump();
    await tester.pump();
    expect(source.calls, 4);
    expect(source.tokens.take(2).every((token) => token.isCancelled), isTrue);
    source.completePending(nx: 61, temperature: '25');
    await tester.pumpAndSettle();
    expect(find.text('25℃'), findsOneWidget);
    source.completePending(nx: 60, temperature: '10');
    await tester.pumpAndSettle();
    expect(find.text('25℃'), findsOneWidget);
    expect(find.text('10℃'), findsNothing);
  });
}

Widget _app(
  _Source source, {
  bool connected = true,
  bool remote = true,
  double textScale = 1,
  ValueNotifier<String>? selected,
}) => ProviderScope(
  overrides: [
    useRemoteApiProvider.overrideWithValue(remote),
    authenticatedUserDataSession,
    if (connected) ...[
      placeWeatherGridProvider(
        'A',
      ).overrideWithValue(WeatherGrid(nx: 60, ny: 127)),
      placeWeatherGridProvider(
        'B',
      ).overrideWithValue(WeatherGrid(nx: 61, ny: 128)),
    ],
    placeWeatherRepositoryProvider.overrideWithValue(
      PlaceWeatherRepository(
        source,
        now: () => DateTime.parse('2026-09-20T09:50:00+09:00'),
      ),
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: selected == null
                ? _header('A')
                : ValueListenableBuilder(
                    valueListenable: selected,
                    builder: (context, placeId, _) => _header(placeId),
                  ),
          ),
        ),
      ),
    ),
  ),
);

Widget _header(String id) => PlaceDetailHeader(
  placeId: id,
  name: '아주 긴 장소 이름을 가진 옥상 정원',
  address: '서울특별시 성북구의 긴 장소 주소',
  friends: const [],
);

class _Source implements WeatherRemoteDataSource {
  _Source({this.hang = false, this.fail = false});
  bool hang;
  bool fail;
  int calls = 0;
  final tokens = <CancelToken>[];
  final grids = <WeatherGrid>[];
  final pending = <(WeatherRequest, Completer<Object?>)>[];
  @override
  Future<Object?> fetch(WeatherRequest request, CancelToken cancelToken) async {
    calls++;
    grids.add(request.grid);
    tokens.add(cancelToken);
    if (fail) {
      throw const ApiException(message: 'SECRET', kind: ApiFailureKind.network);
    }
    if (hang) {
      final completer = Completer<Object?>();
      pending.add((request, completer));
      return completer.future;
    }
    return weatherResponse(request);
  }

  void completePending({int? nx, String? temperature}) {
    for (final (request, completer) in pending) {
      if (completer.isCompleted || (nx != null && request.grid.nx != nx)) {
        continue;
      }
      final response = weatherResponse(request);
      if (temperature != null &&
          request.product == WeatherProduct.observation) {
        weatherItems(response).first['obsrValue'] = temperature;
      }
      completer.complete(response);
    }
  }
}
