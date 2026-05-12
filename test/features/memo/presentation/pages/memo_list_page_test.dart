import 'package:commonplant_frontend/features/memo/presentation/pages/memo_list_page.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('메모 목록 기본 화면은 피드형 메모와 작성 액션을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MemoListPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Memo'), findsOneWidget);
    expect(find.text('작성하기'), findsOneWidget);
    expect(find.byTooltip('메모 작성'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(TextButton, '작성하기')).width,
      greaterThanOrEqualTo(80),
    );
    expect(find.text('커먼플랜트'), findsOneWidget);
    expect(find.text('커먼맘'), findsNWidgets(2));
    expect(find.text('커먼 파파'), findsOneWidget);
    expect(find.textContaining('장마여서 물주는 날짜를 조금 늦춤'), findsOneWidget);
  });

  testWidgets('메모 더보기는 수정삭제 메뉴와 삭제 확인 알럿을 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MemoListPage(plantId: 'plant-1')),
    );
    await tester.pumpAndSettle();

    final menuButton = find.bySemanticsLabel('메모 메뉴 열기: 커먼플랜트');

    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    expect(find.text('수정하기'), findsOneWidget);
    expect(find.text('삭제하기'), findsOneWidget);
    expect(
      tester.getTopRight(find.byType(CommonEditDeletePopup)).dx,
      closeTo(tester.getTopRight(menuButton).dx, 1),
    );
    expect(
      tester.getTopLeft(find.byType(CommonEditDeletePopup)).dy,
      closeTo(tester.getBottomLeft(menuButton).dy + 4, 1),
    );

    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();

    expect(find.text('게시물 삭제'), findsOneWidget);
    expect(find.text('해당 게시물을 삭제하시겠습니까?'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('커먼플랜트'), findsNothing);
    expect(find.textContaining('장마여서 물주는 날짜를 조금 늦춤'), findsNothing);
  });
}
