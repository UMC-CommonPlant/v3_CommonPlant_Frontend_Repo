import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('공통 네비게이션 바는 화면 전체 너비를 차지한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: CommonNavigationBar(title: '장소 등록')),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CommonNavigationBar)),
      const Size(375, AppSizes.navigationBarHeight),
    );
    expect(tester.getTopLeft(find.byType(IconButton)).dx, 0);
  });
}
