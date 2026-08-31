import 'dart:async';

import 'package:commonplant_frontend/app/router/app_routes.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_place_code_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_viewport.dart';
import '../../helpers/user_data_session.dart';

void main() {
  testWidgets('Home처럼 장소 code 없이 상세 진입하면 plant ID로 상세 code를 복원한다', (
    tester,
  ) async {
    configureTestViewport(tester, TestViewports.reference);
    final repository = _EditRepository();
    final placeRepository = _ResolverPlaceRepository();
    late ProviderContainer container;
    final router = await _pumpRoutes(
      tester,
      repository,
      AppRoutePaths.plantDetailLocation('1'),
      placeRepository: placeRepository,
      onContainer: (value) => container = value,
    );
    await tester.pumpAndSettle();

    expect(placeRepository.detailCodes, ['PLACE-A', 'PLACE-B']);
    expect(
      container.read(remotePlantPlaceCodeProvider('1')).requireValue,
      'PLACE-B',
    );
    expect(
      container
          .read(plantDetailViewProvider((plantId: '1', placeCode: null)))
          .requireValue
          ?.placeCode,
      'PLACE-B',
    );
    expect(router.routeInformationProvider.value.uri.path, '/plants/1');
    expect(
      router.routeInformationProvider.value.uri.queryParameters['placeId'],
      isNull,
    );
    expect(find.byTooltip('식물 상세 메뉴'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (viewport: TestViewports.reference, code: null),
    (viewport: TestViewports.compactWidth, code: null),
    (viewport: TestViewports.shortHeight, code: null),
    (viewport: TestViewports.reference, code: ''),
    (viewport: TestViewports.reference, code: ' \t '),
  ]) {
    testWidgets('장소 query 누락·빈 값은 안내 후 홈으로 복귀한다 ($scenario)', (tester) async {
      configureTestViewport(tester, scenario.viewport);
      final repository = _EditRepository();
      final router = await _pumpRoutes(
        tester,
        repository,
        AppRoutePaths.plantEditLocation('1', placeId: scenario.code),
      );
      await tester.pumpAndSettle();

      expect(find.text('장소 정보를 확인할 수 없어요'), findsOneWidget);
      expect(find.text('장소에서 식물을 선택한 뒤 다시 수정해 주세요'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.widgetWithText(FilledButton, '완료'), findsNothing);
      expect(find.text('다시 시도'), findsNothing);
      expect(repository.editReads, 0);
      expect(repository.detailReads, 0);
      expect(repository.requests, isEmpty);
      await tester.tap(find.widgetWithText(OutlinedButton, '홈으로'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutePaths.home,
      );
      expect(find.text('테스트 홈'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final viewport in [
    TestViewports.reference,
    TestViewports.compactWidth,
    TestViewports.shortHeight,
  ]) {
    testWidgets('상세의 장소 code로 수정하고 새 날짜·애칭을 다시 조회한다 ($viewport)', (
      tester,
    ) async {
      configureTestViewport(tester, viewport);
      final repository = _EditRepository()..barrier = Completer<void>();
      final router = await _pumpRoutes(
        tester,
        repository,
        AppRoutePaths.plantDetailLocation('1', placeId: ' PLACE-A '),
      );
      await tester.pumpAndSettle();
      expect(find.text('2026.08.20'), findsOneWidget);
      await tester.tap(find.byTooltip('식물 상세 메뉴'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('수정하기'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.queryParameters['placeId'],
        ' PLACE-A ',
      );
      await tester.enterText(find.byType(TextField), '수정 애칭');
      final dateField = find.text('2026. 08. 20');
      await tester.ensureVisible(dateField);
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      tester
          .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
          .onDateChanged(DateTime(2026, 8, 28));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final button = find.widgetWithText(FilledButton, '완료');
      final staleSubmit = tester.widget<FilledButton>(button).onPressed!;
      await tester.tap(button);
      await tester.pump();
      staleSubmit();
      await tester.pump();
      expect(repository.requests, hasLength(1));
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      repository.barrier!.complete();
      await tester.pumpAndSettle();

      expect(repository.requests.single, (
        code: 'PLACE-A',
        name: '수정 애칭',
        imageKey: 'images/keep.png',
        date: '2026-08-28',
      ));
      expect(router.routeInformationProvider.value.uri.path, '/plants/1');
      expect(
        router.routeInformationProvider.value.uri.queryParameters['placeId'],
        'PLACE-A',
      );
      expect(find.text('2026.08.28'), findsOneWidget);
      expect(find.text('2026.08.20'), findsNothing);
      expect(repository.detailReads, 2);

      await tester.tap(find.byTooltip('식물 상세 메뉴'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('수정하기'));
      await tester.pumpAndSettle();
      expect(find.text('수정 애칭'), findsOneWidget);
      expect(find.text('2026. 08. 28'), findsOneWidget);
      expect(repository.editReads, 2);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('수정 실패는 이동하지 않고 초안을 보존하며 재시도 성공 뒤에만 이동한다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final repository = _EditRepository()..barrier = Completer<void>();
    final router = await _pumpRoutes(
      tester,
      repository,
      AppRoutePaths.plantEditLocation('1', placeId: 'PLACE-A'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '첫 수정');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pump();
    expect(repository.requests, hasLength(1));
    repository.barrier!.completeError(StateError('raw failure'));
    await tester.pumpAndSettle();

    expect(find.byType(PlantFormPage), findsOneWidget);
    expect(find.text('식물 수정에 실패했어요'), findsOneWidget);
    expect(find.textContaining('raw failure'), findsNothing);
    expect(find.text('첫 수정'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/plants/1/edit');
    expect(repository.detailReads, 0);
    expect(repository.editReads, 1);
    await tester.pump(tester.widget<SnackBar>(find.byType(SnackBar)).duration);
    await tester.pumpAndSettle();
    repository.barrier = null;
    await tester.enterText(find.byType(TextField), '재시도 수정');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '완료'));
    await tester.pumpAndSettle();

    expect(repository.requests.map((request) => request.name), [
      '첫 수정',
      '재시도 수정',
    ]);
    expect(router.routeInformationProvider.value.uri.path, '/plants/1');
    expect(find.byType(PlantFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<GoRouter> _pumpRoutes(
  WidgetTester tester,
  _EditRepository repository,
  String location, {
  PlaceRepository? placeRepository,
  void Function(ProviderContainer)? onContainer,
}) async {
  final container = ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      plantRepositoryProvider.overrideWithValue(repository),
      if (placeRepository != null)
        placeRepositoryProvider.overrideWithValue(placeRepository),
    ],
  );
  onContainer?.call(container);
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: location,
    routes: [
      // 수정·상세는 production route builder와 query 전달을 그대로 검증한다.
      ...buildAppRoutes().whereType<GoRoute>().where(
        (route) =>
            route.name == AppRouteNames.plantEdit ||
            route.name == AppRouteNames.plantDetail,
      ),
      GoRoute(
        path: AppRoutePaths.home,
        builder: (context, state) => const Scaffold(body: Text('테스트 홈')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  return router;
}

class _ResolverPlaceRepository extends Fake implements PlaceRepository {
  final List<String> detailCodes = [];

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    return const [
      PlaceSummary(id: 'PLACE-A', name: '같은 장소명'),
      PlaceSummary(id: 'PLACE-B', name: '같은 장소명'),
    ];
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    detailCodes.add(code);
    return PlaceDetail(
      code: code,
      name: '같은 장소명',
      address: '주소',
      isOwner: true,
      members: const [],
      plants: [
        PlacePlant(
          id: code == 'PLACE-B' ? '1' : 'other-plant',
          scientificNameKo: '몬스테라',
        ),
      ],
    );
  }
}

class _EditRepository extends Fake implements PlantRepository {
  int detailReads = 0;
  int editReads = 0;
  String savedName = '기존 애칭';
  String savedDate = '2026-08-20';
  Completer<void>? barrier;
  final requests =
      <({String code, String? name, String? imageKey, String? date})>[];

  @override
  Future<PlantDetail> fetchPlant({required String plantId}) async {
    detailReads++;
    return PlantDetail(
      id: plantId,
      name: '몬스테라',
      placeName: '정원',
      lastWateredDate: savedDate,
    );
  }

  @override
  Future<PlantEditInfo> fetchPlantEditInfo({required String plantId}) async {
    editReads++;
    return PlantEditInfo(
      name: savedName,
      lastWateredDate: savedDate,
      imageKey: 'images/keep.png',
    );
  }

  @override
  Future<void> updatePlant({
    required String plantId,
    required String placeCode,
    String? imageKey,
    String? nickname,
    String? lastWateredDate,
  }) async {
    requests.add((
      code: placeCode,
      name: nickname,
      imageKey: imageKey,
      date: lastWateredDate,
    ));
    await barrier?.future;
    savedName = nickname ?? savedName;
    savedDate = lastWateredDate ?? savedDate;
  }
}
