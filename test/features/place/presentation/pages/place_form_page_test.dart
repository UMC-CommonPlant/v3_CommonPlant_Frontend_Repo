import 'package:commonplant_frontend/features/place/presentation/pages/place_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('장소 수정 화면은 기존 장소 정보와 비활성 완료 버튼을 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlaceFormPage(placeId: 'place-1')),
      ),
    );

    expect(find.text('장소 수정'), findsOneWidget);
    expect(find.text('스윗 홈_ 거실'), findsOneWidget);
    expect(find.text('주소'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 대표 이미지'), findsOneWidget);
    expect(find.bySemanticsLabel('텍스트 삭제'), findsOneWidget);

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );

    expect(completeButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('장소 수정 화면은 이름이 변경되면 완료 버튼을 활성화한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlaceFormPage(placeId: 'place-1')),
      ),
    );

    await tester.enterText(find.byType(TextField), '스윗 홈_ 방');
    await tester.pump();

    final completeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );

    expect(completeButton.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
