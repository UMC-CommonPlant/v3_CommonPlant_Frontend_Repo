import 'package:commonplant_frontend/features/memo/presentation/pages/memo_write_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('메모 작성 기본 화면은 빈 사진과 비활성 완료 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MemoWritePage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('메모 작성'), findsOneWidget);
    expect(find.text('메모 내용을 입력해 주세요'), findsOneWidget);
    expect(find.text('0/1', findRichText: true), findsOneWidget);
    expect(find.text('0/200', findRichText: true), findsOneWidget);

    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('메모를 입력하면 글자 수와 완료 버튼 상태를 갱신한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MemoWritePage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '오늘도 맑음');
    await tester.pumpAndSettle();

    expect(find.text('6/200', findRichText: true), findsOneWidget);

    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '완료'),
    );
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('사진 추가 버튼은 첨부 사진과 삭제 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MemoWritePage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('사진 추가'));
    await tester.pumpAndSettle();

    expect(find.text('1/1', findRichText: true), findsOneWidget);
    expect(find.bySemanticsLabel('첨부된 메모 사진'), findsOneWidget);
    expect(find.byTooltip('첨부 사진 삭제'), findsOneWidget);

    await tester.tap(find.byTooltip('첨부 사진 삭제'));
    await tester.pumpAndSettle();

    expect(find.text('0/1', findRichText: true), findsOneWidget);
    expect(find.bySemanticsLabel('첨부된 메모 사진'), findsNothing);
  });
}
