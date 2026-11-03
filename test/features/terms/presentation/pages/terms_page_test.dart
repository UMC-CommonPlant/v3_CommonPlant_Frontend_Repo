import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_controller.dart';
import 'package:commonplant_frontend/features/terms/presentation/pages/terms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('개인정보 이용약관 화면은 Figma 기준 구조를 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: _TermsPageApp()));

    expect(find.text('9:41'), findsNothing);
    expect(find.text('개인정보 이용약관'), findsOneWidget);
    expect(find.textContaining('Lorem ipsum dolor sit amet'), findsOneWidget);
    expect(find.text('동의합니다'), findsOneWidget);
    expect(find.bySemanticsLabel('동의합니다 선택 안 됨'), findsOneWidget);
    expect(find.text('확인'), findsOneWidget);

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('privacyTermsSheet'))).dy,
      closeTo(50, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('privacyTermsBody'))).dy,
      closeTo(135, 0.01),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('privacyTermsCheckRow'))).dy,
      closeTo(610, 0.01),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('privacyTermsConfirmButton')))
          .dy,
      closeTo(698, 0.01),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('privacyTermsConfirmButton'))),
      closeToSize(const Size(335, 48), 0.01),
    );
  });

  testWidgets('약관 동의는 펼친 창과 짧은 창 전환 후에도 유지된다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TermsPageApp(),
      ),
    );
    final checkRow = find.byKey(const ValueKey('privacyTermsCheckRow'));
    await tester.ensureVisible(checkRow);
    await tester.pumpAndSettle();
    await tester.tap(checkRow);
    await tester.pump();
    final controller = container.read(profileSetupControllerProvider.notifier);

    for (final viewport in [
      const Size(1000, 800),
      const Size(812, 375),
      const Size(375, 520),
      const Size(320, 640),
    ]) {
      tester.view.physicalSize = viewport;
      await tester.pumpAndSettle();
      expect(
        container.read(profileSetupControllerProvider.notifier),
        same(controller),
      );
      expect(find.bySemanticsLabel('동의합니다 선택됨'), findsOneWidget);
      final confirm = find.byKey(const ValueKey('privacyTermsConfirmButton'));
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(confirm).dy,
        lessThanOrEqualTo(viewport.height),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('큰 글씨와 키보드가 있는 짧은 창에서도 약관 동의에 접근한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 375);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 20);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
    tester.view.viewInsets = const FakeViewPadding(bottom: 150);
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewInsets);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const TermsPage(),
        ),
      ),
    );
    final checkRow = find.byKey(const ValueKey('privacyTermsCheckRow'));
    await tester.ensureVisible(checkRow);
    await tester.pumpAndSettle();
    await tester.tap(checkRow);
    await tester.pump();
    expect(
      container.read(profileSetupControllerProvider).isPrivacyTermsAccepted,
      isTrue,
    );
    final confirm = find.byKey(const ValueKey('privacyTermsConfirmButton'));
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(confirm).dy, lessThanOrEqualTo(225));
    expect(tester.takeException(), isNull);
  });

  testWidgets('개인정보 이용약관 체크는 프로필 설정 상태 Provider에 반영된다', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TermsPageApp(),
      ),
    );

    final checkRow = find.byKey(const ValueKey('privacyTermsCheckRow'));
    await tester.ensureVisible(checkRow);
    await tester.pumpAndSettle();
    await tester.tap(checkRow);
    await tester.pump();

    expect(
      container.read(profileSetupControllerProvider).isPrivacyTermsAccepted,
      isTrue,
    );
    expect(find.bySemanticsLabel('동의합니다 선택됨'), findsOneWidget);
  });
}

class _TermsPageApp extends StatelessWidget {
  const _TermsPageApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TermsPage());
  }
}

Matcher closeToSize(Size expected, double delta) {
  return predicate<Size>(
    (actual) =>
        (actual.width - expected.width).abs() <= delta &&
        (actual.height - expected.height).abs() <= delta,
    'is within $delta of $expected',
  );
}
