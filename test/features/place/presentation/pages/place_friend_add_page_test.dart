import 'package:commonplant_frontend/features/place/presentation/pages/place_friend_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('친구 추가 기본 화면은 검색 전 결과 없이 액션을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlaceFriendAddPage()));

    expect(find.text('친구 추가'), findsOneWidget);
    expect(find.text('건너뛰기'), findsOneWidget);
    expect(find.text('닉네임 검색'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
    expect(find.text('커먼맘'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('친구 닉네임 검색 후 결과를 선택할 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlaceFriendAddPage()));

    await tester.enterText(find.byType(TextField), '커먼');
    await tester.pumpAndSettle();

    expect(find.text('커먼맘'), findsOneWidget);
    expect(find.text('커먼인척'), findsOneWidget);
    expect(find.text('커먼일뻔'), findsOneWidget);
    expect(find.text('커먼일지도'), findsOneWidget);
    expect(find.text('커먼 파파'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(5));

    await tester.tap(find.text('커먼맘'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
