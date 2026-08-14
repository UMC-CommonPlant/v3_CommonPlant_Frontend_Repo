import 'package:commonplant_frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/golden_test.dart';

void main() {
  testWidgets('온보딩 화면은 Reference viewport 디자인을 유지한다', (tester) async {
    await pumpGoldenTestApp(tester, child: const OnboardingPage());

    await expectLater(
      find.byKey(goldenTestSurfaceKey),
      matchesGoldenFile('goldens/onboarding_page_375x812.png'),
    );
  });
}
