import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Figma 기준 route-level screen 18개를 등록한다', () {
    expect(appRouteSpecs, hasLength(18));
    expect(appRouteSpecs.map((route) => route.name).toSet(), hasLength(18));
    expect(appRouteSpecs.map((route) => route.path).toSet(), hasLength(18));
  });

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appRouterProvider.overrideWithValue(router)],
          child: const CommonPlantApp(),
        ),
      );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('메모 작성'), findsOneWidget);
    expect(find.text('오늘 식물 상태는 어땠나요?'), findsOneWidget);
    expect(find.text('라우트 준비 중'), findsNothing);
  });

  testWidgets('onboarding 시작 플로우가 profile, terms, home으로 이어진다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.onboarding);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('시작하기'));
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text('Apple로 로그인'), findsOneWidget);

    await tester.tap(find.text('카카오로 로그인'));
    await tester.pumpAndSettle();

    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '초록');
    await tester.tapAt(const Offset(24, 24));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('완료'));
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('개인정보 이용약관'), findsOneWidget);

    await tester.tap(find.text('동의합니다'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('확인'));
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsOneWidget);
    expect(find.text('My plant'), findsOneWidget);
  });

  testWidgets('약관 보기에서 동의하면 프로필 설정 체크 상태로 돌아온다', (WidgetTester tester) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.profileSetup);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('보기'));
    await tester.pumpAndSettle();

    expect(find.text('개인정보 이용약관'), findsOneWidget);

    await tester.tap(find.text('동의합니다'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
    expect(find.bySemanticsLabel('개인정보 이용약관 동의됨'), findsOneWidget);
  });

  testWidgets('home에서 장소 등록 화면으로 이동한다', (WidgetTester tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '옥상 정원');
    await tester.pump();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('친구 추가'), findsOneWidget);

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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
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

    expect(find.text('식물 상세'), findsOneWidget);
  });

  testWidgets('plant search에서 식물 등록 정보 입력으로 이동한다', (WidgetTester tester) async {
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
    expect(find.text('마지막으로 물 준 날짜'), findsOneWidget);
  });

  testWidgets('plant detail에서 식물 수정, 메모 목록, 메모 작성으로 이동한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.plantDetailLocation('plant-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(IconButton).last);
    await tester.pumpAndSettle();

    expect(find.text('식물 수정'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('전체보기'));
    await tester.tap(find.text('전체보기'));
    await tester.pumpAndSettle();

    expect(find.text('메모'), findsOneWidget);
    expect(find.text('총 3개의 메모'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('메모 작성'));
    await tester.tap(find.text('메모 작성'));
    await tester.pumpAndSettle();

    expect(find.text('오늘 식물 상태는 어땠나요?'), findsOneWidget);
  });

  testWidgets('memo list에서 메모 작성과 삭제 dialog를 표시한다', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      initialLocation: AppRoutePaths.memoListLocation('plant-1'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const CommonPlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('작성'));
    await tester.pumpAndSettle();

    expect(find.text('메모 작성'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('메모를 삭제할까요?'), findsOneWidget);
  });
}
