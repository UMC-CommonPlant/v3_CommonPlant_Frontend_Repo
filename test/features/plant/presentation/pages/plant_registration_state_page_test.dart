import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

const _places = [
  PlaceSummary(id: 'API-A', name: '실제 온실'),
  PlaceSummary(id: 'API-B', name: '실제 정원'),
];

void main() {
  for (final viewport in [
    TestViewports.reference,
    TestViewports.compactWidth,
    TestViewports.shortHeight,
    TestViewports.wide,
  ]) {
    testWidgets('장소 로딩·오류·실제 재시도 후 서버 장소로 등록한다 ($viewport)', (tester) async {
      configureTestViewport(tester, viewport);
      final places = _ControlledPlaceRepository();
      final plants = _RecordingPlantRepository();
      await _pumpPage(tester, places, plants);

      expect(find.text('등록할 장소를 불러오고 있어요'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      _expectRegistrationUnavailable(plants);

      places.requests.single.completeError(StateError('raw failure'));
      await tester.pumpAndSettle();
      expect(find.text('등록할 장소를 불러오지 못했어요'), findsOneWidget);
      expect(find.textContaining('raw failure'), findsNothing);
      _expectRegistrationUnavailable(plants);
      await tester.pump(const Duration(seconds: 5));
      expect(places.requests, hasLength(1));

      await tester.tap(find.widgetWithText(OutlinedButton, '다시 시도'));
      await tester.pump();
      expect(find.text('등록할 장소를 불러오고 있어요'), findsOneWidget);
      expect(places.requests, hasLength(2));
      _expectRegistrationUnavailable(plants);

      places.requests.last.complete(_places);
      await tester.pumpAndSettle();
      expect(find.byType(PlantCreateScaffold), findsOneWidget);
      expect(find.text('실제 온실'), findsOneWidget);
      expect(find.text('실제 정원'), findsOneWidget);
      _expectNoFixtures();
      final nextPlace = find.text('실제 정원');
      await tester.ensureVisible(nextPlace);
      await tester.pump();
      await tester.tap(nextPlace);
      await tester.pump();
      expect(
        tester
            .widget<PlantCreateScaffold>(find.byType(PlantCreateScaffold))
            .selectedPlaceId,
        'API-B',
      );

      await tester.tap(find.widgetWithText(FilledButton, '등록'));
      await tester.pumpAndSettle();
      expect(plants.codes, ['API-B']);
      expect(plants.names, ['선택한 식물']);
      expect(find.text('테스트 홈'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('빈 장소 목록은 등록 대신 홈 안내를 표시한다 ($viewport)', (tester) async {
      configureTestViewport(tester, viewport);
      final places = _ControlledPlaceRepository();
      final plants = _RecordingPlantRepository();
      await _pumpPage(tester, places, plants);
      places.requests.single.complete([]);
      await tester.pumpAndSettle();

      expect(find.text('등록할 장소가 없어요'), findsOneWidget);
      expect(find.text('홈에서 장소를 먼저 등록해 주세요'), findsOneWidget);
      _expectRegistrationUnavailable(plants);
      await tester.tap(find.widgetWithText(OutlinedButton, '홈으로'));
      await tester.pumpAndSettle();
      expect(find.text('테스트 홈'), findsOneWidget);
      expect(plants.codes, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('목록 재조회 직후 이전 등록 버튼 콜백도 요청을 보내지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = await _pumpPage(tester, places, plants);
    places.requests.single.complete(_places);
    await tester.pumpAndSettle();
    final staleSubmit = tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, '등록'))
        .onPressed!;

    container.invalidate(userPlaceSummariesProvider);
    // 아직 이전 버튼이 화면에 남아 있는 프레임에서도 검증해야 한다.
    staleSubmit();
    await tester.pump();
    expect(find.text('등록할 장소를 불러오고 있어요'), findsOneWidget);
    _expectRegistrationUnavailable(plants);
    places.requests.last.complete([]);
    await tester.pumpAndSettle();
    staleSubmit();
    await tester.pumpAndSettle();
    expect(find.text('등록할 장소가 없어요'), findsOneWidget);
    _expectRegistrationUnavailable(plants);
    expect(find.text('테스트 홈'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('B 계정 장소 로딩·오류 중 A의 장소를 보여주지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    final places = _ControlledPlaceRepository();
    final plants = _RecordingPlantRepository();
    final container = await _pumpPage(tester, places, plants);
    places.requests.single.complete(_places);
    await tester.pumpAndSettle();
    expect(find.text('실제 온실'), findsOneWidget);

    container.read(userDataSessionProvider.notifier).start();
    await tester.pump();
    expect(find.text('등록할 장소를 불러오고 있어요'), findsOneWidget);
    expect(find.text('실제 온실'), findsNothing);
    expect(find.text('실제 정원'), findsNothing);
    _expectRegistrationUnavailable(plants);
    places.requests.last.completeError(StateError('B 조회 실패'));
    await tester.pumpAndSettle();
    expect(find.text('등록할 장소를 불러오지 못했어요'), findsOneWidget);
    _expectRegistrationUnavailable(plants);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    expect(places.requests, hasLength(3));
    places.requests.last.complete([
      const PlaceSummary(id: 'B-ONLY', name: 'B 장소'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('B 장소'), findsOneWidget);
    expect(find.text('실제 온실'), findsNothing);
    expect(find.text('실제 정원'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, '등록'));
    await tester.pumpAndSettle();
    expect(plants.codes, ['B-ONLY']);
    expect(tester.takeException(), isNull);
  });
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester,
  PlaceRepository places,
  PlantRepository plants,
) async {
  final container = ProviderContainer(
    overrides: [
      authenticatedUserDataSession,
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(places),
      plantRepositoryProvider.overrideWithValue(plants),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: AppRoutePaths.plantCreateDetails,
    routes: [
      GoRoute(
        path: AppRoutePaths.plantCreateDetails,
        builder: (context, state) =>
            const PlantFormPage(initialPlantName: '선택한 식물'),
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
  return container;
}

void _expectRegistrationUnavailable(_RecordingPlantRepository plants) {
  expect(find.byType(PlantCreateScaffold), findsNothing);
  expect(find.widgetWithText(FilledButton, '등록'), findsNothing);
  expect(plants.codes, isEmpty);
  _expectNoFixtures();
}

void _expectNoFixtures() {
  for (final place in plantRegistrationPlaceFallbacks) {
    expect(find.text(place.name), findsNothing);
  }
}

class _ControlledPlaceRepository extends Fake implements PlaceRepository {
  final requests = <Completer<List<PlaceSummary>>>[];

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() {
    final request = Completer<List<PlaceSummary>>();
    requests.add(request);
    return request.future;
  }
}

class _RecordingPlantRepository extends Fake implements PlantRepository {
  final codes = <String>[];
  final names = <String>[];

  @override
  Future<void> createPlant({
    required String placeCode,
    required String nickname,
    String? scientificNameKo,
    String? scientificNameEn,
    String? lastWateredDate,
    String? description,
  }) async {
    codes.add(placeCode);
    names.add(nickname);
  }
}
