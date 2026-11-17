import 'package:commonplant_frontend/app/router/app_router.dart';
import 'package:commonplant_frontend/app/router/main_tab_shell.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_settings_page.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/test_viewport.dart';

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

  testWidgets('하단 탭으로 정원과 마이페이지를 오간다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(initialLocation: AppRoutePaths.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('마이'));
    await tester.pumpAndSettle();

    expect(find.text('alwaysweave@gmail.com'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('정원'));
    await tester.pumpAndSettle();

    expect(find.text('My place'), findsOneWidget);
    expect(find.text('alwaysweave@gmail.com'), findsNothing);
  });

  testWidgets('미구현 메인 탭은 현재 화면에서 준비 중 안내를 표시한다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(initialLocation: AppRoutePaths.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();

    for (final label in ['정보', '이야기', '캘린더']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(mainTabComingSoonMessage), findsOneWidget);
      expect(find.text('My place'), findsOneWidget);
    }
  });

  testWidgets('마이 상세 화면은 하단 탭을 숨기고 뒤로가면 다시 표시한다', (tester) async {
    await _setPhoneViewport(tester);
    final router = createAppRouter(initialLocation: AppRoutePaths.userProfile);
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterApp(router));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('정원'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('userSettingsButton')));
    await tester.pumpAndSettle();

    expect(find.text('설정'), findsOneWidget);
    expect(find.bySemanticsLabel('정원'), findsNothing);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('alwaysweave@gmail.com'), findsOneWidget);
    expect(find.bySemanticsLabel('정원'), findsOneWidget);
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

  for (final viewport in [
    TestViewports.reference,
    TestViewports.shortHeight,
    TestViewports.compactWidth,
  ]) {
    testWidgets('회원탈퇴 화면에서 확인하고 설정으로 돌아갈 수 있다 ($viewport)', (tester) async {
      configureTestViewport(tester, viewport);
      final router = createAppRouter(
        initialLocation: AppRoutePaths.userSettings,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_buildRouterApp(router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('회원탈퇴'));
      await tester.pumpAndSettle();
      expect(find.text('커먼님 잠시만요 !'), findsOneWidget);
      expect(find.byType(CommonDialogCard), findsNothing);

      final deleteButton = find.widgetWithText(CommonButton, '계정 삭제하기');
      await tester.ensureVisible(deleteButton);
      await tester.pumpAndSettle();
      expect(tester.widget<CommonButton>(deleteButton).onPressed, isNull);

      final acknowledgement = find.text('유의사항을 모두 확인하였습니다.');
      final checkIcon = find.byWidgetPredicate(
        (widget) =>
            widget is CommonSvgIcon &&
            widget.assetPath == AppIconAssets.checkCircleUnselected,
      );
      final uncheckedRect = tester.getRect(checkIcon);
      expect(tester.widget<CommonSvgIcon>(checkIcon).colorMapper, isNull);

      await tester.tap(acknowledgement);
      await tester.pump();
      expect(tester.widget<CommonButton>(deleteButton).onPressed, isNotNull);
      expect(tester.getRect(checkIcon), uncheckedRect);
      expect(tester.widget<CommonSvgIcon>(checkIcon).colorMapper, isNotNull);

      await tester.tap(acknowledgement);
      await tester.pump();
      expect(tester.widget<CommonButton>(deleteButton).onPressed, isNull);
      expect(tester.getRect(checkIcon), uncheckedRect);
      expect(tester.widget<CommonSvgIcon>(checkIcon).colorMapper, isNull);

      await tester.tap(find.bySemanticsLabel('뒤로 가기'));
      await tester.pumpAndSettle();
      expect(find.text('설정'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('설정 화면은 알림 토글과 로그아웃 확인창을 제공한다', (tester) async {
    configureTestViewport(tester, TestViewports.compactWidth);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: UserSettingsPage())),
    );
    await tester.pumpAndSettle();

    final title = tester.getRect(find.text('알림 설정'));
    final description = tester.getRect(find.text('물주기 및 식물의 상태를 알려드려요'));
    final notificationSwitch = find.byType(Switch);
    final switchRect = tester.getRect(notificationSwitch);
    expect(description.top, greaterThan(title.bottom));
    expect(description.right, lessThan(switchRect.left));
    expect(
      switchRect.center.dy,
      closeTo((title.top + description.bottom) / 2, 0.01),
    );

    final switchWidget = tester.widget<Switch>(notificationSwitch);
    expect(switchWidget.value, isTrue);
    await tester.tap(notificationSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(notificationSwitch).value, isFalse);

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
