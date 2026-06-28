import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_content_width.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class PlantInfoSection extends StatelessWidget {
  const PlantInfoSection({super.key, required this.wateringCycleLabel});

  final String wateringCycleLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlantDetailSectionDivider(),
        PlantDetailContentWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.x10),
                      child: Text(
                        '식물정보',
                        style: AppTextStyles.size18Medium.copyWith(
                          color: AppColors.iconInactive,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FBF9),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.x16),
                      child: Row(
                        children: [
                          const CommonSvgIcon(
                            AppIconAssets.watering,
                            width: 24,
                            height: 24,
                            semanticsLabel: '물주기 주기',
                          ),
                          const SizedBox(width: AppSpacing.x8),
                          Text(
                            wateringCycleLabel,
                            style: AppTextStyles.size14Medium.copyWith(
                              color: AppColors.textStrong,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
