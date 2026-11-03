import 'package:commonplant_frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('온보딩 화면은 Figma 기준 일러스트와 시작 액션을 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildPageTestApp(const OnboardingPage()));
    await tester.pumpAndSettle();

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

    await tester.pumpWidget(buildPageTestApp(const OnboardingPage()));
    await tester.pumpAndSettle();

    final illustrationSize = tester.getSize(find.bySemanticsLabel('온보딩 일러스트'));
    expect(illustrationSize.width, lessThan(223.698));
    expect(illustrationSize.height, lessThan(253.251));
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('식물을 내 공간으로,\n공간은 내 폰으로'), findsOneWidget);
  });

  testWidgets('온보딩은 펼친 창과 짧은 창으로 변경되어도 같은 상태를 유지한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(buildPageTestApp(const OnboardingPage()));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OnboardingPage)),
    );
    final controller = container.read(onboardingControllerProvider.notifier);

    for (final viewport in [
      const Size(1000, 800),
      const Size(812, 375),
      const Size(320, 640),
    ]) {
      tester.view.physicalSize = viewport;
      await tester.pumpAndSettle();
      expect(
        container.read(onboardingControllerProvider.notifier),
        same(controller),
      );
      final button = find.byKey(const ValueKey('onboardingStartButton'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(button).dy,
        lessThanOrEqualTo(viewport.height),
      );
      if (viewport.width >= 720) {
        expect(
          tester.getTopLeft(button).dx,
          greaterThan(
            tester.getBottomRight(find.bySemanticsLabel('온보딩 일러스트')).dx,
          ),
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('큰 글씨와 시스템 여백이 있는 짧은 창에서 시작하기에 접근한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 375);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 20);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingLocalStoreProvider.overrideWithValue(
            TestOnboardingLocalStore(),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('onboardingStartButton'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(355));
    expect(tester.takeException(), isNull);
  });

  testWidgets('완료 값 저장에 실패하면 안내하고 시작 버튼을 다시 활성화한다', (tester) async {
    final store = TestOnboardingLocalStore(writeFailures: 1);
    await tester.pumpWidget(
      buildPageTestApp(const OnboardingPage(), onboardingStore: store),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('onboardingStartButton')));
    await tester.pumpAndSettle();

    expect(find.text(onboardingSaveFailureMessage), findsOneWidget);
    expect(store.completed, isFalse);
    expect(store.writeCount, 1);
    expect(
      tester
          .widget<CommonButton>(
            find.byKey(const ValueKey('onboardingStartButton')),
          )
          .onPressed,
      isNotNull,
    );
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
