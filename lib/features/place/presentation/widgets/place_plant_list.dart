import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_view_data.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlacePlantList extends StatelessWidget {
  const PlacePlantList({
    super.key,
    required this.placeId,
    required this.plants,
  });

  final String placeId;
  final List<PlaceDetailPlantItem> plants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x24,
        AppSpacing.x20,
        120,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (plants.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x32),
                child: Text(
                  '등록된 식물이 없어요',
                  style: AppTextStyles.size16Medium.copyWith(
                    color: AppColors.textBody,
                  ),
                ),
              ),
            );
          }
          final columns =
              constraints.maxWidth >=
                  AppSizes.placePlantCardWidth * 2 + AppSpacing.x16
              ? 2
              : 1;
          final cardWidth =
              (constraints.maxWidth - AppSpacing.x16 * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSpacing.x16,
            runSpacing: AppSpacing.x16,
            children: [
              for (final plant in plants)
                CommonPlacePlantCard(
                  width: cardWidth,
                  name: plant.name,
                  species: plant.species,
                  description: plant.description,
                  imageProvider: _imageProvider(plant),
                  action: plant.canWater
                      ? CommonWateringButton(onPressed: () {})
                      : null,
                  trailing: _PlantDueInfo(
                    dDayLabel: plant.dDayLabel,
                    dateLabel: plant.dateLabel,
                    isPrimary: plant.canWater,
                  ),
                  onTap: () => context.push(
                    AppRoutePaths.plantDetailLocation(
                      plant.id,
                      placeId: placeId,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  ImageProvider<Object>? _imageProvider(PlaceDetailPlantItem plant) {
    final imageUrl = plant.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    }

    final imageAsset = plant.imageAsset;
    if (imageAsset != null) {
      return AssetImage(imageAsset);
    }

    return null;
  }
}

class _PlantDueInfo extends StatelessWidget {
  const _PlantDueInfo({
    required this.dDayLabel,
    required this.dateLabel,
    required this.isPrimary,
  });

  final String? dDayLabel;
  final String? dateLabel;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (dDayLabel case final label?)
          Text(
            label,
            style: AppTextStyles.size16Bold.copyWith(
              color: isPrimary
                  ? AppColors.brandPrimary
                  : AppColors.iconInactive,
            ),
          ),
        if (dateLabel case final label?)
          Text(
            label,
            style: AppTextStyles.size12Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
      ],
    );
  }
}
