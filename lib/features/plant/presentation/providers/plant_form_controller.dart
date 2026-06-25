import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/dtos/plant_requests.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantFormControllerProvider =
    NotifierProvider<PlantFormController, FormSubmitState>(
      PlantFormController.new,
    );

enum PlantFormSubmitDestination { home, plantDetail }

class PlantFormSubmitResult {
  const PlantFormSubmitResult._({
    required this.destination,
    this.plantId,
    this.placeId,
  });

  const PlantFormSubmitResult.home()
    : this._(destination: PlantFormSubmitDestination.home);

  const PlantFormSubmitResult.plantDetail({
    required String plantId,
    String? placeId,
  }) : this._(
         destination: PlantFormSubmitDestination.plantDetail,
         plantId: plantId,
         placeId: placeId,
       );

  final PlantFormSubmitDestination destination;
  final String? plantId;
  final String? placeId;
}

class PlantFormSubmitInput {
  const PlantFormSubmitInput.create({
    required this.plantName,
    required this.placeId,
    required this.placeName,
  }) : plantId = null;

  const PlantFormSubmitInput.update({
    required this.plantId,
    required this.plantName,
    this.placeId,
  }) : placeName = null;

  final String? plantId;
  final String plantName;
  final String? placeId;
  final String? placeName;

  bool get isEdit => plantId != null;
}

class PlantFormController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    return const FormSubmitState.idle();
  }

  Future<PlantFormSubmitResult?> submit(PlantFormSubmitInput input) async {
    if (state.isSubmitting) {
      return null;
    }

    state = const FormSubmitState.submitting();

    try {
      final result = input.isEdit ? await _update(input) : await _create(input);
      state = const FormSubmitState.idle();

      return result;
    } catch (_) {
      state = FormSubmitState.failure(
        input.isEdit ? '식물 수정에 실패했어요' : '식물 등록에 실패했어요',
      );

      return null;
    }
  }

  Future<PlantFormSubmitResult> _create(PlantFormSubmitInput input) async {
    final plantName = input.plantName.trim();
    final placeId = input.placeId!;
    final placeName = input.placeName!;

    if (ref.read(useRemoteApiProvider)) {
      await ref
          .read(plantRepositoryProvider)
          .createPlant(
            CreatePlantRequest(
              placeCode: placeId,
              nickname: plantName,
              scientificNameKo: plantName,
            ),
          );
      ref.invalidate(remotePlantListProvider);
    }

    ref
        .read(plantListProvider.notifier)
        .addPlant(name: plantName, placeId: placeId, placeName: placeName);

    return const PlantFormSubmitResult.home();
  }

  Future<PlantFormSubmitResult> _update(PlantFormSubmitInput input) async {
    final plantId = input.plantId!;
    final plantName = input.plantName.trim();
    final placeId = input.placeId;

    if (ref.read(useRemoteApiProvider) && placeId != null) {
      await ref
          .read(plantRepositoryProvider)
          .updatePlant(
            plantId: plantId,
            placeCode: placeId,
            request: UpdatePlantRequest(nickname: plantName),
          );
      ref.invalidate(remotePlantListProvider);
    }

    ref
        .read(plantListProvider.notifier)
        .updatePlant(id: plantId, name: plantName);

    return PlantFormSubmitResult.plantDetail(
      plantId: plantId,
      placeId: placeId,
    );
  }
}
