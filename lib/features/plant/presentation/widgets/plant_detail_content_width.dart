import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class PlantDetailContentWidth extends StatelessWidget {
  const PlantDetailContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
        child: child,
      ),
    );
  }
}

class PlantDetailSectionDivider extends StatelessWidget {
  const PlantDetailSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: ValueKey('plant-detail-section-divider'),
      height: AppSpacing.x8,
      width: double.infinity,
      child: ColoredBox(color: AppColors.surfaceDisabled),
    );
  }
}
