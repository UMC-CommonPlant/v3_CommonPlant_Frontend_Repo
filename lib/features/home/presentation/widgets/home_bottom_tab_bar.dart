import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_motion.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

enum HomeBottomTab { info, story, garden, calendar, my }

class HomeBottomTabBar extends StatelessWidget {
  const HomeBottomTabBar({
    super.key,
    this.selectedTab = HomeBottomTab.garden,
    required this.onTabSelected,
  });

  final HomeBottomTab selectedTab;
  final ValueChanged<HomeBottomTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSizes.bottomNavigationBarHeight,
            child: Row(
              children: [
                _HomeBottomTabItem(
                  icon: Icons.article_outlined,
                  semanticsLabel: '정보',
                  isSelected: selectedTab == HomeBottomTab.info,
                  onTap: () => onTabSelected(HomeBottomTab.info),
                ),
                _HomeBottomTabItem(
                  icon: Icons.chat_bubble_outline,
                  semanticsLabel: '이야기',
                  isSelected: selectedTab == HomeBottomTab.story,
                  onTap: () => onTabSelected(HomeBottomTab.story),
                ),
                _HomeGardenTabItem(
                  isSelected: selectedTab == HomeBottomTab.garden,
                  onTap: () => onTabSelected(HomeBottomTab.garden),
                ),
                _HomeBottomTabItem(
                  icon: Icons.calendar_today_outlined,
                  semanticsLabel: '캘린더',
                  isSelected: selectedTab == HomeBottomTab.calendar,
                  onTap: () => onTabSelected(HomeBottomTab.calendar),
                ),
                _HomeBottomTabItem(
                  icon: selectedTab == HomeBottomTab.my
                      ? Icons.person
                      : Icons.person_outline,
                  semanticsLabel: '마이',
                  iconSize: AppSizes.iconLarge,
                  isSelected: selectedTab == HomeBottomTab.my,
                  onTap: () => onTabSelected(HomeBottomTab.my),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomTabItem extends StatelessWidget {
  const _HomeBottomTabItem({
    required this.icon,
    required this.semanticsLabel,
    required this.isSelected,
    this.iconSize = AppSizes.iconMedium,
    this.onTap,
  });

  final IconData icon;
  final String semanticsLabel;
  final bool isSelected;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: onTap != null,
        selected: isSelected,
        label: semanticsLabel,
        child: InkResponse(
          onTap: onTap,
          child: Center(
            child: _HomeBottomTabContent(
              isSelected: isSelected,
              child: Icon(
                icon,
                size: iconSize,
                color: isSelected
                    ? AppColors.brandStrong
                    : AppColors.iconInactive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeGardenTabItem extends StatelessWidget {
  const _HomeGardenTabItem({required this.isSelected, this.onTap});

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: onTap != null,
        selected: isSelected,
        label: '정원',
        child: InkResponse(
          onTap: onTap,
          child: Center(
            child: _HomeBottomTabContent(
              isSelected: isSelected,
              child: CommonSvgIcon(
                isSelected ? AppIconAssets.plantSelected : AppIconAssets.plant,
                width: AppSizes.iconMedium,
                height: AppSizes.iconMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomTabContent extends StatelessWidget {
  const _HomeBottomTabContent({required this.isSelected, required this.child});

  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.durationOf(context, AppMotion.fast);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        AnimatedContainer(
          key: const ValueKey('homeBottomTabIndicator'),
          duration: duration,
          curve: AppMotion.standardCurve,
          height: isSelected ? AppSpacing.x8 + 6 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: duration,
              curve: AppMotion.standardCurve,
              opacity: isSelected ? 1 : 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.brandAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
