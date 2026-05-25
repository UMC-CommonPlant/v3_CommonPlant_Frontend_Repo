import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('식물 등록 검색 전에는 결과를 표시하지 않는다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlantSearchPage()));

    expect(find.text('식물 등록  (1/2)'), findsOneWidget);
    expect(find.text('식물을 입력해 주세요.'), findsOneWidget);
    expect(find.text('몬스테라 델리오사'), findsNothing);
    expect(find.text('검색 결과가 없어요'), findsNothing);
  });

  testWidgets('식물 검색어를 입력하면 Figma 기준 결과 목록을 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlantSearchPage()));

    await tester.enterText(find.byType(TextField), '몬스테라');
    await tester.pump();

    expect(find.text('몬스테라 델리오사'), findsOneWidget);
    expect(find.text('몬스테라 알보 바리에가타'), findsOneWidget);
    expect(find.text('몬스테라 보르시지아나'), findsOneWidget);
    expect(find.text('무늬 몬스테라'), findsOneWidget);
    expect(find.text('검색 결과가 없어요'), findsNothing);
  });

  testWidgets('식물 검색 결과가 없으면 빈 상태 안내를 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlantSearchPage()));

    await tester.enterText(find.byType(TextField), '선인장');
    await tester.pump();

    expect(find.text('검색 결과가 없어요'), findsOneWidget);
    expect(find.text('다른 이름으로 다시 검색해 주세요'), findsOneWidget);
    expect(find.text('몬스테라 델리오사'), findsNothing);
  });

  testWidgets('식물 검색 결과를 선택하면 등록 정보 입력 화면으로 이동한다', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.plantSearch);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '몬스테라');
    await tester.pumpAndSettle();
    await tester.tap(find.text('몬스테라 델리오사'));
    await tester.pumpAndSettle();

    expect(find.text('식물 등록 (2/2)'), findsOneWidget);
    expect(find.text('장소 선택'), findsOneWidget);
  });

  testWidgets('검색어 삭제를 누르면 결과 목록을 닫는다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlantSearchPage()));

    await tester.enterText(find.byType(TextField), '몬스테라');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('검색어 삭제'));
    await tester.pump();

    expect(find.text('몬스테라 델리오사'), findsNothing);
  });
}
