import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_invitations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('장소 친구 요청 기본 화면을 Figma 항목과 버튼으로 표시한다', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('장소 친구 요청'), findsOneWidget);
    expect(find.text('초대받은 장소'), findsNothing);
    expect(find.text('커먼맘'), findsNWidgets(2));
    expect(find.text('도라에몽'), findsOneWidget);
    expect(find.text('스윗홈_욕실'), findsOneWidget);
    expect(find.text('스윗홈_베란다'), findsOneWidget);
    expect(find.text('낫 스윗 회사_중앙'), findsOneWidget);
    expect(find.text('서울시 노원구 광운로 20'), findsNWidgets(2));
    expect(find.text('서울시 강남구 커먼로 55'), findsOneWidget);
    expect(find.text('확인'), findsNWidgets(3));
    expect(find.text('삭제'), findsNWidgets(3));
    expect(
      tester.getSize(find.bySemanticsLabel('스윗홈_욕실 확인')),
      const Size(
        AppSizes.placeInvitationActionButtonWidth,
        AppSizes.placeInvitationActionButtonHeight,
      ),
    );
  });

  testWidgets('확인과 삭제 버튼을 누르면 항목별 결과 상태로 분기한다', (WidgetTester tester) async {
    await _pumpPage(tester);

    await tester.tap(find.bySemanticsLabel('스윗홈_욕실 삭제'));
    await tester.pump();

    expect(find.text('요청 삭제됨'), findsOneWidget);
    expect(find.text('스윗홈_욕실'), findsNothing);
    expect(find.text('확인'), findsNWidgets(2));
    expect(find.text('삭제'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('스윗홈_베란다 확인'));
    await tester.pump();

    expect(find.text('스윗홈_베란다에서 함께 해보세요:)'), findsOneWidget);
    expect(find.text('스윗홈_베란다'), findsNothing);
    expect(find.text('낫 스윗 회사_중앙'), findsOneWidget);
    expect(find.text('확인'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
  });
}

Future<void> _pumpPage(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(const MaterialApp(home: PlaceInvitationsPage()));
  await tester.pumpAndSettle();
}
