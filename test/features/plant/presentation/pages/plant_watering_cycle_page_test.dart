import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/presentation/pages/plant_form_page.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_watering_cycle_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_viewport.dart';

void main() {
  for (final isEdit in [false, true]) {
    for (final viewport in [
      TestViewports.reference,
      TestViewports.compactWidth,
      TestViewports.shortHeight,
    ]) {
      testWidgets('${isEdit ? '수정' : '생성'} 주기 입력 검증과 키보드 스크롤 ($viewport)', (
        tester,
      ) async {
        configureTestViewport(tester, viewport);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: PlantFormPage(plantId: isEdit ? 'p' : null),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final field = find.descendant(
          of: find.byType(PlantWateringCycleField),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(field);
        final submit = find.widgetWithText(FilledButton, isEdit ? '완료' : '등록');
        expect(tester.widget<FilledButton>(submit).onPressed, isNull);
        await tester.enterText(field, '0');
        await tester.pumpAndSettle();
        expect(find.text('1 이상의 정수로 입력해 주세요'), findsOneWidget);
        expect(tester.widget<FilledButton>(submit).onPressed, isNull);
        await tester.enterText(field, '7');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
        expect(
          tester.getBottomRight(submit).dy,
          lessThanOrEqualTo(viewport.height - 300),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('API 수정 화면은 미지원 주기를 비활성 안내로 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useRemoteApiProvider.overrideWithValue(true),
          plantFormEditInfoProvider(
            'p',
          ).overrideWithValue(const AsyncData(PlantEditInfo(name: '식물'))),
        ],
        child: const MaterialApp(
          home: PlantFormPage(plantId: 'p', placeId: 'place'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('물주기 주기 저장 기능을 준비 중이에요'), findsOneWidget);
    final field = find.descendant(
      of: find.byType(PlantWateringCycleField),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(field).enabled, isFalse);
  });
}
