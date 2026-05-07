import 'package:commonplant_frontend/features/login/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('로그인 화면은 Figma 기준 로고와 소셜 로그인 버튼을 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('9:41'), findsNothing);
    expect(find.bySemanticsLabel('Common'), findsOneWidget);
    expect(find.bySemanticsLabel('Plant'), findsOneWidget);
    expect(find.bySemanticsLabel('로그인 일러스트'), findsOneWidget);
    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text('구글로 로그인'), findsOneWidget);
    expect(find.text('Apple로 로그인'), findsOneWidget);

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginWordmark'))).dy,
      closeTo(140, 0.01),
    );
    expect(
      tester.getSize(find.bySemanticsLabel('로그인 일러스트')),
      closeToSize(const Size(186, 186), 0.01),
    );
    expect(
      tester.getTopLeft(find.bySemanticsLabel('로그인 일러스트')).dy,
      closeTo(204.377, 0.01),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('loginKakaoButton'))),
      closeToSize(const Size(335, 44), 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginKakaoButton'))).dy,
      closeTo(582, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginGoogleButton'))).dy,
      closeTo(638, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('loginAppleButton'))).dy,
      closeTo(694, 0.01),
    );
  });

  testWidgets('로그인 화면은 낮은 높이에서 주요 요소를 세로 축소 배치한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final illustrationSize = tester.getSize(find.bySemanticsLabel('로그인 일러스트'));
    expect(illustrationSize.width, lessThan(186));
    expect(illustrationSize.height, lessThan(186));
    expect(find.text('카카오로 로그인'), findsOneWidget);
    expect(find.text('구글로 로그인'), findsOneWidget);
    expect(find.text('Apple로 로그인'), findsOneWidget);
  });
}

Matcher closeToSize(Size expected, double delta) {
  return predicate<Size>(
    (actual) =>
        (actual.width - expected.width).abs() <= delta &&
        (actual.height - expected.height).abs() <= delta,
    'is within $delta of $expected',
  );
}
