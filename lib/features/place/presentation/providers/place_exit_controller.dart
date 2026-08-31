import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
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
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
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

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (!session.isActive) return null;
    state = const FormSubmitState.submitting();

    try {
      await ref.read(placeRepositoryProvider).deletePlace(placeId);
      if (!isCurrentUserDataSession(requestRef, session)) return null;
      ref.invalidate(placeDetailProvider(placeId));
      ref.invalidate(placeSummaryProvider(placeId));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(userPlaceSummariesProvider);
      state = const FormSubmitState.idle();

      return const PlaceExitResult.home();
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return null;
      state = FormSubmitState.failureFrom(
        error,
        fallbackMessage: '장소 삭제에 실패했어요',
      );

      return null;
    }
  }
}
