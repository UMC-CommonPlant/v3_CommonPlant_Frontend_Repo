import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_state.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String placeFormAddressRequiredMessage = '장소 주소를 입력해 주세요.';

final placeFormControllerProvider = NotifierProvider.autoDispose
    .family<PlaceFormController, PlaceFormState, String?>(
      PlaceFormController.new,
    );

enum PlaceFormSubmitDestination { home, friendAdd }

class PlaceFormSubmitResult {
  const PlaceFormSubmitResult._(this.destination);

  const PlaceFormSubmitResult.home() : this._(PlaceFormSubmitDestination.home);

  const PlaceFormSubmitResult.friendAdd()
    : this._(PlaceFormSubmitDestination.friendAdd);

  final PlaceFormSubmitDestination destination;
}

class PlaceFormController extends Notifier<PlaceFormState> {
  PlaceFormController(this.placeId);

  final String? placeId;

  @override
  PlaceFormState build() {
    final placeId = this.placeId;

    if (placeId == null) {
      return const PlaceFormState.create();
    }

    return ref
        .watch(placeFormEditInfoProvider(placeId))
        .when(
          data: (info) {
            if (info == null) {
              return PlaceFormState.notFound(placeId);
            }

            return PlaceFormState.edit(
              placeId: placeId,
              name: info.name,
              address: info.address,
            );
          },
          error: (error, stackTrace) =>
              PlaceFormState.failure(placeId, '장소 정보를 불러오지 못했어요'),
          loading: () => PlaceFormState.loading(placeId),
        );
  }

  void updateName(String name) {
    if (state.loadStatus != PlaceFormLoadStatus.ready) {
      return;
    }

    state = state.copyWith(
      currentName: name,
      submitState: const FormSubmitState.idle(),
    );
  }

  void updateAddress(String? address) {
    if (state.loadStatus != PlaceFormLoadStatus.ready) {
      return;
    }

    state = state.copyWith(
      currentAddress: address,
      submitState: const FormSubmitState.idle(),
    );
  }

  void clearAddress() => updateAddress(null);

  void retryLoad() {
    final placeId = this.placeId;

    if (placeId == null) {
      return;
    }

    ref.invalidate(placeDetailProvider(placeId));
    ref.invalidate(remotePlaceFormEditInfoProvider(placeId));
  }

  Future<PlaceFormSubmitResult?> submit() async {
    if (!state.canSubmit) {
      return null;
    }

    final isEdit = state.isEdit;
    state = state.copyWith(submitState: const FormSubmitState.submitting());

    try {
      final result = isEdit ? await _update() : await _create();
      state = state.copyWith(submitState: const FormSubmitState.idle());

      return result;
    } on _PlaceFormValidationException catch (error) {
      state = state.copyWith(
        submitState: FormSubmitState.failure(error.message),
      );

      return null;
    } catch (_) {
      state = state.copyWith(
        submitState: FormSubmitState.failure(
          isEdit ? '장소 수정에 실패했어요' : '장소 생성에 실패했어요',
        ),
      );

      return null;
    }
  }

  Future<PlaceFormSubmitResult> _create() async {
    final name = state.currentName.trim();
    final address = _normalizeAddress(state.currentAddress);

    if (ref.read(useRemoteApiProvider)) {
      final requiredAddress = _requiredAddress(address);

      await ref
          .read(placeRepositoryProvider)
          .createPlace(
            CreatePlaceRequest(name: name, address: requiredAddress),
          );
      ref.invalidate(remotePlaceListProvider);
    } else {
      ref
          .read(placeListProvider.notifier)
          .addPlace(name: name, address: address);
    }

    return const PlaceFormSubmitResult.friendAdd();
  }

  Future<PlaceFormSubmitResult> _update() async {
    final placeId = state.placeId!;
    final name = state.currentName.trim();
    final address = _normalizeAddress(state.currentAddress);

    if (ref.read(useRemoteApiProvider)) {
      final requiredAddress = _requiredAddress(address);

      await ref
          .read(placeRepositoryProvider)
          .updatePlace(
            code: placeId,
            request: UpdatePlaceRequest(name: name, address: requiredAddress),
          );
      ref.invalidate(placeDetailProvider(placeId));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(userPlaceSummariesProvider);
    } else {
      ref
          .read(placeListProvider.notifier)
          .updatePlace(id: placeId, name: name, address: address);
    }

    return const PlaceFormSubmitResult.home();
  }
}

String? _normalizeAddress(String? address) {
  final trimmed = address?.trim();

  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

String _requiredAddress(String? address) {
  if (address == null || address.isEmpty) {
    throw const _PlaceFormValidationException(placeFormAddressRequiredMessage);
  }

  return address;
}

class _PlaceFormValidationException implements Exception {
  const _PlaceFormValidationException(this.message);

  final String message;
}
