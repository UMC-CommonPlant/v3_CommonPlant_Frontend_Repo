import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_friend_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('home에서 장소 등록 화면으로 이동한다', (WidgetTester tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('장소 추가하기'));
    await tester.pumpAndSettle();

    expect(find.text('장소 등록'), findsOneWidget);
    expect(find.text('장소의 이름을 입력해 주세요'), findsOneWidget);
  });

  testWidgets('장소 등록 다음 단계 후 홈에 장소가 추가되고 식물 추가가 활성화된다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.placeCreate);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('친구 추가'), findsOneWidget);
    expect(
      tester
          .widget<PlaceFriendAddPage>(find.byType(PlaceFriendAddPage))
          .placeCode,
      'place-1',
    );

    await tester.ensureVisible(find.text('완료'));
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsOneWidget);
    expect(find.text('옥상 정원'), findsOneWidget);
    expect(find.text('장소 추가하기'), findsNothing);
    expect(find.bySemanticsLabel('장소 추가'), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('장소 추가')), const Size(24, 24));

    await tester.ensureVisible(find.text('식물 추가하기'));
    await tester.tap(find.text('식물 추가하기'));
    await tester.pumpAndSettle();

    expect(find.text('식물 등록  (1/2)'), findsOneWidget);
  });

  testWidgets('식물 등록 후 홈에서 식물 추가 카드 대신 헤더 +를 표시한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.placeCreate);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('완료'));
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('식물 추가하기'));
    await tester.tap(find.text('식물 추가하기'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '몬스테라');
    await tester.pumpAndSettle();
    await tester.tap(find.text('몬스테라 델리오사'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('등록'));
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();

    expect(find.text('My plant'), findsOneWidget);
    expect(find.text('식물 추가하기'), findsNothing);
    expect(find.bySemanticsLabel('식물 추가'), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('식물 추가')), const Size(24, 24));
    expect(find.bySemanticsLabel('몬스테라 델리오사'), findsOneWidget);
  });

  testWidgets('place form에서 주소 검색과 친구 추가 화면으로 이동한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.placeCreate);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('주소'));
    await tester.pumpAndSettle();

    expect(find.text('주소 검색'), findsOneWidget);
    expect(find.text('신도림역'), findsOneWidget);
    expect(find.text('신도림역 1호선', findRichText: true), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('친구 추가'), findsOneWidget);
    expect(
      tester
          .widget<PlaceFriendAddPage>(find.byType(PlaceFriendAddPage))
          .placeCode,
      'place-1',
    );
    expect(find.text('닉네임 검색'), findsOneWidget);
    expect(find.text('커먼 파파'), findsNothing);

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pumpAndSettle();

    expect(find.text('커먼 파파'), findsWidgets);
  });

  testWidgets('place detail에서 수정, 친구관리, 식물상세로 이동한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.placeDetailLocation('place-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소 수정하기'));
    await tester.pumpAndSettle();

    expect(find.text('장소 수정'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('친구 관리'));
    await tester.pumpAndSettle();

    expect(find.text('친구 관리'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('몬테').first);
    await tester.tap(find.text('몬테').first);
    await tester.pumpAndSettle();

    expect(find.text('My plant'), findsOneWidget);
  });
}
