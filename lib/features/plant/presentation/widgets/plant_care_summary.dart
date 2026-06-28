import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_content_width.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class PlantCareSummary extends StatelessWidget {
  const PlantCareSummary({
    super.key,
    required this.name,
    required this.daysTogether,
    required this.dDayLabel,
    required this.startDate,
    required this.lastWateredDate,
  });

  final String name;
  final int daysTogether;
  final String dDayLabel;
  final String startDate;
  final String lastWateredDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlantDetailSectionDivider(),
        PlantDetailContentWidth(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.x24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.size16Medium.copyWith(
                    color: AppColors.textBody,
                  ),
                  children: [
                    TextSpan(text: '$name와 함께한지 '),
                    TextSpan(
                      text: '$daysTogether일',
                      style: AppTextStyles.size18Medium.copyWith(
                        color: AppColors.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: '이 지났어요!'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CommonSvgIcon(
                    AppIconAssets.watering,
                    width: 32,
                    height: 25,
                    color: AppColors.brandAccent,
                    semanticsLabel: '물주기',
                  ),
                  const SizedBox(width: AppSpacing.x8),
                  Text(
                    dDayLabel,
                    style: AppTextStyles.size24Medium.copyWith(
                      fontSize: 28,
                      height: 36 / 28,
                      color: AppColors.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x12),
              _PlantDateSummary(
                startDate: startDate,
                lastWateredDate: lastWateredDate,
              ),
              const SizedBox(height: AppSpacing.x24),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlantDateSummary extends StatelessWidget {
  const _PlantDateSummary({
    required this.startDate,
    required this.lastWateredDate,
  });

  final String startDate;
  final String lastWateredDate;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.size14Medium.copyWith(
      color: AppColors.iconInactive,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('처음 함께한 날', style: textStyle),
            Text('마지막으로 물 준 날짜', style: textStyle),
          ],
        ),
        const SizedBox(width: 34),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startDate, style: textStyle),
            Text(lastWateredDate, style: textStyle),
          ],
        ),
      ],
    );
  }
}
