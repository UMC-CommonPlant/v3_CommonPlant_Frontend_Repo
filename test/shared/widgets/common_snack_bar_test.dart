import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('새 안내를 표시하면 이전 Snackbar를 교체한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => showCommonSnackBar(context, '첫 안내'),
                  child: const Text('첫 번째'),
                ),
                TextButton(
                  onPressed: () => showCommonSnackBar(context, '다음 안내'),
                  child: const Text('두 번째'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('첫 번째'));
    await tester.pump();
    expect(find.text('첫 안내'), findsOneWidget);

    await tester.tap(find.text('두 번째'));
    await tester.pumpAndSettle();

    expect(find.text('첫 안내'), findsNothing);
    expect(find.text('다음 안내'), findsOneWidget);
  });
}
