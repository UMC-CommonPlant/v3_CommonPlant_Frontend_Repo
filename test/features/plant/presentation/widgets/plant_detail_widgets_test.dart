import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_care_summary.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_content_width.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_hero.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_info_section.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_memo_preview_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
  });

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
