import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/friend_management_page.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';
import '../../../../helpers/user_data_session.dart';

void main() {
  testWidgets('화면이 폐기된 뒤 남은 확인창으로 위임하지 않는다', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticatedUserDataSession,
          useRemoteApiProvider.overrideWithValue(true),
          placeRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          initialRoute: '/manage',
          routes: {
            '/manage': (_) => const FriendManagementPage(placeId: 'place-code'),
          },
          home: const Scaffold(body: Text('홈')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pageContext = tester.element(find.byType(FriendManagementPage));
    final route = ModalRoute.of(pageContext)!;
    final navigator = Navigator.of(pageContext);
    await tester.tap(find.text('팀짱 위임'));
    await tester.pumpAndSettle();
    navigator.removeRoute(route);
    await tester.pumpAndSettle();
    await tester.tap(find.text('위임'));
    await tester.pumpAndSettle();
    expect(repository.targets, isEmpty);
    expect(find.text('홈'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('이전 계정의 확인창은 새 계정의 같은 장소에 위임하지 않는다', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FriendManagementPage)),
    );
    await tester.tap(find.text('팀짱 위임'));
    await tester.pumpAndSettle();
    container.read(userDataSessionProvider.notifier).end();
    container.read(userDataSessionProvider.notifier).start();
    await tester.pumpAndSettle();
    await tester.tap(find.text('위임'));
    await tester.pumpAndSettle();
    expect(repository.targets, isEmpty);
    expect(tester.takeException(), isNull);
  });
  for (final viewport in [
    TestViewports.compactWidth,
    TestViewports.reference,
  ]) {
    testWidgets('팀짱 위임 확인·중복 제출 잠금·재조회 $viewport', (tester) async {
      configureTestViewport(tester, viewport);
      final repository = _Repository()..pending = Completer<void>();
      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('팀짱 위임'), findsOneWidget);
      await tester.tap(find.text('팀짱 위임'));
      await tester.pumpAndSettle();
      expect(find.text('동일한이름님에게 위임'), findsOneWidget);
      expect(find.text('이 멤버에게 팀짱을 넘기면\n내 팀짱 권한이 사라져요.'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(repository.targets, isEmpty);

      await tester.tap(find.text('팀짱 위임'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('위임'));
      await tester.pump();
      expect(repository.targets, ['member-id']);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '팀짱 위임'),
      );
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);

      repository.pending!.complete();
      await tester.pumpAndSettle();
      expect(repository.memberReads, 2);
      expect(repository.detailReads, 2);
      expect(find.text('팀짱 위임'), findsNothing);
      expect(find.text('팀짱'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('일반 멤버에게 위임 액션을 노출하지 않는다', (tester) async {
    final repository = _Repository()..isOwner = false;
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('동일한이름'), findsNWidgets(2));
    expect(find.text('팀짱 위임'), findsNothing);
  });

  testWidgets('위임 실패는 안내하고 같은 멤버로 재시도할 수 있다', (tester) async {
    final repository = _Repository()..fail = true;
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(find.text('팀짱 변경에 실패했어요'), findsOneWidget);
    expect(find.text('팀짱 위임'), findsOneWidget);
    repository.fail = false;
    await _confirm(tester);
    expect(repository.targets, ['member-id', 'member-id']);
    expect(find.text('팀짱 위임'), findsNothing);
  });

  testWidgets('권한 조회 오류는 위임을 숨기고 실제 조회를 재시도한다', (tester) async {
    final repository = _Repository()..failDetail = true;
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('팀짱 위임'), findsNothing);
    repository.failDetail = false;
    await tester.tap(find.text('팀짱 권한을 확인하지 못했어요. 다시 시도'));
    await tester.pumpAndSettle();
    expect(repository.detailReads, 2);
    expect(find.text('팀짱 위임'), findsOneWidget);
  });

  testWidgets('확인창이 열린 뒤 권한이 바뀌면 오래된 확인으로 전송하지 않는다', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FriendManagementPage)),
    );
    await tester.tap(find.text('팀짱 위임'));
    await tester.pumpAndSettle();
    repository.isOwner = false;
    container.invalidate(placeDetailProvider('place-code'));
    await container.read(placeDetailProvider('place-code').future);
    await tester.pump();
    await tester.tap(find.text('위임'));
    await tester.pumpAndSettle();
    expect(repository.targets, isEmpty);
    expect(find.text('팀짱 권한을 확인한 뒤 다시 시도해 주세요'), findsOneWidget);
  });
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text('팀짱 위임'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('위임'));
  await tester.pumpAndSettle();
}

Widget _app(_Repository repository) => ProviderScope(
  overrides: [
    authenticatedUserDataSession,
    useRemoteApiProvider.overrideWithValue(true),
    placeRepositoryProvider.overrideWithValue(repository),
  ],
  child: const MaterialApp(home: FriendManagementPage(placeId: 'place-code')),
);

class _Repository extends Fake implements PlaceRepository {
  bool isOwner = true;
  bool fail = false;
  bool failDetail = false;
  int memberReads = 0;
  int detailReads = 0;
  Completer<void>? pending;
  final targets = <String>[];

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    detailReads++;
    if (failDetail) throw StateError('detail failed');
    return PlaceDetail(
      code: code,
      name: '장소',
      address: '',
      isOwner: isOwner,
      members: const [],
      plants: const [],
    );
  }

  @override
  Future<List<PlaceMember>> fetchPlaceMembers(String code) async {
    memberReads++;
    return [
      PlaceMember(nanoId: 'owner-id', name: '동일한이름', isOwner: isOwner),
      PlaceMember(nanoId: 'member-id', name: '동일한이름', isOwner: !isOwner),
    ];
  }

  @override
  Future<void> changePlaceOwner({
    required String code,
    required String targetNanoId,
  }) async {
    targets.add(targetNanoId);
    if (pending != null) await pending!.future;
    if (fail) throw StateError('transfer failed');
    isOwner = false;
  }
}
