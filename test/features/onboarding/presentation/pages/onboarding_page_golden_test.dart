import 'dart:io';

import 'package:commonplant_frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:commonplant_frontend/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/golden_test_helper.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('온보딩 화면은 Reference viewport 디자인을 유지한다', (tester) async {
    await pumpGoldenTestApp(
      tester,
      child: ProviderScope(
        overrides: [
          onboardingLocalStoreProvider.overrideWithValue(
            TestOnboardingLocalStore(),
          ),
        ],
        child: const OnboardingPage(),
      ),
    );

    await expectLater(
      find.byKey(goldenTestSurfaceKey),
      matchesGoldenFile('goldens/onboarding_page_375x812.png'),
    );
  }, skip: !Platform.isLinux);
}
