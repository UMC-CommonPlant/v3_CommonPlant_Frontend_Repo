import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantDeleteControllerProvider =
    NotifierProvider<PlantDeleteController, FormSubmitState>(
      PlantDeleteController.new,
    );

enum PlantDeleteDestination { home }

class PlantDeleteResult {
  const PlantDeleteResult._(this.destination);

  const PlantDeleteResult.home() : this._(PlantDeleteDestination.home);

  final PlantDeleteDestination destination;
}

class PlantDeleteController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    return const FormSubmitState.idle();
  }

  Future<PlantDeleteResult?> delete({
    required String plantId,
    required String? placeCode,
  }) async {
    if (state.isSubmitting) {
      return null;
    }

    if (!ref.read(useRemoteApiProvider)) {
      state = const FormSubmitState.idle();
      return null;
    }

    final effectivePlaceCode = placeCode?.trim();

    if (effectivePlaceCode == null || effectivePlaceCode.isEmpty) {
      state = const FormSubmitState.failure('장소 정보를 확인할 수 없어요.');
      return null;
    }

    state = const FormSubmitState.submitting();

    try {
      await ref
          .read(plantRepositoryProvider)
          .deletePlant(plantId: plantId, placeCode: effectivePlaceCode);
      ref.invalidate(remotePlantListProvider);
      ref.invalidate(remotePlantDetailProvider(plantId));
      ref.invalidate(remotePlantEditInfoProvider(plantId));
      state = const FormSubmitState.idle();

      return const PlantDeleteResult.home();
    } catch (_) {
      state = const FormSubmitState.failure('식물 삭제에 실패했어요');

      return null;
    }
  }
}
