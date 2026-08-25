import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_settings_page.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('마이페이지는 Figma 기본 회원 정보와 활성 마이 탭을 표시한다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(initialLocation: AppRoutePaths.userProfile);
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();

    expect(find.text('커먼플랜트'), findsOneWidget);
    expect(find.text('alwaysweave@gmail.com'), findsOneWidget);
    expect(find.byKey(const ValueKey('userSettingsButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('userProfileEditButton')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected == true,
      ),
      findsWidgets,
    );
  });

  testWidgets('홈 하단 마이 탭에서 마이페이지로 이동한다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(initialLocation: AppRoutePaths.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('alwaysweave@gmail.com'), findsOneWidget);
  });

  testWidgets('톱니바퀴와 수정 버튼이 각 Figma 화면으로 이동한다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(initialLocation: AppRoutePaths.userProfile);
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('userSettingsButton')));
    await tester.pumpAndSettle();

    expect(find.text('설정'), findsOneWidget);
    expect(find.text('알람설정'), findsOneWidget);
    expect(find.text('회원탈퇴'), findsOneWidget);

    router.go(AppRoutePaths.userProfile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('userProfileEditButton')));
    await tester.pumpAndSettle();

    expect(find.text('회원 정보 수정'), findsOneWidget);
    expect(find.text('수정 완료'), findsOneWidget);
  });

  testWidgets('이름 변경 완료 후 마이페이지에 수정 결과를 반영한다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(
      initialLocation: AppRoutePaths.userProfileEdit,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();
    final disabledButton = tester.widget<CommonButton>(
      find.widgetWithText(CommonButton, '수정 완료'),
    );
    expect(disabledButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), '새싹집사');
    await tester.pump();
    final enabledButton = tester.widget<CommonButton>(
      find.widgetWithText(CommonButton, '수정 완료'),
    );
    expect(enabledButton.onPressed, isNotNull);
    await tester.tap(find.text('수정 완료'));
    await tester.pumpAndSettle();

    expect(find.text('새싹집사'), findsOneWidget);
    expect(find.text('alwaysweave@gmail.com'), findsOneWidget);
  });

  testWidgets('설정 화면은 알림 토글과 계정 확인 dialog를 제공한다', (tester) async {
    await _setPhoneViewport(tester);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: UserSettingsPage())),
    );
    await tester.pumpAndSettle();

    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isTrue);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    expect(find.byType(CommonDialogCard), findsOneWidget);
    expect(find.text('현재 계정에서 로그아웃할까요?'), findsOneWidget);
    expect(find.widgetWithText(CommonDialogActionButton, '취소'), findsOneWidget);
  });
}

Widget _buildRouterApp(GoRouter router) {
  return ProviderScope(
    overrides: [useRemoteApiProvider.overrideWithValue(false)],
    child: buildCommonPlantRouterTestApp(router),
  );
}

Future<void> _setPhoneViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
