import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_edit_photo_button.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_form_bottom_actions.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_place_picker.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_watering_date_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';

class PlantEditScaffold extends StatelessWidget {
  const PlantEditScaffold({
    required this.nameController,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onChanged,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController nameController;
  final bool canSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              CommonNavigationBar(
                title: '식물 수정',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x20,
                    AppSpacing.x24,
                    AppSpacing.x20,
                    AppSpacing.x24,
                  ),
                  child: Column(
                    children: [
                      const PlantEditPhotoButton(),
                      const SizedBox(height: AppSpacing.x32),
                      CommonTextField(
                        controller: nameController,
                        maxLength: 10,
                        forceFocusedDecoration: true,
                        onChanged: onChanged,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x20,
                  0,
                  AppSpacing.x20,
                  AppSpacing.x16,
                ),
                child: CommonButton(
                  label: '완료',
                  isLoading: isSubmitting,
                  onPressed: canSubmit ? onSubmit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlantCreateScaffold extends StatelessWidget {
  const PlantCreateScaffold({
    required this.places,
    required this.selectedPlaceId,
    required this.wateringDate,
    required this.isSubmitting,
    required this.onPlaceSelected,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  final List<PlantRegistrationPlace> places;
  final String? selectedPlaceId;
  final String wateringDate;
  final bool isSubmitting;
  final ValueChanged<PlantRegistrationPlace> onPlaceSelected;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              CommonNavigationBar(
                title: '식물 등록 (2/2)',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x20,
                    AppSpacing.x24,
                    AppSpacing.x20,
                    AppSpacing.x24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlantPlacePicker(
                        places: places,
                        selectedPlaceId: selectedPlaceId,
                        onPlaceSelected: onPlaceSelected,
                      ),
                      const SizedBox(height: AppSpacing.x32),
                      PlantWateringDateField(date: wateringDate),
                    ],
                  ),
                ),
              ),
              PlantFormBottomActions(
                isSubmitting: isSubmitting,
                onCancel: onCancel,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
