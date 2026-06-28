import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/plant_registration_place_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeExitControllerProvider =
    NotifierProvider<PlaceExitController, FormSubmitState>(
      PlaceExitController.new,
    );

enum PlaceExitDestination { home }

class PlaceExitResult {
  const PlaceExitResult._(this.destination);

  const PlaceExitResult.home() : this._(PlaceExitDestination.home);

  final PlaceExitDestination destination;
}

class PlaceExitController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    return const FormSubmitState.idle();
  }

  Future<PlaceExitResult?> exit(String placeId) async {
    if (state.isSubmitting) {
      return null;
    }

    if (!ref.read(useRemoteApiProvider)) {
      state = const FormSubmitState.idle();
      return null;
    }

    state = const FormSubmitState.submitting();

    try {
      await ref.read(placeRepositoryProvider).deletePlace(placeId);
      ref.invalidate(placeDetailProvider(placeId));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(plantRegistrationPlaceProvider);
      state = const FormSubmitState.idle();

      return const PlaceExitResult.home();
    } catch (_) {
      state = const FormSubmitState.failure('장소 나가기에 실패했어요');

      return null;
    }
  }
}
