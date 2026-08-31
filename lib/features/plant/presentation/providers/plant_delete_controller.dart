import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantDeleteControllerProvider =
    NotifierProvider<PlantDeleteController, FormSubmitState>(
      PlantDeleteController.new,
    );

class PlantDeleteController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return const FormSubmitState.idle();
  }

  Future<bool> delete({
    required String plantId,
    required String? placeCode,
  }) async {
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
    final effectivePlaceCode = placeCode?.trim();

    if (effectivePlaceCode == null || effectivePlaceCode.isEmpty) {
      state = const FormSubmitState.failure('장소 정보를 확인할 수 없어요.');
      return false;
    }

    state = const FormSubmitState.submitting();

    try {
      await ref
          .read(plantRepositoryProvider)
          .deletePlant(plantId: plantId, placeCode: effectivePlaceCode);
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      ref.invalidate(remotePlantListProvider);
      ref.invalidate(remotePlantDetailProvider(plantId));
      ref.invalidate(remotePlantEditInfoProvider(plantId));
      state = const FormSubmitState.idle();

      return true;
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = FormSubmitState.failureFrom(
        error,
        fallbackMessage: '식물 삭제에 실패했어요',
      );

      return false;
    }
  }
}
