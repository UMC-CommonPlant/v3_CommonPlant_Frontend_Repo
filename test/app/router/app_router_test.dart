import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Figma 기준 route-level screen 17개를 등록한다', () {
    expect(appRouteSpecs, hasLength(17));
    expect(appRouteSpecs.map((route) => route.name).toSet(), hasLength(17));
    expect(appRouteSpecs.map((route) => route.path).toSet(), hasLength(17));
  });

  testWidgets('placeholder route가 path parameter를 표시한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.placeDetailLocation('place-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('장소 상세'), findsOneWidget);
    expect(find.text('라우트 준비 중'), findsOneWidget);
    expect(find.text('placeId: place-1'), findsOneWidget);
  });

  testWidgets('memo route가 plantId path parameter를 표시한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.memoWriteLocation('plant-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('메모 작성'), findsOneWidget);
    expect(find.text('라우트 준비 중'), findsOneWidget);
    expect(find.text('plantId: plant-1'), findsOneWidget);
  });
}
