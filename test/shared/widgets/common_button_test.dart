import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommonButton은 로딩 중 탭을 막고 진행 상태를 표시한다', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonButton(
            label: '저장',
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      ),
    );

    expect(find.text('저장'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '저장'));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '저장'),
    );

    expect(button.onPressed, isNull);
    expect(tapCount, 0);
  });
}
