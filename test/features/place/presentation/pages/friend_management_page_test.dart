import 'package:commonplant_frontend/features/place/presentation/pages/friend_management_page.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('친구 관리 기본 화면은 선택 친구와 검색 결과를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
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
      const MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
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
      const MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
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
      const MaterialApp(home: FriendManagementPage(placeId: 'place-1')),
    );

    await tester.enterText(find.byType(TextField), '파파');
    await tester.pumpAndSettle();

    expect(find.text('커먼맘'), findsOneWidget);
    expect(find.text('커먼 파파'), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
