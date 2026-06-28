import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:flutter/material.dart';

class PlantPlacePicker extends StatelessWidget {
  const PlantPlacePicker({
    required this.places,
    required this.selectedPlaceId,
    required this.onPlaceSelected,
    super.key,
  });

  final List<PlantRegistrationPlace> places;
  final String? selectedPlaceId;
  final ValueChanged<PlantRegistrationPlace> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonAddressOrPlaceField(label: '장소 선택'),
        const SizedBox(height: AppSpacing.x4),
        SizedBox(
          height: AppSizes.placeCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.x8),
            itemBuilder: (context, index) {
              final place = places[index];
              final isSelected = place.id == selectedPlaceId;

              return Semantics(
                selected: isSelected,
                child: CommonPlaceCard(
                  title: place.name,
                  imageProvider: AssetImage(place.imageAsset),
                  onTap: () => onPlaceSelected(place),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
