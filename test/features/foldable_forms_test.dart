import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/memo/presentation/pages/memo_list_page.dart';
import 'package:commonplant_frontend/features/memo/presentation/pages/memo_write_page.dart';
import 'package:commonplant_frontend/features/memo/presentation/widgets/memo_list_content.dart';
import 'package:commonplant_frontend/features/place/presentation/pages/place_form_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:commonplant_frontend/features/user/domain/entities/user_profile.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_profile_edit_page.dart';
import 'package:commonplant_frontend/features/user/presentation/pages/user_profile_page.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/current_user_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_content_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/image_selection.dart';
import '../helpers/test_viewport.dart';

void main() {
  for (final scenario in [
    (page: const PlaceFormPage(), draft: '폴더블 초안', action: '다음'),
    (
      page: const PlantFormPage(initialPlantName: '몬스테라'),
      draft: '7',
      action: '등록',
    ),
    (
      page: const PlantFormPage(plantId: 'plant-1'),
      draft: '초록 식물',
      action: '완료',
    ),
    (page: const UserProfileEditPage(), draft: '폴더블 초안', action: '수정 완료'),
  ]) {
    testWidgets('${scenario.page}: 접기·펴기·회전 후 입력·사진·포커스를 유지한다', (tester) async {
      configureTestViewport(tester, TestViewports.reference);
      final gateway = FakeImageSelectionGateway(
        () async => testSelectedImage(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            useRemoteApiProvider.overrideWithValue(false),
            imageSelectionGatewayProvider.overrideWithValue(gateway),
            currentUserProvider.overrideWith(() => _CurrentUser()),
          ],
          child: MaterialApp(home: scenario.page),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('사진 선택'));
      await tester.pumpAndSettle();
      final field = find.byType(TextField).first;
      await tester.ensureVisible(field);
      await tester.enterText(field, scenario.draft);
      await tester.pumpAndSettle();
      final editable = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      final textController = editable.controller;
      final focusNode = editable.focusNode;
      final image = tester.widget<Image>(find.byType(Image)).image;
      final selection = TextSelection(
        baseOffset: 0,
        extentOffset: scenario.draft.length,
      );
      textController.selection = selection;

      for (final size in const [
        Size(840, 690),
        Size(812, 375),
        Size(560, 320),
        Size(320, 640),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        final resized = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(resized.controller, same(textController));
        expect(resized.focusNode, same(focusNode));
        expect(textController.text, scenario.draft);
        expect(textController.selection, selection);
        expect(focusNode.hasFocus, isTrue);
        expect(tester.widget<Image>(find.byType(Image)).image, image);
        expect(gateway.calls, 1);
        expect(
          tester
              .getSize(find.widgetWithText(FilledButton, scenario.action))
              .width,
          lessThanOrEqualTo(AppSizes.formMaxWidth),
        );
        expect(tester.takeException(), isNull);
      }

      tester.view.physicalSize = const Size(560, 320);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);
      expect(textController.text, scenario.draft);
      final action = find.widgetWithText(FilledButton, scenario.action);
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(action).dy, greaterThanOrEqualTo(0));
      expect(tester.getBottomRight(action).dy, lessThanOrEqualTo(80));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('메모 작성은 창 크기가 바뀌어도 내용·사진과 입력 선택을 유지한다', (tester) async {
    configureTestViewport(tester, TestViewports.reference);
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MemoWritePage(plantId: 'foldable-plant')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('사진 추가'));
    await tester.enterText(find.byType(TextField), '새 잎이 자라고 있어요');
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    final controller = editable.controller;
    final focusNode = editable.focusNode;
    const selection = TextSelection(baseOffset: 1, extentOffset: 3);
    controller.selection = selection;

    for (final size in const [
      Size(840, 690),
      Size(812, 375),
      Size(560, 320),
      Size(375, 812),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      final resized = tester.widget<EditableText>(find.byType(EditableText));
      expect(resized.controller, same(controller));
      expect(resized.focusNode, same(focusNode));
      expect(focusNode.hasFocus, isTrue);
      expect(controller.text, '새 잎이 자라고 있어요');
      expect(controller.selection, selection);
      expect(find.bySemanticsLabel('첨부된 메모 사진'), findsOneWidget);
      expect(
        tester.getSize(find.byType(TextField)).width,
        lessThanOrEqualTo(AppSizes.formMaxWidth),
      );
      expect(tester.takeException(), isNull);
    }

    tester.view.physicalSize = const Size(560, 320);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    final action = find.widgetWithText(FilledButton, '완료');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(action).dy, lessThanOrEqualTo(80));
    expect(tester.widget<FilledButton>(action).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('펼친 화면의 메모 피드와 프로필을 읽기 폭 안에 배치한다', (tester) async {
    configureTestViewport(tester, const Size(840, 690));
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MemoListPage(plantId: 'plant-1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(MemoListContent)).width,
      lessThanOrEqualTo(AppSizes.formMaxWidth),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWith(() => _CurrentUser())],
        child: const MaterialApp(home: UserProfilePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CommonContentWidth)).width, 840);
    expect(
      tester.getTopRight(find.byKey(const ValueKey('userSettingsButton'))).dx,
      lessThanOrEqualTo((840 + AppSizes.formMaxWidth) / 2),
    );
    tester.view.physicalSize = const Size(560, 320);
    await tester.pumpAndSettle();
    expect(find.text('초록집사'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('높이가 낮은 프로필 오류 화면에서도 다시 시도까지 스크롤할 수 있다', (tester) async {
    configureTestViewport(tester, const Size(560, 240));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(() => _FailedCurrentUser()),
        ],
        child: const MaterialApp(home: UserProfilePage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(
      tester.getBottomRight(find.text('다시 시도')).dy,
      lessThanOrEqualTo(240),
    );
    expect(tester.takeException(), isNull);
  });
}

class _CurrentUser extends CurrentUserController {
  @override
  Future<UserProfile> build() async =>
      const UserProfile(id: 'user-foldable', name: '초록집사');
}

class _FailedCurrentUser extends CurrentUserController {
  @override
  Future<UserProfile> build() async => throw StateError('조회 실패');
}
