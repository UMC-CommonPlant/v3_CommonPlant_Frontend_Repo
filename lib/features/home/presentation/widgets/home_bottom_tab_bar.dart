import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class HomeBottomTabBar extends StatelessWidget {
  const HomeBottomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFDFD),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: const [
                _HomeBottomTabItem(
                  icon: Icons.article_outlined,
                  semanticsLabel: '정보',
                ),
                _HomeBottomTabItem(
                  icon: Icons.chat_bubble_outline,
                  semanticsLabel: '이야기',
                ),
                _HomeGardenTabItem(isSelected: true),
                _HomeBottomTabItem(
                  icon: Icons.calendar_today_outlined,
                  semanticsLabel: '캘린더',
                ),
                _HomeBottomTabItem(
                  icon: Icons.person_outline,
                  semanticsLabel: '마이',
                  iconSize: AppSizes.iconLarge,
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
    this.iconSize = AppSizes.iconMedium,
  });

  final IconData icon;
  final String semanticsLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: AppColors.textDisabled,
          semanticLabel: semanticsLabel,
        ),
      ),
    );
  }
}

class _HomeGardenTabItem extends StatelessWidget {
  const _HomeGardenTabItem({this.isSelected = true});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonSvgIcon(
              isSelected ? AppIconAssets.plantSelected : AppIconAssets.plant,
              width: 24,
              height: 24,
              semanticsLabel: '정원',
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.x8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.brandAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
