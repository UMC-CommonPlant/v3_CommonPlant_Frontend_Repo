import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_form_scaffold.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_state_view.dart';
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
  late final TextEditingController _nameController;
  late final String _selectedPlantName;
  String? _selectedPlaceId;
  String _initialEditPlantName = plantFormDefaultEditName;
  bool _hasAppliedEditInfo = false;

  @override
  void initState() {
    super.initState();
    _selectedPlantName = _normalizedInitialPlantName();
    _nameController = TextEditingController(
      text: widget.isEdit ? plantFormDefaultEditName : '',
    );
    _selectedPlaceId = widget.isEdit
        ? null
        : plantRegistrationPlaceFallbacks.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEdit) {
      return _buildEditRoute();
    }

    final remotePlaces = ref.watch(plantRegistrationPlaceProvider);
    final registrationPlaces = _registrationPlacesFromSummaries(
      remotePlaces.value ?? const [],
    );
    final isSubmitting = ref.watch(plantFormControllerProvider).isSubmitting;
    final places = registrationPlaces.isEmpty
        ? plantRegistrationPlaceFallbacks
        : registrationPlaces;
    final selectedPlaceId = _effectiveSelectedPlaceId(places);

    return PlantCreateScaffold(
      places: places,
      selectedPlaceId: selectedPlaceId,
      wateringDate: '2023. 01. 30',
      isSubmitting: isSubmitting,
      onPlaceSelected: (place) => setState(() => _selectedPlaceId = place.id),
      onCancel: _cancelCreate,
      onSubmit: () => _submitCreate(),
    );
  }

  Widget _buildEditRoute() {
    final plantId = widget.plantId!;
    final editInfo = ref.watch(plantFormEditInfoProvider(plantId));

    return editInfo.when(
      data: (info) {
        if (info == null) {
          return const PlantStateScaffold(
            title: '식물 수정',
            statusTitle: '식물 수정 정보를 찾을 수 없어요',
            message: '다시 식물 상세에서 수정해 주세요',
          );
        }

        _applyEditInfo(info);

        return _buildEditScaffold();
      },
      error: (error, stackTrace) => PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '식물 수정 정보를 불러오지 못했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () => invalidatePlantFormEditInfo(ref, plantId),
      ),
      loading: () => const PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '식물 수정 정보를 불러오고 있어요',
        message: '식물 이름과 사진 정보를 준비하고 있어요',
        isLoading: true,
      ),
    );
  }

  Widget _buildEditScaffold() {
    final isSubmitting = ref.watch(plantFormControllerProvider).isSubmitting;
    final trimmedName = _nameController.text.trim();
    final canSubmit =
        trimmedName.isNotEmpty &&
        trimmedName != _initialEditPlantName &&
        !isSubmitting;

    return PlantEditScaffold(
      nameController: _nameController,
      canSubmit: canSubmit,
      isSubmitting: isSubmitting,
      onChanged: (_) => setState(() {}),
      onSubmit: () => _submitEdit(),
    );
  }

  void _applyEditInfo(PlantEditInfo info) {
    if (_hasAppliedEditInfo) {
      return;
    }

    final name = info.name.trim();

    _initialEditPlantName = name;
    _nameController.text = name;
    _nameController.selection = TextSelection.collapsed(offset: name.length);
    _hasAppliedEditInfo = true;
  }

  String _normalizedInitialPlantName() {
    final plantName = widget.initialPlantName?.trim();

    if (plantName == null || plantName.isEmpty) {
      return '몬스테라 델리오사';
    }

    return plantName;
  }

  PlantRegistrationPlace? get _selectedPlace {
    final remotePlaces = ref.read(plantRegistrationPlaceProvider).value;
    final places = _registrationPlacesFromSummaries(remotePlaces ?? const []);
    final effectivePlaces = places.isEmpty
        ? plantRegistrationPlaceFallbacks
        : places;
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

  String? _effectiveSelectedPlaceId(List<PlantRegistrationPlace> places) {
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
    if (ref.read(plantFormControllerProvider).isSubmitting) {
      return;
    }

    final selectedPlace = _selectedPlace;

    if (selectedPlace == null) {
      return;
    }

    final result = await ref
        .read(plantFormControllerProvider.notifier)
        .submit(
          PlantFormSubmitInput.create(
            plantName: _selectedPlantName,
            placeId: selectedPlace.id,
            placeName: selectedPlace.name,
          ),
        );

    if (!mounted) {
      return;
    }

    if (result?.destination == PlantFormSubmitDestination.home) {
      context.go(AppRoutePaths.home);
      return;
    }

    _showSubmitErrorSnackBar();
  }

  Future<void> _submitEdit() async {
    if (ref.read(plantFormControllerProvider).isSubmitting) {
      return;
    }

    final name = _nameController.text.trim();
    final result = await ref
        .read(plantFormControllerProvider.notifier)
        .submit(
          PlantFormSubmitInput.update(
            plantId: widget.plantId!,
            plantName: name,
            placeId: widget.placeId,
          ),
        );

    if (!mounted) {
      return;
    }

    if (result?.destination == PlantFormSubmitDestination.plantDetail &&
        result?.plantId != null) {
      context.go(
        AppRoutePaths.plantDetailLocation(
          result!.plantId!,
          placeId: result.placeId,
        ),
      );
      return;
    }

    _showSubmitErrorSnackBar();
  }

  void _showSubmitErrorSnackBar() {
    final errorMessage = ref.read(plantFormControllerProvider).errorMessage;

    if (!mounted || errorMessage == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  List<PlantRegistrationPlace> _registrationPlacesFromSummaries(
    List<PlaceSummary> summaries,
  ) {
    return [
      for (final place in summaries)
        PlantRegistrationPlace(
          id: place.id,
          name: place.name,
          imageAsset: AppImageAssets.placeEditLivingRoom,
        ),
    ];
  }
}
