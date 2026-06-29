import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_image_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';

class PlaceCreateScaffold extends StatelessWidget {
  const PlaceCreateScaffold({
    super.key,
    required this.nameController,
    required this.address,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onNameChanged,
    required this.onImageTap,
    required this.onAddressTap,
    required this.onAddressClear,
    required this.onNext,
  });

  final TextEditingController nameController;
  final String? address;
  final bool canSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onImageTap;
  final VoidCallback onAddressTap;
  final VoidCallback onAddressClear;
  final VoidCallback onNext;

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
                title: '장소 등록',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x20,
                        AppSpacing.x24,
                        AppSpacing.x20,
                        AppSizes.buttonHeight + AppSpacing.x40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: CommonPlaceImageAddButton(onTap: onImageTap),
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonTextField(
                            controller: nameController,
                            hintText: '장소의 이름을 입력해 주세요',
                            maxLength: 10,
                            onChanged: onNameChanged,
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonAddressOrPlaceField(
                            label: '주소',
                            value: address,
                            onTap: onAddressTap,
                            onClear: onAddressClear,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.x20,
                      right: AppSpacing.x20,
                      bottom: AppSpacing.x16,
                      child: CommonButton(
                        label: '다음',
                        isLoading: isSubmitting,
                        onPressed: canSubmit ? onNext : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceEditScaffold extends StatelessWidget {
  const PlaceEditScaffold({
    super.key,
    required this.nameController,
    required this.address,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onNameChanged,
    required this.onImageTap,
    required this.onAddressTap,
    required this.onAddressClear,
    required this.onComplete,
  });

  final TextEditingController nameController;
  final String? address;
  final bool canSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onImageTap;
  final VoidCallback onAddressTap;
  final VoidCallback onAddressClear;
  final VoidCallback onComplete;

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
                title: '장소 수정',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x20,
                        AppSpacing.x24,
                        AppSpacing.x20,
                        AppSizes.buttonHeight + AppSpacing.x40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: CommonPlaceImageAddButton(
                              imageAsset: AppImageAssets.placeEditLivingRoom,
                              imageSemanticsLabel: '장소 대표 이미지',
                              onTap: onImageTap,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonTextField(
                            controller: nameController,
                            hintText: '장소 이름을 입력해 주세요',
                            maxLength: 10,
                            forceFocusedDecoration: true,
                            onChanged: onNameChanged,
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonAddressOrPlaceField(
                            label: '주소',
                            value: address,
                            onTap: onAddressTap,
                            onClear: onAddressClear,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.x20,
                      right: AppSpacing.x20,
                      bottom: AppSpacing.x16,
                      child: CommonButton(
                        label: '완료',
                        isLoading: isSubmitting,
                        onPressed: canSubmit ? onComplete : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
