import 'dart:async';
import 'dart:io';

import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_care_summary.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_content_width.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_hero.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_info_section.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_memo_preview_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/image_selection.dart';

void main() {
  testWidgets('PlantHero는 장소와 식물 주요 정보를 표시한다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        const PlantDetailContentWidth(
          child: PlantHero(
            placeName: '거실 정원',
            name: '몬테',
            species: 'Monstera deliciosa',
          ),
        ),
      ),
    );

    expect(find.text('거실 정원'), findsOneWidget);
    expect(find.text('몬테'), findsOneWidget);
    expect(find.text('Monstera deliciosa'), findsOneWidget);
    expect(find.byTooltip('식물 사진 확대'), findsNothing);
    expect(find.bySemanticsLabel('식물 이미지 없음'), findsOneWidget);
    expect(find.text('사진을 불러오지 못했어요.'), findsNothing);
    expect(find.text('다시 시도'), findsNothing);
  });

  testWidgets('대표 사진을 원본 비율로 열고 확대하거나 닫을 수 있다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        const PlantDetailContentWidth(
          child: PlantHero(
            placeName: '거실 정원',
            name: '몬테',
            species: 'Monstera deliciosa',
            imageAsset: AppImageAssets.plantEditMonstera,
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(AppImageAssets.plantEditMonstera),
        tester.element(find.byType(PlantHero)),
      );
    });
    await tester.pump();
    await tester.tap(find.byTooltip('식물 사진 확대'));
    await tester.pumpAndSettle();

    final viewer = find.byType(InteractiveViewer);
    final photo = find.descendant(of: viewer, matching: find.byType(Image));
    expect(tester.widget<Image>(photo).fit, BoxFit.contain);
    final initialWidth = tester.getRect(photo).width;
    final center = tester.getCenter(viewer);
    final first = await tester.startGesture(center - const Offset(25, 0));
    final second = await tester.startGesture(center + const Offset(25, 0));
    await first.moveTo(center - const Offset(65, 0));
    await second.moveTo(center + const Offset(65, 0));
    await first.moveTo(center - const Offset(100, 0));
    await second.moveTo(center + const Offset(100, 0));
    await tester.pump();
    expect(tester.getRect(photo).width, greaterThan(initialWidth));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    expect(viewer, findsNothing);
    expect(find.text('거실 정원'), findsOneWidget);

    await tester.tap(find.byTooltip('식물 사진 확대'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(viewer, findsNothing);
    expect(find.text('거실 정원'), findsOneWidget);
  });

  for (final openViewer in [false, true]) {
    testWidgets(
      '${openViewer ? '확대 화면' : '대표 사진'}에서 사진 조회 실패 후 같은 사진을 다시 요청한다',
      (tester) async {
        final url = Uri.https('example.test', '/plant-$openViewer.png');
        final first = Completer<HttpClientResponse>();
        final retry = Completer<HttpClientResponse>();
        final client = _PhotoClient([first.future, retry.future]);
        debugNetworkImageHttpClientProvider = () => client;
        try {
          await tester.pumpWidget(
            _buildRouterApp(
              PlantDetailContentWidth(
                child: PlantHero(
                  placeName: '거실 정원',
                  name: '몬테',
                  species: 'Monstera deliciosa',
                  imageUrl: url.toString(),
                ),
              ),
            ),
          );
          final viewer = find.byType(InteractiveViewer);
          if (openViewer) {
            await tester.tap(find.byTooltip('식물 사진 확대'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            expect(viewer, findsOneWidget);
          }

          first.complete(_PhotoResponse(HttpStatus.serviceUnavailable));
          await tester.pumpAndSettle();
          expect(client.requests, [url]);
          expect(find.bySemanticsLabel('식물 이미지 없음'), findsNothing);
          expect(find.text('사진을 불러오지 못했어요.').hitTestable(), findsOneWidget);
          expect(find.byTooltip('식물 사진 확대'), findsNothing);

          final retryButton = find
              .widgetWithText(OutlinedButton, '다시 시도')
              .hitTestable();
          expect(
            tester
                .widget<OutlinedButton>(retryButton)
                .style
                ?.padding
                ?.resolve(const <WidgetState>{}),
            const EdgeInsets.symmetric(horizontal: AppSpacing.x16),
          );
          await tester.tap(retryButton);
          await tester.pump();
          expect(client.requests, [url, url]);
          expect(retryButton, findsNothing);
          expect(
            find.bySemanticsLabel('사진 불러오는 중').hitTestable(),
            findsOneWidget,
          );

          retry.complete(
            _PhotoResponse(HttpStatus.ok, testSelectedImage().bytes),
          );
          await tester.pump();
          await tester.runAsync(() async {
            await precacheImage(
              NetworkImage(url.toString()),
              tester.element(find.byType(PlantHero)),
            );
          });
          await tester.pumpAndSettle();
          expect(find.text('사진을 불러오지 못했어요.'), findsNothing);
          expect(find.bySemanticsLabel('사진 불러오는 중'), findsNothing);

          if (openViewer) {
            await tester.tap(find.byTooltip('닫기'));
            await tester.pumpAndSettle();
            expect(viewer, findsNothing);
          }
          expect(find.byTooltip('식물 사진 확대'), findsOneWidget);
          expect(client.requests, [url, url]);
          expect(tester.takeException(), isNull);
        } finally {
          debugNetworkImageHttpClientProvider = null;
        }
      },
    );
  }

  testWidgets('PlantCareSummary와 PlantInfoSection은 관리 정보를 표시한다', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildRouterApp(
        const Column(
          children: [
            PlantCareSummary(
              name: '몬테',
              daysTogether: 3,
              dDayLabel: 'D-2',
              startDate: '2026.06.01',
              lastWateredDate: '2026.06.20',
            ),
            PlantInfoSection(wateringCycleLabel: '10 Day'),
          ],
        ),
      ),
    );

    expect(find.text('D-2'), findsOneWidget);
    expect(find.text('처음 함께한 날'), findsOneWidget);
    expect(find.text('마지막으로 물 준 날짜'), findsOneWidget);
    expect(find.text('2026.06.01'), findsOneWidget);
    expect(find.text('2026.06.20'), findsOneWidget);
    expect(find.text('식물정보'), findsOneWidget);
    expect(find.text('10 Day'), findsOneWidget);
  });

  testWidgets('원격 관리 정보가 없으면 지원 범위를 명확히 표시한다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        const Column(
          children: [
            PlantCareSummary(
              name: '필로덴드론',
              daysTogether: null,
              dDayLabel: null,
              startDate: null,
              lastWateredDate: null,
            ),
            PlantInfoSection(
              wateringCycleLabel: null,
              plantInfo: '반양지에서 관리해 주세요.',
            ),
          ],
        ),
      ),
    );

    expect(find.text('필로덴드론와 함께한 기간 정보가 없어요'), findsOneWidget);
    expect(find.text('물주기 예정 정보 없음'), findsOneWidget);
    expect(find.text('정보 없음'), findsNWidgets(2));
    expect(find.text('물주기 주기 정보 없음'), findsOneWidget);
    expect(find.text('반양지에서 관리해 주세요.'), findsOneWidget);
  });

  testWidgets('MemoPreviewSection은 메모를 표시하고 목록/작성으로 이동한다', (tester) async {
    const memoSection = MemoPreviewSection(
      plantId: 'plant-1',
      memos: [
        PlantDetailMemoItem(
          author: '커먼맘',
          content: '오늘은 잎 상태가 좋아요',
          dateLabel: '2026.06.20',
        ),
      ],
    );

    await tester.pumpWidget(_buildRouterApp(memoSection));

    expect(find.text('Memo'), findsOneWidget);
    expect(find.text('커먼맘'), findsOneWidget);
    expect(find.text('오늘은 잎 상태가 좋아요'), findsOneWidget);
    expect(find.text('2026.06.20'), findsOneWidget);
    expect(find.text('작성하기'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('메모 전체보기'));
    await tester.pumpAndSettle();

    expect(find.text('메모 목록 화면'), findsOneWidget);

    await tester.pumpWidget(_buildRouterApp(memoSection));
    await tester.tap(find.text('작성하기'));
    await tester.pumpAndSettle();

    expect(find.text('메모 작성 화면'), findsOneWidget);
  });

  testWidgets('원격 Memo는 대표 메모만 표시하고 미지원 동작을 숨긴다', (tester) async {
    await tester.pumpWidget(
      _buildRouterApp(
        const MemoPreviewSection(
          plantId: 'plant-1',
          memos: [],
          representativeMemo: '서버 대표 메모',
          supportsActions: false,
        ),
      ),
    );

    expect(find.text('대표 메모'), findsOneWidget);
    expect(find.text('서버 대표 메모'), findsOneWidget);
    expect(find.text('메모 목록과 작성 API는 아직 제공되지 않아요.'), findsOneWidget);
    expect(find.bySemanticsLabel('메모 전체보기'), findsNothing);
    expect(find.text('작성하기'), findsNothing);
  });
}

class _PhotoClient extends Fake implements HttpClient {
  _PhotoClient(this.responses);

  final List<Future<HttpClientResponse>> responses;
  final List<Uri> requests = [];

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    final response = responses[requests.length];
    requests.add(url);
    return _PhotoRequest(response);
  }
}

class _PhotoRequest extends Fake implements HttpClientRequest {
  _PhotoRequest(this.response);

  final Future<HttpClientResponse> response;

  @override
  Future<HttpClientResponse> close() => response;
}

class _PhotoResponse extends Stream<List<int>> implements HttpClientResponse {
  _PhotoResponse(this.statusCode, [this.bytes = const []]);

  final List<int> bytes;

  @override
  final int statusCode;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildRouterApp(Widget home) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Scaffold(body: SingleChildScrollView(child: home)),
      ),
      GoRoute(
        path: '/plants/:plantId/memos/new',
        builder: (context, state) => const Text('메모 작성 화면'),
      ),
      GoRoute(
        path: '/plants/:plantId/memos',
        builder: (context, state) => const Text('메모 목록 화면'),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}
