import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_registration_place_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String plantFormImagePreservationMessage =
    '기존 사진 정보를 확인할 수 없어 수정하지 못했어요. 다시 불러와 주세요.';

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
    final useRemoteApi = ref.watch(useRemoteApiProvider);
    if (useRemoteApi) {
      ref.watch(userDataSessionProvider);
    }
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
                imageKey: info.imageKey,
                imageUrl: info.imageUrl,
                lastWateredDate: _normalizedLastWateredDate(
                  info.lastWateredDate,
                ),
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
      state = _withRegistrationPlaces(state, next, useRemoteApi: useRemoteApi);
    });

    return _withRegistrationPlaces(
      PlantFormState.create(
        plantName: _normalizedInitialPlantName(args.initialPlantName),
        places: const [],
      ),
      ref.read(plantRegistrationPlaceProvider),
      useRemoteApi: useRemoteApi,
    );
  }

  void updateName(String name) {
    if (state.loadStatus != PlantFormLoadStatus.ready) {
      return;
    }

    state = state.copyWith(
      currentName: name,
      submitState: state.isSubmitting
          ? state.submitState
          : const FormSubmitState.idle(),
    );
  }

  void updateLastWateredDate(DateTime date) {
    if (state.loadStatus != PlantFormLoadStatus.ready) {
      return;
    }

    state = state.copyWith(
      currentLastWateredDate: _formatPlantWateringDate(date),
      submitState: state.isSubmitting
          ? state.submitState
          : const FormSubmitState.idle(),
    );
  }

  void selectPlace(PlantRegistrationPlace place) {
    _syncRegistrationPlaces();
    if (state.isEdit ||
        state.loadStatus != PlantFormLoadStatus.ready ||
        !state.places.any((item) => item.id == place.id)) {
      return;
    }

    state = state.copyWith(
      selectedPlaceId: place.id,
      submitState: state.isSubmitting
          ? state.submitState
          : const FormSubmitState.idle(),
    );
  }

  void retryLoad() {
    final plantId = args.plantId;

    if (plantId == null) {
      ref.invalidate(userPlaceSummariesProvider);
      return;
    }

    ref.invalidate(remotePlantEditInfoProvider(plantId));
    ref.invalidate(remotePlantFormEditInfoProvider(plantId));
  }

  Future<PlantFormSubmitResult?> submit() async {
    _syncRegistrationPlaces();
    if (!state.canSubmit) {
      return null;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (ref.read(useRemoteApiProvider) && !session.isActive) return null;
    if (state.isEdit &&
        ref.read(useRemoteApiProvider) &&
        state.hasUnresolvedImage) {
      state = state.copyWith(
        submitState: const FormSubmitState.failure(
          plantFormImagePreservationMessage,
        ),
      );
      return null;
    }

    final isEdit = state.isEdit;
    state = state.copyWith(submitState: const FormSubmitState.submitting());

    try {
      final result = isEdit
          ? await _update(requestRef, session)
          : await _create(requestRef, session);
      if (result == null || !isCurrentUserDataSession(requestRef, session)) {
        return null;
      }
      state = state.copyWith(submitState: const FormSubmitState.idle());

      return result;
    } catch (_) {
      if (!isCurrentUserDataSession(requestRef, session)) return null;
      state = state.copyWith(
        submitState: FormSubmitState.failure(
          isEdit ? '식물 수정에 실패했어요' : '식물 등록에 실패했어요',
        ),
      );

      return null;
    }
  }

  void _syncRegistrationPlaces() {
    if (args.isEdit || !ref.read(useRemoteApiProvider)) return;

    // 화면 재빌드 전의 콜백도 무효화된 장소 목록으로 등록하지 못하게 한다.
    final places = ref.read(plantRegistrationPlaceProvider);
    state = _withRegistrationPlaces(state, places, useRemoteApi: true);
  }

  Future<PlantFormSubmitResult?> _create(
    Ref requestRef,
    UserDataSession session,
  ) async {
    final plantName = state.currentName.trim();
    final selectedPlace = state.selectedPlace!;

    if (ref.read(useRemoteApiProvider)) {
      await ref
          .read(plantRepositoryProvider)
          .createPlant(
            placeCode: selectedPlace.id,
            nickname: plantName,
            lastWateredDate: state.currentLastWateredDate,
          );
      if (!isCurrentUserDataSession(requestRef, session)) return null;
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

  Future<PlantFormSubmitResult?> _update(
    Ref requestRef,
    UserDataSession session,
  ) async {
    final plantId = state.plantId!;
    final plantName = state.currentName.trim();
    final placeId = state.placeId;

    if (ref.read(useRemoteApiProvider) && placeId != null) {
      await ref
          .read(plantRepositoryProvider)
          .updatePlant(
            plantId: plantId,
            placeCode: placeId,
            imageKey: state.initialImageKey,
            nickname: plantName,
            lastWateredDate: state.currentLastWateredDate,
          );
      if (!isCurrentUserDataSession(requestRef, session)) return null;
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

PlantFormState _withRegistrationPlaces(
  PlantFormState state,
  AsyncValue<List<PlantRegistrationPlace>> value, {
  required bool useRemoteApi,
}) {
  final current = value.unwrapPrevious();
  if (!useRemoteApi) {
    final places = current.value ?? const [];
    return _withLoadedPlaces(
      state,
      places.isEmpty ? plantRegistrationPlaceFallbacks : places,
    );
  }

  return current.when(
    skipLoadingOnRefresh: false,
    skipLoadingOnReload: false,
    data: (places) => _withLoadedPlaces(state, places),
    loading: () => state.copyWith(
      loadStatus: PlantFormLoadStatus.loading,
      loadErrorMessage: null,
      places: const [],
      selectedPlaceId: null,
    ),
    error: (error, stackTrace) => state.copyWith(
      loadStatus: PlantFormLoadStatus.failure,
      loadErrorMessage: '등록할 장소를 불러오지 못했어요',
      places: const [],
      selectedPlaceId: null,
    ),
  );
}

PlantFormState _withLoadedPlaces(
  PlantFormState state,
  List<PlantRegistrationPlace> places,
) {
  return state.copyWith(
    loadStatus: places.isEmpty
        ? PlantFormLoadStatus.empty
        : PlantFormLoadStatus.ready,
    loadErrorMessage: null,
    places: places,
    selectedPlaceId: _effectiveSelectedPlaceId(places, state.selectedPlaceId),
  );
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

String? _normalizedLastWateredDate(String? lastWateredDate) {
  final normalized = lastWateredDate?.trim();

  return normalized == null || normalized.isEmpty ? null : normalized;
}

String _formatPlantWateringDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}
