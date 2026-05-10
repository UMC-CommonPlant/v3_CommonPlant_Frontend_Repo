import 'package:commonplant_frontend/features/place/presentation/pages/address_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('주소 검색 화면은 Figma 기준 검색어와 결과 목록을 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddressSearchPage()));

    expect(find.text('주소 검색'), findsOneWidget);
    expect(find.text('신도림역'), findsOneWidget);
    expect(find.text('신도림역 1호선', findRichText: true), findsOneWidget);
    expect(find.text('서울 구로구 경인로 688'), findsOneWidget);
    expect(find.text('선택'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('선택'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('주소 검색 결과를 선택하면 이전 화면으로 돌아간다', (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddressSearchPage(),
                    ),
                  );
                },
                child: const Text('주소 검색 열기'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('주소 검색 열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('선택').first);
    await tester.pumpAndSettle();

    expect(find.text('주소 검색 열기'), findsOneWidget);
    expect(navigatorKey.currentState?.canPop(), isFalse);
  });
}
