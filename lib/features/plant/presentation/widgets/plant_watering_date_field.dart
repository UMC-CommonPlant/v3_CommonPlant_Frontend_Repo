import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PlantWateringDateField extends StatelessWidget {
  const PlantWateringDateField({required this.date, super.key});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColorPrimitives.grayGray2),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.addressOrPlaceFieldHeight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '마지막으로 물 준 날짜',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.size18Medium.copyWith(
                      color: AppColors.textStrong,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.x12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDisabled,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: AppSpacing.x8,
                    ),
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size18Medium.copyWith(
                        color: AppColors.textStrong,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        Text(
          '선택하지 않을 시, 등록일을 기준으로 설정합니다',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size12Medium.copyWith(
            color: AppColors.brandStrong,
          ),
        ),
      ],
    );
  }
}
