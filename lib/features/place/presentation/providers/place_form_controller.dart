import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String placeFormAddressRequiredMessage = '장소 주소를 입력해 주세요.';

final placeFormControllerProvider =
    NotifierProvider<PlaceFormController, FormSubmitState>(
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

class PlaceFormSubmitInput {
  const PlaceFormSubmitInput.create({required this.name, this.address})
    : placeId = null;

  const PlaceFormSubmitInput.update({
    required this.placeId,
    required this.name,
    this.address,
  });

  final String? placeId;
  final String name;
  final String? address;

  bool get isEdit => placeId != null;
}

class PlaceFormController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    return const FormSubmitState.idle();
  }

  Future<PlaceFormSubmitResult?> submit(PlaceFormSubmitInput input) async {
    if (state.isSubmitting) {
      return null;
    }

    state = const FormSubmitState.submitting();

    try {
      final result = input.isEdit ? await _update(input) : await _create(input);
      state = const FormSubmitState.idle();

      return result;
    } on _PlaceFormValidationException catch (error) {
      state = FormSubmitState.failure(error.message);

      return null;
    } catch (_) {
      state = FormSubmitState.failure(
        input.isEdit ? '장소 수정에 실패했어요' : '장소 생성에 실패했어요',
      );

      return null;
    }
  }

  Future<PlaceFormSubmitResult> _create(PlaceFormSubmitInput input) async {
    final name = input.name.trim();
    final address = _normalizeAddress(input.address);

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

  Future<PlaceFormSubmitResult> _update(PlaceFormSubmitInput input) async {
    final placeId = input.placeId!;
    final name = input.name.trim();
    final address = _normalizeAddress(input.address);

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
      ref.invalidate(plantRegistrationPlaceProvider);
    } else {
      ref
          .read(placeListProvider.notifier)
          .updatePlace(id: placeId, name: name, address: address);
    }

    return const PlaceFormSubmitResult.home();
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
      throw const _PlaceFormValidationException(
        placeFormAddressRequiredMessage,
      );
    }

    return address;
  }
}

class _PlaceFormValidationException implements Exception {
  const _PlaceFormValidationException(this.message);

  final String message;
}
