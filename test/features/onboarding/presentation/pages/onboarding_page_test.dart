import 'package:commonplant_frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('온보딩 화면은 Figma 기준 일러스트와 시작 액션을 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    expect(find.text('온보딩'), findsNothing);
    expect(find.bySemanticsLabel('온보딩 일러스트'), findsOneWidget);
    expect(find.text('식물을 내 공간으로,\n공간은 내 폰으로'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(
      tester.getSize(find.bySemanticsLabel('온보딩 일러스트')),
      closeToSize(const Size(223.698, 253.251), 0.01),
    );
    expect(
      tester.getTopLeft(find.bySemanticsLabel('온보딩 일러스트')).dy,
      closeTo(174.52, 0.01),
    );
    expect(
      tester.getTopLeft(find.text('식물을 내 공간으로,\n공간은 내 폰으로')).dy,
      closeTo(463.3, 0.01),
    );
    expect(
      tester.getSize(find.byType(CommonButton)),
      closeToSize(const Size(335, 48), 0.01),
    );
    expect(tester.getTopLeft(find.byType(CommonButton)).dy, closeTo(722, 0.01));
  });

  testWidgets('온보딩 화면은 낮은 높이에서 세로 배치를 줄인다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    final illustrationSize = tester.getSize(find.bySemanticsLabel('온보딩 일러스트'));
    expect(illustrationSize.width, lessThan(223.698));
    expect(illustrationSize.height, lessThan(253.251));
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('식물을 내 공간으로,\n공간은 내 폰으로'), findsOneWidget);
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
