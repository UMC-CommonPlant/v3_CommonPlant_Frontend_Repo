import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_state.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String placeFormAddressRequiredMessage = '장소 주소를 입력해 주세요.';
const String placeFormImagePreservationMessage =
    '기존 사진을 유지할 수 없어 지금은 장소를 수정할 수 없어요.';

final placeFormControllerProvider = NotifierProvider.autoDispose
    .family<PlaceFormController, PlaceFormState, String?>(
      PlaceFormController.new,
    );

enum PlaceFormSubmitDestination { home, friendAdd }

class PlaceFormSubmitResult {
  const PlaceFormSubmitResult._(this.destination, this.placeCode);

  const PlaceFormSubmitResult.home(String placeCode)
    : this._(PlaceFormSubmitDestination.home, placeCode);

  const PlaceFormSubmitResult.friendAdd(String placeCode)
    : this._(PlaceFormSubmitDestination.friendAdd, placeCode);

  final PlaceFormSubmitDestination destination;
  final String placeCode;
}

class PlaceFormController extends Notifier<PlaceFormState> {
  PlaceFormController(this.placeId);

  final String? placeId;

  @override
  PlaceFormState build() {
    if (ref.watch(useRemoteApiProvider)) {
      ref.watch(userDataSessionProvider);
    }
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
              imageUrl: info.imageUrl,
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
      submitState: state.isSubmitting
          ? state.submitState
          : const FormSubmitState.idle(),
    );
  }

  void updateAddress(String? address) {
    if (state.loadStatus != PlaceFormLoadStatus.ready) {
      return;
    }

    state = state.copyWith(
      currentAddress: address,
      submitState: state.isSubmitting
          ? state.submitState
          : const FormSubmitState.idle(),
    );
  }

  void clearAddress() => updateAddress(null);

  void retryLoad() {
    final placeId = this.placeId;

    if (placeId == null) {
      return;
    }

    ref.invalidate(placeSummaryProvider(placeId));
    ref.invalidate(remotePlaceFormEditInfoProvider(placeId));
  }

  Future<PlaceFormSubmitResult?> submit() async {
    if (!state.canSubmit) {
      return null;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    final isRemote = ref.read(useRemoteApiProvider);
    if (isRemote && !session.isActive) return null;
    final isEdit = state.isEdit;
    state = state.copyWith(submitState: const FormSubmitState.submitting());

    try {
      final result = isEdit ? await _update() : await _create();
      if (!isCurrentUserDataSession(requestRef, session)) return null;
      state = state.copyWith(submitState: const FormSubmitState.idle());
      if (isRemote) {
        ref.invalidate(remotePlaceListProvider);
        if (isEdit) {
          ref.invalidate(placeDetailProvider(placeId!));
          ref.invalidate(placeSummaryProvider(placeId!));
          ref.invalidate(userPlaceSummariesProvider);
        }
      }

      return result;
    } on _PlaceFormValidationException catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return null;
      state = state.copyWith(
        submitState: FormSubmitState.failure(error.message),
      );

      return null;
    } catch (_) {
      if (!isCurrentUserDataSession(requestRef, session)) return null;
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
    final String placeCode;

    if (ref.read(useRemoteApiProvider)) {
      final requiredAddress = _requiredAddress(address);

      placeCode = await ref
          .read(placeRepositoryProvider)
          .createPlace(name: name, address: requiredAddress);
    } else {
      placeCode = ref
          .read(placeListProvider.notifier)
          .addPlace(name: name, address: address)
          .id;
    }

    return PlaceFormSubmitResult.friendAdd(placeCode);
  }

  Future<PlaceFormSubmitResult> _update() async {
    final placeId = state.placeId!;
    final name = state.currentName.trim();
    final address = _normalizeAddress(state.currentAddress);
    var resultPlaceCode = placeId;

    if (ref.read(useRemoteApiProvider)) {
      // Place 조회는 URL만 제공하므로 유지에 필요한 key를 추측하지 않는다.
      if (state.hasExistingImage) {
        throw const _PlaceFormValidationException(
          placeFormImagePreservationMessage,
        );
      }

      final requiredAddress = _requiredAddress(address);

      final updatedPlace = await ref
          .read(placeRepositoryProvider)
          .updatePlace(code: placeId, name: name, address: requiredAddress);
      resultPlaceCode = updatedPlace.id;
    } else {
      ref
          .read(placeListProvider.notifier)
          .updatePlace(id: placeId, name: name, address: address);
    }

    return PlaceFormSubmitResult.home(resultPlaceCode);
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
