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

class PlaceExitController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return const FormSubmitState.idle();
  }

  Future<bool> exit(String placeId) async {
    if (state.isSubmitting) {
      return false;
    }

    if (!ref.read(useRemoteApiProvider)) {
      state = const FormSubmitState.idle();
      return false;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (!session.isActive) return false;
    state = const FormSubmitState.submitting();

    try {
      await ref.read(placeRepositoryProvider).deletePlace(placeId);
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      ref.invalidate(placeDetailProvider(placeId));
      ref.invalidate(placeSummaryProvider(placeId));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(userPlaceSummariesProvider);
      state = const FormSubmitState.idle();

      return true;
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = FormSubmitState.failureFrom(
        error,
        fallbackMessage: '장소 삭제에 실패했어요',
      );

      return false;
    }
  }
}
