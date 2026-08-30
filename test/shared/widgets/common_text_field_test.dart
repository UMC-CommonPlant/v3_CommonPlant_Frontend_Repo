import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommonTextField는 활성 상태의 clear 동작을 유지한다', (tester) async {
    final controller = TextEditingController(text: '몬스테라');
    final changes = <String>[];
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonTextField(
            controller: controller,
            forceFocusedDecoration: true,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changes, ['']);
  });

  testWidgets('CommonTextField는 enabled가 false이면 clear를 차단한다', (tester) async {
    final controller = TextEditingController(text: '수정할 수 없는 이름');
    final changes = <String>[];
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonTextField(
            controller: controller,
            enabled: false,
            forceFocusedDecoration: true,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));

    expect(textField.enabled, isFalse);
    expect(find.byType(IconButton), findsNothing);
    expect(controller.text, '수정할 수 없는 이름');
    expect(changes, isEmpty);
  });

  testWidgets('CommonTextField는 disabled state이면 clear를 차단한다', (tester) async {
    final controller = TextEditingController(text: '수정할 수 없는 이름');
    final changes = <String>[];
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonTextField(
            controller: controller,
            state: CommonTextFieldState.disabled,
            forceFocusedDecoration: true,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));

    expect(textField.enabled, isFalse);
    expect(find.byType(IconButton), findsNothing);
    expect(controller.text, '수정할 수 없는 이름');
    expect(changes, isEmpty);
  });

  testWidgets('CommonTextField는 disabled 상태에서 입력을 막고 helper를 표시한다', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CommonTextField(
            state: CommonTextFieldState.disabled,
            helperText: '입력할 수 없습니다',
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));

    expect(textField.enabled, isFalse);
    expect(find.text('입력할 수 없습니다'), findsOneWidget);
  });

  testWidgets('CommonTextField는 error 상태의 line과 helper 색상을 적용한다', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CommonTextField(
            state: CommonTextFieldState.error,
            helperText: '다시 입력해 주세요',
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = decoratedBox.decoration as BoxDecoration;
    final border = decoration.border! as Border;
    final helper = tester.widget<Text>(find.text('다시 입력해 주세요'));

    expect(border.bottom.color, AppColors.danger);
    expect(helper.style?.color, AppColors.danger);
  });
}
