import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final variant in CommonButtonVariant.values) {
    testWidgets('비활성 $variant 버튼은 배경 선을 불투명하게 가리고 탭을 막는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Positioned(left: 0, right: 0, top: 24, child: Divider()),
                CommonButton(label: '다음', variant: variant, onPressed: null),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(CommonButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppThemeTokens.light.surfaceDisabled);
      expect(material.color!.a, 1);
      final button = tester.widget<ButtonStyleButton>(
        find
            .descendant(
              of: find.byType(CommonButton),
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .first,
      );
      expect(button.onPressed, isNull);
    });
  }

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
