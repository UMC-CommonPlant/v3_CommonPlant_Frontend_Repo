import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_body.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_sections.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

void main() {
  testWidgets('친구 요청 수 loading을 정상 0건과 구분한다', (tester) async {
    await tester.pumpWidget(_buildHomeBody(const AsyncLoading<int>()));
    await tester.pump();

    expect(find.bySemanticsLabel('장소 요청 불러오는 중'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('요청 0건'), findsNothing);
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('정상 0건이면 장소 요청 버튼을 숨긴다', (tester) async {
    await tester.pumpWidget(_buildHomeBody(const AsyncData(0)));
    await tester.pumpAndSettle();

    expect(find.byType(HomePlaceRequestButton), findsNothing);
    expect(find.bySemanticsLabel('장소 요청 0건'), findsNothing);
    expect(find.text('재시도'), findsNothing);
  });

  testWidgets('친구 요청 조회 오류를 재시도해 0건이면 버튼을 숨긴다', (tester) async {
    var fetchCalls = 0;
    final retryResult = Completer<List<PlaceInvitation>>();

    await tester.pumpWidget(
      _buildRemoteHomeBody(() {
        fetchCalls++;
        if (fetchCalls == 1) {
          throw StateError('요청 조회 실패');
        }
        return retryResult.future;
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('재시도'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 요청 조회 실패, 다시 시도'), findsOneWidget);
    expect(find.text('요청 0건'), findsNothing);

    await tester.tap(find.text('재시도'));
    await tester.pump();

    expect(fetchCalls, 2);
    expect(find.bySemanticsLabel('장소 요청 불러오는 중'), findsOneWidget);

    retryResult.complete(const []);
    await tester.pumpAndSettle();

    expect(find.byType(HomePlaceRequestButton), findsNothing);
    expect(find.text('재시도'), findsNothing);
  });

  testWidgets('양수 친구 요청 수를 그대로 표시한다', (tester) async {
    await tester.pumpWidget(_buildHomeBody(const AsyncData(4)));
    await tester.pumpAndSettle();

    expect(find.text('요청 4건'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 요청 4건'), findsOneWidget);
  });
  for (final placeFails in [true, false]) {
    final failedList = placeFails ? '장소' : '식물';
    testWidgets('$failedList만 실패하면 정상 목록을 보존하고 실패한 요청만 재시도한다', (tester) async {
      var placeCalls = 0;
      var plantCalls = 0;
      var invitationCalls = 0;
      final placeRetry = Completer<List<PlaceSummary>>();
      final plantRetry = Completer<List<PlantSummary>>();

      await tester.pumpWidget(
        _buildRemoteHomeBody(
          () async {
            invitationCalls++;
            return [];
          },
          fetchPlaces: () {
            placeCalls++;
            if (!placeFails) return const [_place];
            if (placeCalls == 1) throw StateError('장소 실패');
            return placeRetry.future;
          },
          fetchPlants: () {
            plantCalls++;
            if (placeFails) return const [_plant];
            if (plantCalls == 1) throw StateError('식물 실패');
            return plantRetry.future;
          },
        ),
      );
      await tester.pumpAndSettle();

      final healthy = placeFails
          ? find.bySemanticsLabel(_plant.name)
          : find.text(_place.name);
      final failedStatus = find.text('$failedList 목록을 불러오지 못했어요.');
      final retryButton = find.text('다시 시도');
      expect(healthy, findsOneWidget);
      expect(failedStatus, findsOneWidget);
      expect(find.byType(HomePlaceRequestButton), findsNothing);
      expect(retryButton, findsOneWidget);
      expect(find.text('$failedList 추가하기'), findsNothing);

      await tester.tap(retryButton);
      await tester.pump();

      expect(placeCalls, placeFails ? 2 : 1);
      expect(plantCalls, placeFails ? 1 : 2);
      expect(invitationCalls, 1);
      expect(healthy, findsOneWidget);
      expect(find.bySemanticsLabel('$failedList 목록 불러오는 중'), findsOneWidget);
      expect(retryButton, findsNothing);

      if (placeFails) {
        placeRetry.complete(const [_place]);
      } else {
        plantRetry.complete(const [_plant]);
      }
      await tester.pumpAndSettle();

      expect(find.text(_place.name), findsOneWidget);
      expect(find.bySemanticsLabel(_plant.name), findsOneWidget);
      expect(failedStatus, findsNothing);
    });
  }

  testWidgets('API 모드에서 홈을 아래로 당겨도 추가 조회하지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    var placeCalls = 0;
    var plantCalls = 0;
    var invitationCalls = 0;
    await tester.pumpWidget(
      _buildRemoteHomeBody(
        () async {
          invitationCalls++;
          return const [_invitation];
        },
        fetchPlaces: () {
          placeCalls++;
          return const [_place];
        },
        fetchPlants: () {
          plantCalls++;
          return const [_plant];
        },
      ),
    );
    await tester.pumpAndSettle();
    expect([placeCalls, plantCalls, invitationCalls], [1, 1, 1]);

    await tester.drag(find.text('My place'), const Offset(0, 280));
    await tester.pumpAndSettle();

    expect([placeCalls, plantCalls, invitationCalls], [1, 1, 1]);
    expect(find.byType(RefreshIndicator), findsNothing);
    expect(find.text(_place.name), findsOneWidget);
    expect(find.bySemanticsLabel(_plant.name), findsOneWidget);
    expect(find.text('요청 1건'), findsOneWidget);
  });
}

const _place = PlaceSummary(id: 'place-test', name: '거실 정원');
const _plant = PlantSummary(id: 'plant-test', name: '몬스테라');
const _invitation = PlaceInvitation(
  id: 'invitation-test',
  inviterName: '초록',
  placeName: '공동 정원',
  address: '테스트 주소',
  avatarAsset: '',
);

Widget _buildHomeBody(AsyncValue<int> invitationCount) {
  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(false),
      placeSummariesProvider.overrideWithValue(const AsyncData([])),
      plantSummariesProvider.overrideWithValue(const AsyncData([])),
      placeInvitationRequestCountProvider.overrideWithValue(invitationCount),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeBody())),
  );
}

Widget _buildRemoteHomeBody(
  Future<List<PlaceInvitation>> Function() fetchInvitations, {
  FutureOr<List<PlaceSummary>> Function()? fetchPlaces,
  FutureOr<List<PlantSummary>> Function()? fetchPlants,
}) {
  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      authenticatedUserDataSession,
      remotePlaceListProvider.overrideWith(
        (ref) => fetchPlaces?.call() ?? const [],
      ),
      remotePlantListProvider.overrideWith(
        (ref) => fetchPlants?.call() ?? const [],
      ),
      remotePlaceInvitationsProvider.overrideWith((ref) => fetchInvitations()),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeBody())),
  );
}
