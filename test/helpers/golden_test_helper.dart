import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_viewport.dart';

const Key goldenTestSurfaceKey = ValueKey<String>('golden-test-surface');

const List<String> _pretendardFontAssets = <String>[
  'assets/fonts/pretendard_regular.otf',
  'assets/fonts/pretendard_medium.otf',
  'assets/fonts/pretendard_semibold.otf',
  'assets/fonts/pretendard_bold.otf',
];

Future<void>? _fontLoadFuture;

Future<void> loadGoldenTestFonts() {
  return _fontLoadFuture ??= _loadPretendardFonts();
}

Future<void> _loadPretendardFonts() async {
  final fontLoader = FontLoader(AppTextStyles.fontFamily);

  for (final asset in _pretendardFontAssets) {
    fontLoader.addFont(rootBundle.load(asset));
  }

  await fontLoader.load();
}

Future<void> pumpGoldenTestApp(
  WidgetTester tester, {
  required Widget child,
  Size logicalSize = TestViewports.reference,
}) async {
  configureTestViewport(tester, logicalSize);
  await loadGoldenTestFonts();

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: RepaintBoundary(key: goldenTestSurfaceKey, child: child),
    ),
  );
  await tester.pumpAndSettle();
}
