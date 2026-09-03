import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/onboarding/data/onboarding_local_store.dart';
import 'package:commonplant_frontend/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('API 비사용 앱은 Home에서 장소 친구 요청으로 이동한다', (tester) async {
    expect(
      AppEnvironment.useRemoteApi,
      isFalse,
      reason: 'TEST-02-A smoke는 remote API를 사용하지 않아야 합니다.',
    );

    final preferences = SharedPreferencesAsync();
    await preferences.remove(onboardingCompletedKey);
    addTearDown(() => preferences.remove(onboardingCompletedKey));

    app.main();
    await tester.pumpAndSettle();

    expect(find.text('식물을 내 공간으로,\n공간은 내 폰으로'), findsOneWidget);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsOneWidget);
    expect(find.text('My plant'), findsOneWidget);
    expect(find.bySemanticsLabel('장소 요청 3건'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('장소 요청 3건'));
    await tester.pumpAndSettle();

    expect(find.text('장소 친구 요청'), findsOneWidget);
    expect(find.text('스윗홈_욕실'), findsOneWidget);
  });
}
