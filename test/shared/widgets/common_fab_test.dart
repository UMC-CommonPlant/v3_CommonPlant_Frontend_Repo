import 'package:commonplant_frontend/shared/widgets/common_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FAB 확장 메뉴는 닫힌 뒤 선택한 동작을 실행한다', (tester) async {
    var actionCallCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: CommonFabDial(
              actions: [
                CommonFabDialAction(
                  label: '식물 추가하기',
                  icon: const Icon(Icons.add),
                  onPressed: () => actionCallCount += 1,
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('식물 추가하기'), findsOneWidget);

    await tester.tap(find.text('식물 추가하기'));
    await tester.pumpAndSettle();

    expect(actionCallCount, 1);
    expect(find.text('식물 추가하기'), findsNothing);
  });
}
