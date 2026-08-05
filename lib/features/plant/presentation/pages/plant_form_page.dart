import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_form_scaffold.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlantFormPage extends ConsumerWidget {
  const PlantFormPage({
    super.key,
    this.plantId,
    this.placeId,
    this.initialPlantName,
  });

  final String? plantId;
  final String? placeId;
  final String? initialPlantName;

  PlantFormArgs get _args => PlantFormArgs(
    plantId: plantId,
    placeId: placeId,
    initialPlantName: initialPlantName,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(plantFormControllerProvider(_args));

    return switch (formState.loadStatus) {
      PlantFormLoadStatus.loading => const PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '식물 수정 정보를 불러오고 있어요',
        message: '식물 이름과 사진 정보를 준비하고 있어요',
        isLoading: true,
      ),
      PlantFormLoadStatus.failure => PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '식물 수정 정보를 불러오지 못했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () =>
            ref.read(plantFormControllerProvider(_args).notifier).retryLoad(),
      ),
      PlantFormLoadStatus.notFound => const PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '식물 수정 정보를 찾을 수 없어요',
        message: '다시 식물 상세에서 수정해 주세요',
      ),
      PlantFormLoadStatus.ready => _buildForm(context, ref, formState),
    };
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    PlantFormState formState,
  ) {
    final controller = ref.read(plantFormControllerProvider(_args).notifier);

    if (!formState.isEdit) {
      return PlantCreateScaffold(
        places: formState.places,
        selectedPlaceId: formState.selectedPlaceId,
        wateringDate: '2023. 01. 30',
        isSubmitting: formState.isSubmitting,
        onPlaceSelected: controller.selectPlace,
        onCancel: () => _cancelCreate(context),
        onSubmit: () => _submit(context, ref),
      );
    }

    return PlantEditScaffold(
      name: formState.currentName,
      canSubmit: formState.canSubmit,
      isSubmitting: formState.isSubmitting,
      onChanged: controller.updateName,
      onSubmit: () => _submit(context, ref),
    );
  }

  void _cancelCreate(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutePaths.home);
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final provider = plantFormControllerProvider(_args);
    final result = await ref.read(provider.notifier).submit();

    if (!context.mounted) {
      return;
    }

    switch (result?.destination) {
      case PlantFormSubmitDestination.home:
        context.go(AppRoutePaths.home);
      case PlantFormSubmitDestination.plantDetail:
        final plantId = result?.plantId;

        if (plantId != null) {
          context.go(
            AppRoutePaths.plantDetailLocation(
              plantId,
              placeId: result?.placeId,
            ),
          );
        }
      case null:
        final errorMessage = ref.read(provider).submitErrorMessage;

        if (errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
    }
  }
}
