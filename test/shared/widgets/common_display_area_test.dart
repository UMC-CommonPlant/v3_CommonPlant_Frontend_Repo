import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:commonplant_frontend/shared/widgets/common_display_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_viewport.dart';

void main() {
  for (final feature in <DisplayFeature>[
    const DisplayFeature(
      bounds: Rect.fromLTWH(400, 0, 24, 812),
      type: DisplayFeatureType.hinge,
      state: DisplayFeatureState.unknown,
    ),
    const DisplayFeature(
      bounds: Rect.fromLTWH(0, 380, 884, 0),
      type: DisplayFeatureType.fold,
      state: DisplayFeatureState.postureHalfOpened,
    ),
  ]) {
    testWidgets('분리 영역을 넘지 않는 본문과 dialog (${feature.type})', (tester) async {
      configureTestViewport(tester, const Size(884, 812));
      final features = ValueNotifier([feature]);
      addTearDown(features.dispose);
      await tester.pumpWidget(_app(features));
      await tester.pumpAndSettle();

      final page = tester.getRect(find.byKey(const ValueKey('draft-page')));
      expect(page.overlaps(feature.bounds), isFalse);
      if (feature.bounds.height > feature.bounds.width) {
        expect(page.right, lessThanOrEqualTo(feature.bounds.left));
      } else {
        expect(page.bottom, lessThanOrEqualTo(feature.bounds.top));
      }

      await tester.tap(find.text('안내 열기'));
      await tester.pumpAndSettle();
      final dialog = tester.getRect(find.byType(AlertDialog));
      expect(dialog.left, greaterThanOrEqualTo(page.left));
      expect(dialog.top, greaterThanOrEqualTo(page.top));
      expect(dialog.right, lessThanOrEqualTo(page.right));
      expect(dialog.bottom, lessThanOrEqualTo(page.bottom));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('평평하게 펼친 화면은 전체 가용 영역을 사용한다', (tester) async {
    configureTestViewport(tester, const Size(884, 812));
    final features = ValueNotifier([
      const DisplayFeature(
        bounds: Rect.fromLTWH(442, 0, 0, 812),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      ),
    ]);
    addTearDown(features.dispose);
    await tester.pumpWidget(_app(features));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('draft-page'))),
      const Size(884, 812),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('같은 화면의 접기·펼치기에서 입력과 focus·selection을 보존한다', (tester) async {
    configureTestViewport(tester, const Size(375, 812));
    final features = ValueNotifier(<DisplayFeature>[]);
    addTearDown(features.dispose);
    await tester.pumpWidget(_app(features));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '우리집 몬스테라');
    final fieldState = tester.state(find.byType(TextField));
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    editable.controller.selection = const TextSelection(
      baseOffset: 2,
      extentOffset: 5,
    );
    final focus = editable.focusNode;

    tester.view.physicalSize = const Size(884, 812);
    features.value = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(400, 0, 24, 812),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.unknown,
      ),
    ];
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('draft-page'))).width, 400);
    features.value = [];
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(375, 812);
    await tester.pumpAndSettle();

    final after = tester.widget<EditableText>(find.byType(EditableText));
    expect(tester.state(find.byType(TextField)), same(fieldState));
    expect(after.controller.text, '우리집 몬스테라');
    expect(
      after.controller.selection,
      const TextSelection(baseOffset: 2, extentOffset: 5),
    );
    expect(after.focusNode, same(focus));
    expect(after.focusNode.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(ValueNotifier<List<DisplayFeature>> features) {
  return MaterialApp(
    builder: (context, child) => ValueListenableBuilder<List<DisplayFeature>>(
      valueListenable: features,
      child: child,
      builder: (context, value, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(displayFeatures: value),
        child: CommonDisplayArea(child: child!),
      ),
    ),
    home: const _DraftPage(),
  );
}

class _DraftPage extends StatefulWidget {
  const _DraftPage();

  @override
  State<_DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<_DraftPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('draft-page'),
      body: SafeArea(
        child: Column(
          children: [
            TextField(controller: _controller),
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(title: Text('접힘 안내')),
              ),
              child: const Text('안내 열기'),
            ),
          ],
        ),
      ),
    );
  }
}
