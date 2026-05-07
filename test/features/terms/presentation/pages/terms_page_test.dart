import 'package:commonplant_frontend/features/login/presentation/providers/profile_setup_state_provider.dart';
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

  testWidgets('개인정보 이용약관 체크는 프로필 설정 상태 Provider에 반영된다', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TermsPageApp(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('privacyTermsCheckRow')));
    await tester.pump();

    expect(
      container.read(profileSetupStateProvider).isPrivacyTermsAccepted,
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
