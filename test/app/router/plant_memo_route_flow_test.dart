import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('plant search에서 식물 등록 정보 입력으로 이동한다', (WidgetTester tester) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.plantSearch);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '몬스테라');
    await tester.pumpAndSettle();
    await tester.tap(find.text('몬스테라 델리오사'));
    await tester.pumpAndSettle();

    expect(find.text('식물 등록 (2/2)'), findsOneWidget);
    expect(find.text('장소 선택'), findsOneWidget);
    expect(find.text('마지막으로 물 준 날짜'), findsOneWidget);
  });

  testWidgets('plant detail에서 식물 수정, 메모 목록, 메모 작성으로 이동한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.plantDetailLocation('plant-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('수정하기'));
    await tester.pumpAndSettle();

    expect(find.text('식물 수정'), findsOneWidget);
    expect(find.text('몬테'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.bySemanticsLabel('메모 전체보기'));
    await tester.tap(find.bySemanticsLabel('메모 전체보기'));
    await tester.pumpAndSettle();

    expect(find.text('Memo'), findsOneWidget);
    expect(find.text('커먼플랜트'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('작성하기'));
    await tester.tap(find.text('작성하기'));
    await tester.pumpAndSettle();

    expect(find.text('메모 내용을 입력해 주세요'), findsOneWidget);
  });

  testWidgets('memo list에서 메모 작성과 삭제 dialog를 표시한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.memoListLocation('plant-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('작성하기'));
    await tester.pumpAndSettle();

    expect(find.text('메모 작성'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('게시물 삭제'), findsOneWidget);
  });
}
