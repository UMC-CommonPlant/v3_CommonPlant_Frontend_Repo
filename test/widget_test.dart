import 'package:commonplant_frontend/app/common_plant_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱이 초기 홈 화면을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CommonPlantApp()));
    await tester.pumpAndSettle();

    expect(find.text('CommonPlant Components'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
    expect(find.text('장소 추가하기'), findsOneWidget);
    expect(
      find.text('피그마 이미지 기준으로 버튼, 추가 타일, 메모 카드 스타일을 다시 맞추고 있습니다.'),
      findsOneWidget,
    );
    expect(find.text('사용가능한 닉네임 입니다'), findsNothing);

    final nicknameField = find.widgetWithText(TextField, '닉네임을 입력해 주세요');

    await tester.enterText(nicknameField, '가');
    await tester.pump();

    expect(find.text('2~10자의 닉네임으로 입력해주세요'), findsOneWidget);

    await tester.enterText(nicknameField, '가나');
    await tester.pump();

    expect(find.text('사용가능한 닉네임 입니다'), findsNothing);

    await tester.tapAt(const Offset(32, 220));
    await tester.pumpAndSettle();

    expect(find.text('사용가능한 닉네임 입니다'), findsOneWidget);

    await tester.enterText(nicknameField, '커먼플랜트');
    await tester.pump();

    await tester.tapAt(const Offset(32, 220));
    await tester.pumpAndSettle();

    expect(find.text('중복된 닉네임입니다'), findsOneWidget);
  });
}
