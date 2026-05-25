import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlantFormPage extends ConsumerStatefulWidget {
  const PlantFormPage({
    super.key,
    this.plantId,
    this.placeId,
    this.initialPlantName,
  });

  final String? plantId;
  final String? placeId;
  final String? initialPlantName;

  bool get isEdit => plantId != null;

  @override
  ConsumerState<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends ConsumerState<PlantFormPage> {
  static const String _defaultEditPlantName = '몬테';

  late final TextEditingController _nameController;
  late final String _selectedPlantName;
  String? _selectedPlaceId;
  bool _isSubmitting = false;

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
    _nameController = TextEditingController(
      text: widget.isEdit ? _defaultEditPlantName : '',
    );
    _selectedPlaceId = widget.isEdit ? null : _places.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEdit) {
      final trimmedName = _nameController.text.trim();
      final canSubmit =
          trimmedName.isNotEmpty &&
          trimmedName != _defaultEditPlantName &&
          !_isSubmitting;

      return _PlantEditScaffold(
        nameController: _nameController,
        canSubmit: canSubmit,
        isSubmitting: _isSubmitting,
        onChanged: (_) => setState(() {}),
        onSubmit: () => _submitEdit(),
      );
    }

    final remotePlaces = ref.watch(plantRegistrationPlaceProvider);
    final registrationPlaces = _registrationPlacesFromSummaries(
      remotePlaces.value ?? const [],
    );
    final places = registrationPlaces.isEmpty ? _places : registrationPlaces;
    final selectedPlaceId = _effectiveSelectedPlaceId(places);

    return _PlantCreateScaffold(
      places: places,
      selectedPlaceId: selectedPlaceId,
      wateringDate: '2023. 01. 30',
      isSubmitting: _isSubmitting,
      onPlaceSelected: (place) => setState(() => _selectedPlaceId = place.id),
      onCancel: _cancelCreate,
      onSubmit: () => _submitCreate(),
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
    final remotePlaces = ref.read(plantRegistrationPlaceProvider).value;
    final places = _registrationPlacesFromSummaries(remotePlaces ?? const []);
    final effectivePlaces = places.isEmpty ? _places : places;
    final selectedPlaceId = _selectedPlaceId;

    if (selectedPlaceId == null) {
      return null;
    }

    for (final place in effectivePlaces) {
      if (place.id == selectedPlaceId) {
        return place;
      }
    }

    return effectivePlaces.isEmpty ? null : effectivePlaces.first;
  }

  String? _effectiveSelectedPlaceId(List<_PlantRegistrationPlace> places) {
    final selectedPlaceId = _selectedPlaceId;

    if (selectedPlaceId != null) {
      for (final place in places) {
        if (place.id == selectedPlaceId) {
          return selectedPlaceId;
        }
      }
    }

    return places.isEmpty ? null : places.first.id;
  }

  void _cancelCreate() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutePaths.home);
  }

  Future<void> _submitCreate() async {
    if (_isSubmitting) {
      return;
    }

    final selectedPlace = _selectedPlace;

    if (selectedPlace == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (ref.read(useRemoteApiProvider)) {
        try {
          await ref
              .read(plantRepositoryProvider)
              .createPlant(
                CreatePlantRequest(
                  placeCode: selectedPlace.id,
                  nickname: _selectedPlantName,
                  scientificNameKo: _selectedPlantName,
                ),
              );
          ref.invalidate(remotePlantListProvider);
        } catch (error) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('식물 등록에 실패했어요: $error')));
          return;
        }
      }

      if (!mounted) {
        return;
      }

      ref
          .read(plantListProvider.notifier)
          .addPlant(
            name: _selectedPlantName,
            placeId: selectedPlace.id,
            placeName: selectedPlace.name,
          );
      context.go(AppRoutePaths.home);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitEdit() async {
    if (_isSubmitting) {
      return;
    }

    final name = _nameController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      if (ref.read(useRemoteApiProvider) && widget.placeId != null) {
        try {
          await ref
              .read(plantRepositoryProvider)
              .updatePlant(
                plantId: widget.plantId!,
                placeCode: widget.placeId!,
                request: UpdatePlantRequest(nickname: name),
              );
          ref.invalidate(remotePlantListProvider);
        } catch (error) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('식물 수정에 실패했어요: $error')));
          return;
        }
      }

      if (!mounted) {
        return;
      }

      ref
          .read(plantListProvider.notifier)
          .updatePlant(id: widget.plantId!, name: name);
      context.go(
        AppRoutePaths.plantDetailLocation(
          widget.plantId!,
          placeId: widget.placeId,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  List<_PlantRegistrationPlace> _registrationPlacesFromSummaries(
    List<PlaceSummary> summaries,
  ) {
    return [
      for (final place in summaries)
        _PlantRegistrationPlace(
          id: place.id,
          name: place.name,
          imageAsset: AppImageAssets.placeEditLivingRoom,
        ),
    ];
  }
}

class _PlantEditScaffold extends StatelessWidget {
  const _PlantEditScaffold({
    required this.nameController,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onChanged,
    required this.onSubmit,
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
                      const _PlantEditPhotoButton(),
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

class _PlantEditPhotoButton extends StatelessWidget {
  const _PlantEditPhotoButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.plantEditPhotoCanvasSize,
      height: AppSizes.plantEditPhotoCanvasSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: AppSpacing.x10,
            top: AppSpacing.x10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.asset(
                AppImageAssets.plantEditMonstera,
                width: AppSizes.plantEditPhotoImageSize,
                height: AppSizes.plantEditPhotoImageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: AppSizes.plantEditPhotoOverlayOffset,
            top: AppSizes.plantEditPhotoOverlayOffset,
            child: Semantics(
              label: '식물 사진 수정',
              button: true,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.iconInactive,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: AppSizes.plantEditPhotoCameraSize,
                  child: Center(
                    child: CommonSvgIcon(
                      AppIconAssets.cameraAlt,
                      width: AppSizes.iconLarge,
                      height: AppSizes.iconLarge,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantCreateScaffold extends StatelessWidget {
  const _PlantCreateScaffold({
    required this.places,
    required this.selectedPlaceId,
    required this.wateringDate,
    required this.isSubmitting,
    required this.onPlaceSelected,
    required this.onCancel,
    required this.onSubmit,
  });

  final List<_PlantRegistrationPlace> places;
  final String? selectedPlaceId;
  final String wateringDate;
  final bool isSubmitting;
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
              _PlantFormBottomActions(
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
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSubmitting;
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
              isLoading: isSubmitting,
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
