import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_state.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_form_scaffold.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_state_view.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
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
    final title = formState.isEdit ? '식물 수정' : '식물 등록 (2/2)';

    return switch (formState.loadStatus) {
      PlantFormLoadStatus.loading => PlantStateScaffold(
        title: title,
        statusTitle: formState.isEdit
            ? '식물 수정 정보를 불러오고 있어요'
            : '등록할 장소를 불러오고 있어요',
        message: formState.isEdit
            ? '식물 이름과 사진 정보를 준비하고 있어요'
            : '소속된 장소 목록을 확인하고 있어요',
        isLoading: true,
      ),
      PlantFormLoadStatus.failure => PlantStateScaffold(
        title: title,
        statusTitle: formState.loadErrorMessage!,
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () =>
            ref.read(plantFormControllerProvider(_args).notifier).retryLoad(),
      ),
      PlantFormLoadStatus.empty => PlantStateScaffold(
        title: title,
        statusTitle: '등록할 장소가 없어요',
        message: '홈에서 장소를 먼저 등록해 주세요',
        actionLabel: '홈으로',
        onAction: () => context.go(AppRoutePaths.home),
      ),
      PlantFormLoadStatus.notFound => const PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '식물 수정 정보를 찾을 수 없어요',
        message: '다시 식물 상세에서 수정해 주세요',
      ),
      PlantFormLoadStatus.missingPlace => PlantStateScaffold(
        title: '식물 수정',
        statusTitle: '장소 정보를 확인할 수 없어요',
        message: '장소에서 식물을 선택한 뒤 다시 수정해 주세요',
        actionLabel: '홈으로',
        onAction: () => context.go(AppRoutePaths.home),
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
        lastWateredDate: formState.currentLastWateredDate,
        lastWateredDateErrorMessage: formState.lastWateredDateErrorMessage,
        isSubmitting: formState.isSubmitting,
        onPlaceSelected: controller.selectPlace,
        onWateringDateTap: () => _selectLastWateredDate(
          context,
          ref,
          formState.currentLastWateredDate,
        ),
        onCancel: () => _cancelCreate(context),
        onSubmit: formState.canSubmit ? () => _submit(context, ref) : null,
      );
    }

    return PlantEditScaffold(
      name: formState.currentName,
      lastWateredDate: formState.currentLastWateredDate,
      nameErrorMessage: formState.nameErrorMessage,
      lastWateredDateErrorMessage: formState.lastWateredDateErrorMessage,
      canSubmit: formState.canSubmit,
      isSubmitting: formState.isSubmitting,
      onChanged: controller.updateName,
      onWateringDateTap: () => _selectLastWateredDate(
        context,
        ref,
        formState.currentLastWateredDate,
      ),
      onSubmit: () => _submit(context, ref),
    );
  }

  Future<void> _selectLastWateredDate(
    BuildContext context,
    WidgetRef ref,
    String? currentDate,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDate = DateTime(1900);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _clampWateringDatePickerInitialDate(
        currentDate: currentDate,
        firstDate: firstDate,
        lastDate: today,
      ),
      firstDate: firstDate,
      lastDate: today,
    );

    if (selectedDate == null || !context.mounted) {
      return;
    }

    ref
        .read(plantFormControllerProvider(_args).notifier)
        .updateLastWateredDate(selectedDate);
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
        final errorMessage = ref.read(provider).submitState.errorMessage;

        if (errorMessage != null) {
          showCommonSnackBar(context, errorMessage);
        }
    }
  }
}

DateTime _clampWateringDatePickerInitialDate({
  required String? currentDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final parsedDate = DateTime.tryParse(currentDate ?? '');

  if (parsedDate == null) {
    return lastDate;
  }

  final date = DateUtils.dateOnly(parsedDate);

  if (date.isBefore(firstDate)) {
    return firstDate;
  }

  if (date.isAfter(lastDate)) {
    return lastDate;
  }

  return date;
}
