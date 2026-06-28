import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailPlantItem {
  const PlaceDetailPlantItem({
    required this.id,
    required this.name,
    required this.species,
    required this.description,
    required this.dDayLabel,
    required this.dateLabel,
    this.canWater = false,
  });

  final String id;
  final String name;
  final String species;
  final String description;
  final String dDayLabel;
  final String dateLabel;
  final bool canWater;
}

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
      child: Column(
        children: [
          for (final plant in plants) ...[
            CommonPlacePlantCard(
              width: double.infinity,
              name: plant.name,
              species: plant.species,
              description: plant.description,
              imageProvider: const AssetImage(
                AppImageAssets.placeDetailMonstera,
              ),
              action: CommonWateringButton(
                onPressed: plant.canWater ? () {} : null,
              ),
              trailing: _PlantDueInfo(
                dDayLabel: plant.dDayLabel,
                dateLabel: plant.dateLabel,
                isPrimary: plant.canWater,
              ),
              onTap: () => context.push(
                AppRoutePaths.plantDetailLocation(plant.id, placeId: placeId),
              ),
            ),
            if (plant != plants.last) const SizedBox(height: AppSpacing.x16),
          ],
        ],
      ),
    );
  }
}

class _PlantDueInfo extends StatelessWidget {
  const _PlantDueInfo({
    required this.dDayLabel,
    required this.dateLabel,
    required this.isPrimary,
  });

  final String dDayLabel;
  final String dateLabel;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dDayLabel,
          style: AppTextStyles.size16Bold.copyWith(
            color: isPrimary ? AppColors.brandPrimary : AppColors.iconInactive,
          ),
        ),
        Text(
          dateLabel,
          style: AppTextStyles.size12Medium.copyWith(color: AppColors.textBody),
        ),
      ],
    );
  }
}
