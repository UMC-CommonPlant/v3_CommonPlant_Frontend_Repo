import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_bottom_tab_bar.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String mainTabComingSoonMessage = '준비 중인 기능입니다';

class MainTabShell extends StatelessWidget {
  const MainTabShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selectedTab = location == AppRoutePaths.userProfile
        ? HomeBottomTab.my
        : HomeBottomTab.garden;

    return Column(
      children: [
        Expanded(child: child),
        HomeBottomTabBar(
          selectedTab: selectedTab,
          onTabSelected: (tab) => _selectTab(context, tab, selectedTab),
        ),
      ],
    );
  }

  void _selectTab(
    BuildContext context,
    HomeBottomTab tab,
    HomeBottomTab selectedTab,
  ) {
    if (tab == selectedTab) {
      return;
    }

    switch (tab) {
      case HomeBottomTab.garden:
        context.go(AppRoutePaths.home);
        return;
      case HomeBottomTab.my:
        context.go(AppRoutePaths.userProfile);
        return;
      case HomeBottomTab.info:
      case HomeBottomTab.story:
      case HomeBottomTab.calendar:
        showCommonSnackBar(context, mainTabComingSoonMessage);
        return;
    }
  }
}
