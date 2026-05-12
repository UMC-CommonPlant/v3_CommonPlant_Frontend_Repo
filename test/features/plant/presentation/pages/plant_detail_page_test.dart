import 'package:commonplant_frontend/features/plant/presentation/pages/plant_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('식물 상세는 Figma 주요 정보와 더보기 메뉴를 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PlantDetailPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('My plant'), findsOneWidget);
    expect(find.text('스윗홈_거실'), findsOneWidget);
    expect(find.text('몬테'), findsOneWidget);
    expect(find.text('Monstera deliciosa'), findsOneWidget);
    expect(find.text('D-3'), findsOneWidget);
    expect(find.text('Memo'), findsOneWidget);
    expect(find.text('식물정보'), findsOneWidget);
    expect(find.text('10 Day'), findsOneWidget);
    expect(
      tester.getCenter(find.byTooltip('식물 상세 메뉴')).dy,
      lessThanOrEqualTo(56),
    );

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('수정하기'), findsOneWidget);
    expect(find.text('삭제하기'), findsOneWidget);
  });

  testWidgets('식물 삭제 메뉴는 확인 dialog를 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PlantDetailPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('식물 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('식물을 삭제할까요?'), findsOneWidget);
    expect(find.text('삭제하면 기록된 메모도 함께 사라져요.'), findsOneWidget);
  });
}
