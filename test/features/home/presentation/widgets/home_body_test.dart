import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_body.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('친구 요청 수 loading을 정상 0건과 구분한다', (tester) async {
    await tester.pumpWidget(_buildHomeBody(const AsyncLoading<int>()));
    await tester.pump();

    expect(find.bySemanticsLabel('장소 요청 불러오는 중'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('요청 0건'), findsNothing);
  });

  testWidgets('정상 0건은 요청 0건으로 표시한다', (tester) async {
    await tester.pumpWidget(_buildHomeBody(const AsyncData(0)));
    await tester.pumpAndSettle();

    expect(find.text('요청 0건'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 요청 0건'), findsOneWidget);
    expect(find.text('재시도'), findsNothing);
  });

  testWidgets('친구 요청 수 오류를 표시하고 재시도 후 0건으로 복구한다', (tester) async {
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

    expect(find.text('요청 0건'), findsOneWidget);
    expect(find.text('재시도'), findsNothing);
  });

  testWidgets('양수 친구 요청 수를 그대로 표시한다', (tester) async {
    await tester.pumpWidget(_buildHomeBody(const AsyncData(4)));
    await tester.pumpAndSettle();

    expect(find.text('요청 4건'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 요청 4건'), findsOneWidget);
  });
}

Widget _buildHomeBody(AsyncValue<int> invitationCount) {
  return ProviderScope(
    overrides: [
      placeSummariesProvider.overrideWithValue(const AsyncData([])),
      plantSummariesProvider.overrideWithValue(const AsyncData([])),
      placeInvitationRequestCountProvider.overrideWithValue(invitationCount),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeBody())),
  );
}

Widget _buildRemoteHomeBody(
  Future<List<PlaceInvitation>> Function() fetchInvitations,
) {
  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      placeSummariesProvider.overrideWithValue(const AsyncData([])),
      plantSummariesProvider.overrideWithValue(const AsyncData([])),
      remotePlaceInvitationsProvider.overrideWith((ref) => fetchInvitations()),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeBody())),
  );
}
