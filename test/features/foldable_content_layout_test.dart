import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_body.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_frame.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_view_data.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_detail_page.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_view_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_detail_header.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_plant_list.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_detail_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_hero.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_memo_preview_section.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_viewport.dart';

void main() {
  testWidgets('홈은 펼친 폭에서 두 섹션을 나란히 배치하고 배경을 늘리지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    await tester.pumpWidget(_homeApp());
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('My place')).dx, AppSizes.iconSmall);
    expect(
      tester.getTopLeft(find.text('My plant')).dy,
      greaterThan(tester.getTopLeft(find.text('My place')).dy),
    );

    _resize(tester, const Size(1000, 700));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('My plant')).dy,
      tester.getTopLeft(find.text('My place')).dy,
    );
    expect(
      tester.getTopLeft(find.text('My plant')).dx,
      greaterThan(tester.getTopLeft(find.text('My place')).dx),
    );
    expect(
      tester.getSize(find.bySemanticsLabel('메인 배경')).width,
      AppSizes.mobileWidth,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈의 낮은 창에서는 배너를 스크롤해 두 섹션에 접근한다', (tester) async {
    configureTestViewport(tester, const Size(375, 280));
    await tester.pumpWidget(_homeApp());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text('My plant').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈 크기 변경은 조회와 세로 스크롤 상태를 재생성하지 않는다', (tester) async {
    configureTestViewport(tester, const Size(375, 600));
    var placeReads = 0;
    var plantReads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeSummariesProvider.overrideWith((ref) {
            placeReads++;
            return AsyncData([
              for (var index = 0; index < 8; index++)
                PlaceSummary(id: 'place-$index', name: '장소 $index'),
            ]);
          }),
          plantSummariesProvider.overrideWith((ref) {
            plantReads++;
            return const AsyncData([]);
          }),
          placeInvitationRequestCountProvider.overrideWithValue(
            const AsyncData(0),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: HomeFrame())),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = _homeScrollable(tester);
    scrollable.position.jumpTo(100);
    await tester.pump();

    _resize(tester, const Size(800, 600));
    await tester.pumpAndSettle();
    expect(_homeScrollable(tester), same(scrollable));
    expect(scrollable.position.pixels, 100);
    expect(placeReads, 1);
    expect(plantReads, 1);

    _resize(tester, const Size(375, 600));
    await tester.pumpAndSettle();
    expect(_homeScrollable(tester), same(scrollable));
    expect(scrollable.position.pixels, 100);
    expect(tester.takeException(), isNull);
  });

  for (final state in <AsyncValue<List<PlaceSummary>>>[
    const AsyncLoading(),
    AsyncError(StateError('조회 실패'), StackTrace.empty),
  ]) {
    testWidgets('낮은 홈 창에서 조회 상태를 스크롤할 수 있다 ($state)', (tester) async {
      configureTestViewport(tester, const Size(375, 280));
      await tester.pumpWidget(_homeApp(placeState: state));
      await tester.pump();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      if (state.isLoading) {
        expect(
          find.byType(CircularProgressIndicator).hitTestable(),
          findsOneWidget,
        );
      } else {
        expect(find.text('데이터를 불러오지 못했어요').hitTestable(), findsOneWidget);
      }
    });
  }

  testWidgets('장소 상세는 같은 조회와 스크롤을 유지하며 헤더와 식물을 재배치한다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    var detailReads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeDetailViewProvider((
            placeId: 'layout-place',
            role: null,
          )).overrideWith((ref) {
            detailReads++;
            final detail = placeDetailFixture('layout-place');
            return AsyncData(
              PlaceDetailViewData(
                role: detail.role,
                name: detail.name,
                address: detail.address,
                friends: detail.friends,
                plants: [...detail.plants, ...detail.plants, ...detail.plants],
              ),
            );
          }),
        ],
        child: const MaterialApp(
          home: PlaceDetailPage(placeId: 'layout-place'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = _pageScrollable(tester);
    expect(scrollable.position.maxScrollExtent, greaterThan(60));
    scrollable.position.jumpTo(60);
    await tester.pump();

    _resize(tester, const Size(1120, 400));
    await tester.pumpAndSettle();

    expect(_pageScrollable(tester), same(scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(60));
    expect(scrollable.position.pixels, 60);
    expect(detailReads, 1);
    final header = tester.getRect(find.byType(PlaceDetailHeader));
    final plants = tester.getRect(find.byType(PlacePlantList));
    expect(header.width, AppSizes.mobileWidth);
    expect(plants.top, header.top);
    expect(plants.left, greaterThanOrEqualTo(header.right));
    final cards = find.byType(CommonPlacePlantCard);
    expect(
      tester.getTopLeft(cards.at(0)).dy,
      tester.getTopLeft(cards.at(1)).dy,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('식물 상세는 같은 조회와 스크롤을 유지하며 정보와 메모를 재배치한다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    var detailReads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantDetailViewProvider((
            plantId: 'layout-plant',
            placeCode: null,
          )).overrideWith((ref) {
            detailReads++;
            return AsyncData(plantDetailFixture());
          }),
        ],
        child: const MaterialApp(
          home: PlantDetailPage(plantId: 'layout-plant'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = _pageScrollable(tester);
    expect(
      tester.getTopLeft(find.byType(MemoPreviewSection)).dy,
      greaterThan(tester.getTopLeft(find.byType(PlantHero)).dy),
    );

    _resize(tester, const Size(1000, 700));
    await tester.pumpAndSettle();

    expect(_pageScrollable(tester), same(scrollable));
    expect(detailReads, 1);
    final hero = tester.getRect(find.byType(PlantHero));
    final memos = tester.getRect(find.byType(MemoPreviewSection));
    expect(memos.top, hero.top);
    expect(memos.left, greaterThanOrEqualTo(hero.right));
    expect(tester.takeException(), isNull);
  });

  for (final viewport in [const Size(320, 280), const Size(1000, 700)]) {
    for (final state in <AsyncValue<PlaceDetailViewData?>>[
      const AsyncLoading(),
      const AsyncData(null),
      AsyncError(StateError('조회 실패'), StackTrace.empty),
      const AsyncData(
        PlaceDetailViewData(
          role: PlaceDetailRole.leader,
          name: '등록된 식물 없는 장소',
          address: '',
          friends: [],
          plants: [],
        ),
      ),
    ]) {
      testWidgets('장소 상세 상태가 가용 영역을 넘지 않는다 ($viewport, $state)', (
        tester,
      ) async {
        configureTestViewport(tester, viewport);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              placeDetailViewProvider((
                placeId: 'layout-place',
                role: null,
              )).overrideWithValue(state),
            ],
            child: const MaterialApp(
              home: PlaceDetailPage(placeId: 'layout-place'),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
    for (final state in <AsyncValue<PlantDetailViewData?>>[
      const AsyncLoading(),
      const AsyncData(null),
      AsyncError(StateError('조회 실패'), StackTrace.empty),
    ]) {
      testWidgets('식물 상세 상태가 가용 영역을 넘지 않는다 ($viewport, $state)', (
        tester,
      ) async {
        configureTestViewport(tester, viewport);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              plantDetailViewProvider((
                plantId: 'layout-plant',
                placeCode: null,
              )).overrideWithValue(state),
            ],
            child: const MaterialApp(
              home: PlantDetailPage(plantId: 'layout-plant'),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Widget _homeApp({
  AsyncValue<List<PlaceSummary>> placeState = const AsyncData([]),
}) {
  return ProviderScope(
    overrides: [
      placeSummariesProvider.overrideWithValue(placeState),
      plantSummariesProvider.overrideWithValue(
        const AsyncData(<PlantSummary>[]),
      ),
      placeInvitationRequestCountProvider.overrideWithValue(const AsyncData(0)),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeFrame())),
  );
}

ScrollableState _homeScrollable(WidgetTester tester) => tester.state(
  find
      .descendant(of: find.byType(HomeBody), matching: find.byType(Scrollable))
      .first,
);

ScrollableState _pageScrollable(WidgetTester tester) => tester.state(
  find
      .descendant(
        of: find.byType(SingleChildScrollView).first,
        matching: find.byType(Scrollable),
      )
      .first,
);

void _resize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
}
