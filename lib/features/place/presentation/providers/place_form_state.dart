import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';

enum PlaceFormMode { create, edit }

enum PlaceFormLoadStatus { loading, ready, notFound, failure }

class PlaceFormState {
  const PlaceFormState({
    required this.placeId,
    required this.mode,
    required this.initialName,
    required this.currentName,
    required this.initialAddress,
    required this.currentAddress,
    required this.loadStatus,
    required this.submitState,
    this.loadErrorMessage,
  });

  const PlaceFormState.create()
    : this(
        placeId: null,
        mode: PlaceFormMode.create,
        initialName: '',
        currentName: '',
        initialAddress: null,
        currentAddress: null,
        loadStatus: PlaceFormLoadStatus.ready,
        submitState: const FormSubmitState.idle(),
      );

  const PlaceFormState.loading(String placeId)
    : this(
        placeId: placeId,
        mode: PlaceFormMode.edit,
        initialName: '',
        currentName: '',
        initialAddress: null,
        currentAddress: null,
        loadStatus: PlaceFormLoadStatus.loading,
        submitState: const FormSubmitState.idle(),
      );

  const PlaceFormState.edit({
    required String placeId,
    required String name,
    required String? address,
  }) : this(
         placeId: placeId,
         mode: PlaceFormMode.edit,
         initialName: name,
         currentName: name,
         initialAddress: address,
         currentAddress: address,
         loadStatus: PlaceFormLoadStatus.ready,
         submitState: const FormSubmitState.idle(),
       );

  const PlaceFormState.notFound(String placeId)
    : this(
        placeId: placeId,
        mode: PlaceFormMode.edit,
        initialName: '',
        currentName: '',
        initialAddress: null,
        currentAddress: null,
        loadStatus: PlaceFormLoadStatus.notFound,
        submitState: const FormSubmitState.idle(),
      );

  const PlaceFormState.failure(String placeId, String message)
    : this(
        placeId: placeId,
        mode: PlaceFormMode.edit,
        initialName: '',
        currentName: '',
        initialAddress: null,
        currentAddress: null,
        loadStatus: PlaceFormLoadStatus.failure,
        submitState: const FormSubmitState.idle(),
        loadErrorMessage: message,
      );

  final String? placeId;
  final PlaceFormMode mode;
  final String initialName;
  final String currentName;
  final String? initialAddress;
  final String? currentAddress;
  final PlaceFormLoadStatus loadStatus;
  final FormSubmitState submitState;
  final String? loadErrorMessage;

  bool get isEdit => mode == PlaceFormMode.edit;

  bool get isSubmitting => submitState.isSubmitting;

  String? get submitErrorMessage => submitState.errorMessage;

  bool get hasChanges =>
      currentName.trim() != initialName || currentAddress != initialAddress;

  bool get canSubmit {
    if (loadStatus != PlaceFormLoadStatus.ready || isSubmitting) {
      return false;
    }

    return currentName.trim().isNotEmpty && (!isEdit || hasChanges);
  }

  PlaceFormState copyWith({
    String? currentName,
    Object? currentAddress = _unset,
    FormSubmitState? submitState,
  }) {
    return PlaceFormState(
      placeId: placeId,
      mode: mode,
      initialName: initialName,
      currentName: currentName ?? this.currentName,
      initialAddress: initialAddress,
      currentAddress: identical(currentAddress, _unset)
          ? this.currentAddress
          : currentAddress as String?,
      loadStatus: loadStatus,
      submitState: submitState ?? this.submitState,
      loadErrorMessage: loadErrorMessage,
    );
  }
}

const Object _unset = Object();
