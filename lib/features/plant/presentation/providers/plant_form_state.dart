import 'package:commonplant_frontend/features/image/data/models/selected_image.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_registration_place.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';

enum PlantFormMode { create, edit }

enum PlantFormLoadStatus {
  loading,
  ready,
  empty,
  notFound,
  missingPlace,
  failure,
}

class PlantFormArgs {
  const PlantFormArgs({this.plantId, this.placeId, this.initialPlantName});

  final String? plantId;
  final String? placeId;
  final String? initialPlantName;

  bool get isEdit => plantId != null;

  @override
  bool operator ==(Object other) {
    return other is PlantFormArgs &&
        other.plantId == plantId &&
        other.placeId == placeId &&
        other.initialPlantName == initialPlantName;
  }

  @override
  int get hashCode => Object.hash(plantId, placeId, initialPlantName);
}

class PlantFormState {
  const PlantFormState({
    required this.plantId,
    required this.placeId,
    required this.mode,
    required this.initialName,
    required this.currentName,
    required this.initialLastWateredDate,
    required this.currentLastWateredDate,
    required this.places,
    required this.selectedPlaceId,
    required this.loadStatus,
    required this.submitState,
    this.selectedImage,
    this.isPickingImage = false,
    this.initialImageKey,
    this.initialImageUrl,
    this.loadErrorMessage,
    this.initialWateringCycleDays,
    this.editedWateringCycleInput,
    this.wateringCycleSupported = false,
  });

  PlantFormState.create({
    required String plantName,
    required List<PlantRegistrationPlace> places,
    bool wateringCycleSupported = false,
  }) : this(
         wateringCycleSupported: wateringCycleSupported,
         plantId: null,
         placeId: null,
         mode: PlantFormMode.create,
         initialName: plantName,
         currentName: plantName,
         initialLastWateredDate: null,
         currentLastWateredDate: null,
         places: List.unmodifiable(places),
         selectedPlaceId: places.isEmpty ? null : places.first.id,
         loadStatus: places.isEmpty
             ? PlantFormLoadStatus.empty
             : PlantFormLoadStatus.ready,
         submitState: const FormSubmitState.idle(),
       );

  const PlantFormState.loadingEdit({
    required String plantId,
    required String? placeId,
  }) : this(
         plantId: plantId,
         placeId: placeId,
         mode: PlantFormMode.edit,
         initialName: '',
         currentName: '',
         initialLastWateredDate: null,
         currentLastWateredDate: null,
         places: const [],
         selectedPlaceId: null,
         loadStatus: PlantFormLoadStatus.loading,
         submitState: const FormSubmitState.idle(),
       );

  const PlantFormState.edit({
    required String plantId,
    required String? placeId,
    required String name,
    required String? lastWateredDate,
    String? imageKey,
    String? imageUrl,
    int? wateringCycleDays,
    bool wateringCycleSupported = false,
  }) : this(
         plantId: plantId,
         placeId: placeId,
         mode: PlantFormMode.edit,
         initialWateringCycleDays: wateringCycleDays,
         wateringCycleSupported: wateringCycleSupported,
         initialName: name,
         currentName: name,
         initialLastWateredDate: lastWateredDate,
         currentLastWateredDate: lastWateredDate,
         initialImageKey: imageKey,
         initialImageUrl: imageUrl,
         places: const [],
         selectedPlaceId: null,
         loadStatus: PlantFormLoadStatus.ready,
         submitState: const FormSubmitState.idle(),
       );

  const PlantFormState.notFound({
    required String plantId,
    required String? placeId,
  }) : this(
         plantId: plantId,
         placeId: placeId,
         mode: PlantFormMode.edit,
         initialName: '',
         currentName: '',
         initialLastWateredDate: null,
         currentLastWateredDate: null,
         places: const [],
         selectedPlaceId: null,
         loadStatus: PlantFormLoadStatus.notFound,
         submitState: const FormSubmitState.idle(),
       );

  const PlantFormState.failure({
    required String plantId,
    required String? placeId,
    required String message,
  }) : this(
         plantId: plantId,
         placeId: placeId,
         mode: PlantFormMode.edit,
         initialName: '',
         currentName: '',
         initialLastWateredDate: null,
         currentLastWateredDate: null,
         places: const [],
         selectedPlaceId: null,
         loadStatus: PlantFormLoadStatus.failure,
         submitState: const FormSubmitState.idle(),
         loadErrorMessage: message,
       );

  const PlantFormState.missingPlace({required String plantId})
    : this(
        plantId: plantId,
        placeId: null,
        mode: PlantFormMode.edit,
        initialName: '',
        currentName: '',
        initialLastWateredDate: null,
        currentLastWateredDate: null,
        places: const [],
        selectedPlaceId: null,
        loadStatus: PlantFormLoadStatus.missingPlace,
        submitState: const FormSubmitState.idle(),
      );

  final int? initialWateringCycleDays;
  final String? editedWateringCycleInput;
  String get wateringCycleInput =>
      editedWateringCycleInput ?? initialWateringCycleDays?.toString() ?? '';

  final bool wateringCycleSupported;

  int? get wateringCycleDays => int.tryParse(wateringCycleInput.trim());

  String? get wateringCycleErrorText {
    if (!wateringCycleSupported || wateringCycleInput.trim().isEmpty) {
      return null;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(wateringCycleInput.trim()) ||
        wateringCycleDays == null ||
        wateringCycleDays! < 1) {
      return '1 이상의 정수로 입력해 주세요';
    }
    return null;
  }

  final SelectedImage? selectedImage;
  final bool isPickingImage;

  final String? plantId;
  final String? placeId;
  final PlantFormMode mode;
  final String initialName;
  final String currentName;
  final String? initialLastWateredDate;
  final String? currentLastWateredDate;
  final String? initialImageKey;
  final String? initialImageUrl;
  final List<PlantRegistrationPlace> places;
  final String? selectedPlaceId;
  final PlantFormLoadStatus loadStatus;
  final FormSubmitState submitState;
  final String? loadErrorMessage;

  bool get isEdit => mode == PlantFormMode.edit;

  bool get isSubmitting => submitState.isSubmitting;

  String? get nameErrorMessage => submitState.fieldError('nickname');

  String? get lastWateredDateErrorMessage =>
      submitState.fieldError('lastWateredDate');

  bool get hasUnresolvedImage =>
      (initialImageUrl?.trim().isNotEmpty ?? false) &&
      (initialImageKey?.trim().isEmpty ?? true);

  bool get hasChanges =>
      (wateringCycleSupported &&
          wateringCycleDays != initialWateringCycleDays) ||
      selectedImage != null ||
      currentName.trim() != initialName ||
      currentLastWateredDate != initialLastWateredDate;

  PlantRegistrationPlace? get selectedPlace {
    final selectedPlaceId = this.selectedPlaceId;

    if (selectedPlaceId == null) {
      return null;
    }

    for (final place in places) {
      if (place.id == selectedPlaceId) {
        return place;
      }
    }

    return null;
  }

  bool get canSubmit {
    if (loadStatus != PlantFormLoadStatus.ready ||
        isSubmitting ||
        isPickingImage) {
      return false;
    }

    if (wateringCycleSupported &&
        (wateringCycleDays == null || wateringCycleErrorText != null)) {
      return false;
    }

    if (currentName.trim().isEmpty) {
      return false;
    }

    return isEdit ? hasChanges : selectedPlace != null;
  }

  PlantFormState copyWith({
    String? wateringCycleInput,
    SelectedImage? selectedImage,
    bool clearSelectedImage = false,
    bool? isPickingImage,
    String? currentName,
    Object? currentLastWateredDate = _unset,
    List<PlantRegistrationPlace>? places,
    Object? selectedPlaceId = _unset,
    PlantFormLoadStatus? loadStatus,
    Object? loadErrorMessage = _unset,
    FormSubmitState? submitState,
  }) {
    return PlantFormState(
      initialWateringCycleDays: initialWateringCycleDays,
      editedWateringCycleInput: wateringCycleInput ?? editedWateringCycleInput,
      wateringCycleSupported: wateringCycleSupported,
      selectedImage: clearSelectedImage
          ? null
          : selectedImage ?? this.selectedImage,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      plantId: plantId,
      placeId: placeId,
      mode: mode,
      initialName: initialName,
      currentName: currentName ?? this.currentName,
      initialLastWateredDate: initialLastWateredDate,
      currentLastWateredDate: identical(currentLastWateredDate, _unset)
          ? this.currentLastWateredDate
          : currentLastWateredDate as String?,
      initialImageKey: initialImageKey,
      initialImageUrl: initialImageUrl,
      places: places == null ? this.places : List.unmodifiable(places),
      selectedPlaceId: identical(selectedPlaceId, _unset)
          ? this.selectedPlaceId
          : selectedPlaceId as String?,
      loadStatus: loadStatus ?? this.loadStatus,
      submitState: submitState ?? this.submitState,
      loadErrorMessage: identical(loadErrorMessage, _unset)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
    );
  }
}

const Object _unset = Object();
