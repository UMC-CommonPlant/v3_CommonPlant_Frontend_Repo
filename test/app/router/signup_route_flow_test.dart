import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets(
    'onboarding 시작 플로우가 profile, terms, home으로 이어진다',
    (WidgetTester tester) async {
      final router = createAppRouter(initialLocation: AppRoutePaths.onboarding);
      addTearDown(router.dispose);

      await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('시작하기'));
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();

      expect(find.text('카카오로 로그인'), findsOneWidget);

      await tester.tap(find.text('카카오로 로그인'));
      await tester.pumpAndSettle();

      expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '초록');
      await tester.tapAt(const Offset(24, 24));
      await tester.pumpAndSettle();
      await tester.tap(find.text('만 14세 이상입니다.'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('보기'));
      await tester.tap(find.text('보기'));
      await tester.pumpAndSettle();

      expect(find.text('개인정보 이용약관'), findsOneWidget);

      await tester.tap(find.text('동의합니다'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('확인'));
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('완료'));
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      expect(find.text('My place'), findsOneWidget);
      expect(find.text('My plant'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('약관 보기에서 동의하면 프로필 설정 체크 상태로 돌아온다', (WidgetTester tester) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.profileSetup);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '초록');
    await tester.tap(find.text('만 14세 이상입니다.'));
    await tester.tap(find.text('보기'));
    await tester.pumpAndSettle();

    expect(find.text('개인정보 이용약관'), findsOneWidget);

    await tester.tap(find.text('동의합니다'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
    expect(find.bySemanticsLabel('개인정보 이용약관 동의됨'), findsOneWidget);
    expect(
      tester
          .widget<CommonButton>(
            find.byKey(const ValueKey('profileCompleteButton')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('기존 약관 경로에서도 약관을 체크해야 확인할 수 있고 가입은 완료 버튼에서 진행한다', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutePaths.profileSetup);
    addTearDown(router.dispose);

    await tester.pumpWidget(buildCommonPlantRouterTestApp(router));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '초록');
    await tester.tap(find.text('만 14세 이상입니다.'));

    router.push('${AppRoutePaths.terms}?next=home');
    await tester.pumpAndSettle();

    final confirm = find.byKey(const ValueKey('privacyTermsConfirmButton'));
    expect(tester.widget<CommonButton>(confirm).onPressed, isNull);
    await tester.tap(find.text('동의합니다'));
    await tester.pump();
    expect(tester.widget<CommonButton>(confirm).onPressed, isNotNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsNothing);
    expect(find.bySemanticsLabel('개인정보 이용약관 동의됨'), findsOneWidget);
    expect(
      tester
          .widget<CommonButton>(
            find.byKey(const ValueKey('profileCompleteButton')),
          )
          .onPressed,
      isNotNull,
    );
  });
}
