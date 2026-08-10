import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantFormControllerProvider = NotifierProvider.autoDispose
    .family<PlantFormController, PlantFormState, PlantFormArgs>(
      PlantFormController.new,
    );

enum PlantFormSubmitDestination { home, plantDetail }

class PlantFormSubmitResult {
  const PlantFormSubmitResult._({
    required this.destination,
    this.plantId,
    this.placeId,
  });

  const PlantFormSubmitResult.home()
    : this._(destination: PlantFormSubmitDestination.home);

  const PlantFormSubmitResult.plantDetail({
    required String plantId,
    String? placeId,
  }) : this._(
         destination: PlantFormSubmitDestination.plantDetail,
         plantId: plantId,
         placeId: placeId,
       );

  final PlantFormSubmitDestination destination;
  final String? plantId;
  final String? placeId;
}

class PlantFormController extends Notifier<PlantFormState> {
  PlantFormController(this.args);

  final PlantFormArgs args;

  @override
  PlantFormState build() {
    final plantId = args.plantId;

    if (plantId != null) {
      return ref
          .watch(plantFormEditInfoProvider(plantId))
          .when(
            data: (info) {
              if (info == null) {
                return PlantFormState.notFound(
                  plantId: plantId,
                  placeId: args.placeId,
                );
              }

              return PlantFormState.edit(
                plantId: plantId,
                placeId: args.placeId,
                name: info.name.trim(),
              );
            },
            error: (error, stackTrace) => PlantFormState.failure(
              plantId: plantId,
              placeId: args.placeId,
              message: '식물 수정 정보를 불러오지 못했어요',
            ),
            loading: () => PlantFormState.loadingEdit(
              plantId: plantId,
              placeId: args.placeId,
            ),
          );
    }

    ref.listen(plantRegistrationPlaceProvider, (previous, next) {
      final places = _effectivePlaces(next.value ?? const []);
      final selectedPlaceId = _effectiveSelectedPlaceId(
        places,
        state.selectedPlaceId,
      );

      state = state.copyWith(places: places, selectedPlaceId: selectedPlaceId);
    });

    return PlantFormState.create(
      plantName: _normalizedInitialPlantName(args.initialPlantName),
      places: _effectivePlaces(
        ref.read(plantRegistrationPlaceProvider).value ?? const [],
      ),
    );
  }

  void updateName(String name) {
    if (state.loadStatus != PlantFormLoadStatus.ready) {
      return;
    }

    state = state.copyWith(
      currentName: name,
      submitState: const FormSubmitState.idle(),
    );
  }

  void selectPlace(PlantRegistrationPlace place) {
    if (state.isEdit || !state.places.any((item) => item.id == place.id)) {
      return;
    }

    state = state.copyWith(
      selectedPlaceId: place.id,
      submitState: const FormSubmitState.idle(),
    );
  }

  void retryLoad() {
    final plantId = args.plantId;

    if (plantId == null) {
      return;
    }

    ref.invalidate(remotePlantEditInfoProvider(plantId));
    ref.invalidate(remotePlantFormEditInfoProvider(plantId));
  }

  Future<PlantFormSubmitResult?> submit() async {
    if (!state.canSubmit) {
      return null;
    }

    final isEdit = state.isEdit;
    state = state.copyWith(submitState: const FormSubmitState.submitting());

    try {
      final result = isEdit ? await _update() : await _create();
      state = state.copyWith(submitState: const FormSubmitState.idle());

      return result;
    } catch (_) {
      state = state.copyWith(
        submitState: FormSubmitState.failure(
          isEdit ? '식물 수정에 실패했어요' : '식물 등록에 실패했어요',
        ),
      );

      return null;
    }
  }

  Future<PlantFormSubmitResult> _create() async {
    final plantName = state.currentName.trim();
    final selectedPlace = state.selectedPlace!;

    if (ref.read(useRemoteApiProvider)) {
      await ref
          .read(plantRepositoryProvider)
          .createPlant(
            placeCode: selectedPlace.id,
            nickname: plantName,
            scientificNameKo: plantName,
          );
      ref.invalidate(remotePlantListProvider);
    }

    ref
        .read(plantListProvider.notifier)
        .addPlant(
          name: plantName,
          placeId: selectedPlace.id,
          placeName: selectedPlace.name,
        );

    return const PlantFormSubmitResult.home();
  }

  Future<PlantFormSubmitResult> _update() async {
    final plantId = state.plantId!;
    final plantName = state.currentName.trim();
    final placeId = state.placeId;

    if (ref.read(useRemoteApiProvider) && placeId != null) {
      await ref
          .read(plantRepositoryProvider)
          .updatePlant(
            plantId: plantId,
            placeCode: placeId,
            nickname: plantName,
          );
      ref.invalidate(remotePlantListProvider);
    }

    ref
        .read(plantListProvider.notifier)
        .updatePlant(id: plantId, name: plantName);

    return PlantFormSubmitResult.plantDetail(
      plantId: plantId,
      placeId: placeId,
    );
  }
}

List<PlantRegistrationPlace> _effectivePlaces(
  List<PlantRegistrationPlace> places,
) {
  return places.isEmpty ? plantRegistrationPlaceFallbacks : places;
}

String? _effectiveSelectedPlaceId(
  List<PlantRegistrationPlace> places,
  String? selectedPlaceId,
) {
  if (selectedPlaceId != null &&
      places.any((place) => place.id == selectedPlaceId)) {
    return selectedPlaceId;
  }

  return places.isEmpty ? null : places.first.id;
}

String _normalizedInitialPlantName(String? initialPlantName) {
  final plantName = initialPlantName?.trim();

  if (plantName == null || plantName.isEmpty) {
    return '몬스테라 델리오사';
  }

  return plantName;
}
