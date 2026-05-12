import 'package:commonplant_frontend/features/place/presentation/pages/place_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('리더는 FAB에서 장소 수정 액션을 확인할 수 있다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceDetailPage(placeId: 'place-1', role: PlaceDetailRole.leader),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('식물 추가하기'), findsOneWidget);
    expect(find.text('장소 수정하기'), findsOneWidget);
    expect(find.text('장소 나가기'), findsOneWidget);
  });

  testWidgets('팀원은 FAB에서 장소 수정 액션을 보지 않는다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceDetailPage(placeId: 'place-1', role: PlaceDetailRole.member),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();

    expect(find.text('식물 추가하기'), findsOneWidget);
    expect(find.text('장소 수정하기'), findsNothing);
    expect(find.text('장소 나가기'), findsOneWidget);
  });

  testWidgets('장소 나가기는 확인 dialog를 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PlaceDetailPage(placeId: 'place-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('장소 상세 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소 나가기'));
    await tester.pumpAndSettle();

    expect(find.text('장소를 나가시겠어요?'), findsOneWidget);
    expect(find.text('나가면 더 이상 식물을 관리할 수 없어요.'), findsOneWidget);
  });
}
