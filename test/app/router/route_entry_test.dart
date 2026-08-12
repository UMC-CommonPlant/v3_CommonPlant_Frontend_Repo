import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('Figma 기준 route-level screen이 모두 실제 화면으로 진입된다', (
    WidgetTester tester,
  ) async {
    final locations = <String>[
      AppRoutePaths.home,
      AppRoutePaths.onboarding,
      AppRoutePaths.login,
      AppRoutePaths.profileSetup,
      AppRoutePaths.terms,
      AppRoutePaths.placeInvitations,
      AppRoutePaths.placeCreate,
      AppRoutePaths.addressSearch,
      AppRoutePaths.placeFriendAdd,
      AppRoutePaths.placeEditLocation('place-1'),
      AppRoutePaths.friendManagementLocation('place-1'),
      AppRoutePaths.placeDetailLocation('place-1'),
      AppRoutePaths.plantSearch,
      AppRoutePaths.plantCreateDetails,
      AppRoutePaths.plantEditLocation('plant-1'),
      AppRoutePaths.memoWriteLocation('plant-1'),
      AppRoutePaths.memoListLocation('plant-1'),
      AppRoutePaths.plantDetailLocation('plant-1'),
    ];

    for (final location in locations) {
      final router = createAppRouter(initialLocation: location);

      await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
      await tester.pumpAndSettle();

      expect(find.text('라우트 준비 중'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    }
  });

  testWidgets('place detail route가 실제 화면을 표시한다', (WidgetTester tester) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.placeDetailLocation('place-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsOneWidget);
    expect(find.text('스윗 홈_거실'), findsOneWidget);
    expect(find.text('서울시 노원구 광운로 20'), findsOneWidget);
    expect(find.text('라우트 준비 중'), findsNothing);
  });

  testWidgets('memo route가 실제 작성 화면을 표시한다', (WidgetTester tester) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.memoWriteLocation('plant-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    expect(find.text('메모 작성'), findsOneWidget);
    expect(find.text('메모 내용을 입력해 주세요'), findsOneWidget);
    expect(find.text('라우트 준비 중'), findsNothing);
  });
}
