import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/friend_management_page.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';

void main() {
  testWidgets('API 멤버 조회 중 로딩 상태를 표시한다', (tester) async {
    final pending = Completer<List<PlaceMember>>();
    await tester.pumpWidget(_remoteApp(_MembersRepository(pending: pending)));
    await tester.pump();

    expect(find.text('장소 멤버를 불러오고 있어요'), findsOneWidget);
    expect(find.text('커먼맘'), findsNothing);
  });

  testWidgets('좁은 화면에서 키보드와 로딩 안내가 함께 표시돼도 넘치지 않는다', (tester) async {
    configureTestViewport(tester, TestViewports.compactWidth);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    final pending = Completer<List<PlaceMember>>();
    await tester.pumpWidget(_remoteApp(_MembersRepository(pending: pending)));
    await tester.pump();

    expect(find.text('장소 멤버를 불러오고 있어요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('API 멤버는 fixture 없이 조회 전용으로 표시하고 필터링한다', (tester) async {
    final repository = _MembersRepository(
      members: const [
        PlaceMember(name: '서버 멤버'),
        PlaceMember(name: '옥상 친구'),
      ],
    );
    await tester.pumpWidget(_remoteApp(repository));
    await tester.pumpAndSettle();

    expect(repository.requestedCode, 'place-1');
    expect(find.text('서버 멤버'), findsOneWidget);
    expect(find.text('커먼맘'), findsNothing);
    expect(find.text('확인'), findsOneWidget);
    expect(find.text('완료'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);

    await tester.tap(find.text('서버 멤버'));
    await tester.pumpAndSettle();
    expect(find.text('님을 친구 목록에서 삭제하시겠습니까?'), findsNothing);

    await tester.enterText(find.byType(TextField), '옥상');
    await tester.pumpAndSettle();
    expect(find.text('옥상 친구'), findsOneWidget);
    expect(find.text('서버 멤버'), findsNothing);

    await tester.enterText(find.byType(TextField), '없는멤버');
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없어요'), findsOneWidget);
    expect(repository.calls, 1);
  });

  testWidgets('API 멤버가 없으면 빈 목록 안내를 표시한다', (tester) async {
    await tester.pumpWidget(_remoteApp(_MembersRepository()));
    await tester.pumpAndSettle();

    expect(find.text('장소 멤버가 없어요'), findsOneWidget);
    expect(find.text('검색 결과가 없어요'), findsNothing);
  });

  testWidgets('API 멤버 조회 실패는 재시도로 복구한다', (tester) async {
    final repository = _MembersRepository(
      failFirst: true,
      members: const [PlaceMember(name: '복구 멤버')],
    );
    await tester.pumpWidget(_remoteApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('장소 멤버를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('커먼맘'), findsNothing);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('복구 멤버'), findsOneWidget);
    expect(find.text('장소 멤버를 불러오지 못했어요'), findsNothing);
  });

  for (final viewport in [
    TestViewports.compactWidth,
    TestViewports.shortHeight,
    TestViewports.reference,
  ]) {
    testWidgets('조회 전용 긴 이름은 $viewport 화면에서 넘치지 않는다', (tester) async {
      configureTestViewport(tester, viewport);
      await tester.pumpWidget(
        _remoteApp(
          _MembersRepository(
            members: const [PlaceMember(name: '함께 식물을 키우는 이름이 아주 긴 멤버')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('확인'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('친구 관리 기본 화면은 선택 친구와 검색 결과를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
      ),
    );

    expect(find.text('친구 관리'), findsOneWidget);
    expect(find.text('닉네임 검색'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
    expect(find.text('커먼맘'), findsNWidgets(2));
    expect(find.text('커먼 파파'), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('선택 친구 삭제 버튼은 삭제 확인 알럿을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('selected-friend-remove-friend-2')),
    );
    await tester.pumpAndSettle();

    expect(find.text('님을 친구 목록에서 삭제하시겠습니까?'), findsOneWidget);
    expect(find.widgetWithText(CommonDialogActionButton, '취소'), findsOneWidget);
    expect(find.widgetWithText(CommonDialogActionButton, '삭제'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('삭제 확인 후 친구 선택 상태를 해제한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('selected-friend-remove-friend-2')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CommonDialogActionButton, '삭제'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-friend-friend-2')),
      findsNothing,
    );
    expect(find.text('커먼 파파'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('닉네임 검색어로 친구 목록을 필터링한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
      ),
    );

    await tester.enterText(find.byType(TextField), '파파');
    await tester.pumpAndSettle();

    expect(find.text('커먼맘'), findsOneWidget);
    expect(find.text('커먼 파파'), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _remoteApp(PlaceRepository repository) {
  return ProviderScope(
    overrides: [
      useRemoteApiProvider.overrideWithValue(true),
      placeRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
  );
}

class _MembersRepository extends Fake implements PlaceRepository {
  _MembersRepository({
    this.members = const [],
    this.pending,
    this.failFirst = false,
  });

  final List<PlaceMember> members;
  final Completer<List<PlaceMember>>? pending;
  final bool failFirst;
  int calls = 0;
  String? requestedCode;

  @override
  Future<List<PlaceMember>> fetchPlaceMembers(String code) async {
    calls++;
    requestedCode = code;
    if (failFirst && calls == 1) {
      throw StateError('members failed');
    }
    return pending?.future ?? members;
  }
}
