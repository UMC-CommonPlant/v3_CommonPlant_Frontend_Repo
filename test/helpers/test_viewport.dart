import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class TestViewports {
  const TestViewports._();

  static const Size compactWidth = Size(320, 640);
  static const Size shortHeight = Size(375, 667);
  static const Size reference = Size(375, 812);
  static const Size wide = Size(430, 932);
}

void configureTestViewport(
  WidgetTester tester,
  Size logicalSize, {
  double devicePixelRatio = 1,
}) {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = Size(
    logicalSize.width * devicePixelRatio,
    logicalSize.height * devicePixelRatio,
  );
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
