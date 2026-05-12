import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_photo_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlantFormPage extends ConsumerStatefulWidget {
  const PlantFormPage({super.key, this.plantId, this.initialPlantName});

  final String? plantId;
  final String? initialPlantName;

  bool get isEdit => plantId != null;

  @override
  ConsumerState<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends ConsumerState<PlantFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final String _selectedPlantName;
  String? _place;
  String? _wateringDate;
  String? _selectedPlaceId;

  static const List<_PlantRegistrationPlace> _places = [
    _PlantRegistrationPlace(
      id: 'place-1',
      name: '스윗 홈_거실',
      imageAsset: AppImageAssets.placeEditLivingRoom,
    ),
    _PlantRegistrationPlace(
      id: 'place-2',
      name: '낫 스윗 회사_가든',
      imageAsset: AppImageAssets.placeDetailMonstera,
    ),
    _PlantRegistrationPlace(
      id: 'place-3',
      name: '집_작업실',
      imageAsset: AppImageAssets.placeEditLivingRoom,
    ),
    _PlantRegistrationPlace(
      id: 'place-4',
      name: '본가_거실',
      imageAsset: AppImageAssets.placeDetailMonstera,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlantName = _normalizedInitialPlantName();
    _nameController = TextEditingController(text: widget.isEdit ? '몬스테라' : '');
    _descriptionController = TextEditingController(
      text: widget.isEdit ? '거실 창가 오른쪽에서 키우는 중' : '',
    );
    _place = widget.isEdit ? '우리집 거실' : null;
    _wateringDate = widget.isEdit ? '2026.05.05' : null;
    _selectedPlaceId = widget.isEdit ? null : _places.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEdit) {
      return _PlantCreateScaffold(
        places: _places,
        selectedPlaceId: _selectedPlaceId,
        wateringDate: '2023. 01. 30',
        onPlaceSelected: (place) => setState(() => _selectedPlaceId = place.id),
        onCancel: _cancelCreate,
        onSubmit: _submitCreate,
      );
    }

    final canSubmit = _nameController.text.trim().isNotEmpty && _place != null;

    return CommonScaffold(
      title: widget.isEdit ? '식물 수정' : '식물 등록',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CommonPhotoAddButton(currentCount: widget.isEdit ? 1 : 0),
              const SizedBox(width: AppSpacing.x16),
              Expanded(
                child: Text(
                  '식물 사진은 최대 5장까지 추가할 수 있어요.',
                  style: AppTextStyles.size14Medium.copyWith(
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x32),
          Text(
            '식물 이름',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonTextField(
            controller: _nameController,
            hintText: '식물 이름을 입력해 주세요',
            maxLength: 20,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          CommonAddressOrPlaceField(
            label: '장소',
            value: _place,
            onTap: () => setState(() => _place = '우리집 거실'),
            onClear: () => setState(() => _place = null),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonAddressOrPlaceField(
            label: '마지막 물준 날',
            value: _wateringDate,
            onTap: () => setState(() => _wateringDate = '2026.05.06'),
            onClear: () => setState(() => _wateringDate = null),
          ),
          const SizedBox(height: AppSpacing.x24),
          Text(
            '메모',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonTextField(
            controller: _descriptionController,
            hintText: '관리 위치나 특징을 입력해 주세요',
            maxLength: 40,
          ),
          const SizedBox(height: AppSpacing.x24),
          Phase0Section(
            title: '관리 태그',
            child: const Wrap(
              spacing: AppSpacing.x8,
              runSpacing: AppSpacing.x8,
              children: [
                Phase0Chip(label: '공기정화', isActive: true),
                Phase0Chip(label: '초보자 추천', isActive: true),
                Phase0Chip(label: '간접광'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x32),
          CommonButton(
            label: widget.isEdit ? '저장' : '등록',
            onPressed: canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }

  String _normalizedInitialPlantName() {
    final plantName = widget.initialPlantName?.trim();

    if (plantName == null || plantName.isEmpty) {
      return '몬스테라 델리오사';
    }

    return plantName;
  }

  _PlantRegistrationPlace? get _selectedPlace {
    final selectedPlaceId = _selectedPlaceId;

    if (selectedPlaceId == null) {
      return null;
    }

    for (final place in _places) {
      if (place.id == selectedPlaceId) {
        return place;
      }
    }

    return null;
  }

  void _cancelCreate() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutePaths.home);
  }

  void _submitCreate() {
    final selectedPlace = _selectedPlace;

    if (selectedPlace == null) {
      return;
    }

    ref
        .read(plantListProvider.notifier)
        .addPlant(name: _selectedPlantName, placeName: selectedPlace.name);
    context.go(AppRoutePaths.home);
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.isEdit) {
      ref
          .read(plantListProvider.notifier)
          .updatePlant(
            id: widget.plantId!,
            name: name,
            placeName: _place,
            description: description.isEmpty ? null : description,
          );
      context.go(AppRoutePaths.plantDetailLocation(widget.plantId!));
      return;
    }

    ref
        .read(plantListProvider.notifier)
        .addPlant(
          name: name,
          placeName: _place,
          description: description.isEmpty ? null : description,
        );
    context.go(AppRoutePaths.home);
  }
}

class _PlantCreateScaffold extends StatelessWidget {
  const _PlantCreateScaffold({
    required this.places,
    required this.selectedPlaceId,
    required this.wateringDate,
    required this.onPlaceSelected,
    required this.onCancel,
    required this.onSubmit,
  });

  final List<_PlantRegistrationPlace> places;
  final String? selectedPlaceId;
  final String wateringDate;
  final ValueChanged<_PlantRegistrationPlace> onPlaceSelected;
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
                      _PlantPlacePicker(
                        places: places,
                        selectedPlaceId: selectedPlaceId,
                        onPlaceSelected: onPlaceSelected,
                      ),
                      const SizedBox(height: AppSpacing.x32),
                      _PlantWateringDateField(date: wateringDate),
                    ],
                  ),
                ),
              ),
              _PlantFormBottomActions(onCancel: onCancel, onSubmit: onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantPlacePicker extends StatelessWidget {
  const _PlantPlacePicker({
    required this.places,
    required this.selectedPlaceId,
    required this.onPlaceSelected,
  });

  final List<_PlantRegistrationPlace> places;
  final String? selectedPlaceId;
  final ValueChanged<_PlantRegistrationPlace> onPlaceSelected;

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

class _PlantWateringDateField extends StatelessWidget {
  const _PlantWateringDateField({required this.date});

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

class _PlantFormBottomActions extends StatelessWidget {
  const _PlantFormBottomActions({
    required this.onCancel,
    required this.onSubmit,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        0,
        AppSpacing.x20,
        AppSpacing.x16,
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonButton.dark(
              label: '취소',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.textBody,
              foregroundColor: AppColors.white,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: AppSpacing.x8),
          Expanded(
            child: CommonButton(
              label: '등록',
              size: CommonButtonSize.medium,
              backgroundColor: AppColors.brandAccent,
              foregroundColor: AppColors.white,
              onPressed: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantRegistrationPlace {
  const _PlantRegistrationPlace({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String imageAsset;
}
