import 'package:commonplant_frontend/features/home/presentation/widgets/home_bottom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('애니메이션 축소 설정에서는 탭 선택 표시를 즉시 변경한다', (tester) async {
    var selectedTab = HomeBottomTab.garden;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) => HomeBottomTabBar(
              selectedTab: selectedTab,
              onTabSelected: (tab) => setState(() => selectedTab = tab),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('마이'));
    await tester.pump();

    expect(selectedTab, HomeBottomTab.my);
    expect(
      tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .every((widget) => widget.duration == Duration.zero),
      isTrue,
    );
    expect(
      tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .every((widget) => widget.duration == Duration.zero),
      isTrue,
    );
  });
}
