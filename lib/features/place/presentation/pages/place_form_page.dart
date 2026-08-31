import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_state.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_form_scaffold.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_form_status_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlaceFormPage extends ConsumerWidget {
  const PlaceFormPage({super.key, this.placeId});

  final String? placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(placeFormControllerProvider(placeId));

    return switch (formState.loadStatus) {
      PlaceFormLoadStatus.loading => const PlaceFormStatusScaffold(
        title: '장소 정보를 불러오고 있어요',
        message: '장소 수정 정보를 준비하고 있어요',
        isLoading: true,
      ),
      PlaceFormLoadStatus.failure => PlaceFormStatusScaffold(
        title: '장소 정보를 불러오지 못했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () =>
            ref.read(placeFormControllerProvider(placeId).notifier).retryLoad(),
      ),
      PlaceFormLoadStatus.notFound => const PlaceFormStatusScaffold(
        title: '장소 정보를 찾을 수 없어요',
        message: '다시 장소 목록에서 선택해 주세요',
      ),
      PlaceFormLoadStatus.ready => _buildForm(context, ref, formState),
    };
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    PlaceFormState formState,
  ) {
    final controller = ref.read(placeFormControllerProvider(placeId).notifier);

    if (!formState.isEdit) {
      return PlaceCreateScaffold(
        name: formState.currentName,
        address: formState.currentAddress,
        nameErrorMessage: formState.nameErrorMessage,
        addressErrorMessage: formState.addressErrorMessage,
        canSubmit: formState.canSubmit,
        isSubmitting: formState.isSubmitting,
        onNameChanged: controller.updateName,
        onImageTap: () {},
        onAddressTap: () =>
            controller.applyAddressSelection(_searchAddress(context)),
        onAddressClear: controller.clearAddress,
        onNext: () => _submit(context, ref),
      );
    }

    return PlaceEditScaffold(
      name: formState.currentName,
      address: formState.currentAddress,
      nameErrorMessage: formState.nameErrorMessage,
      addressErrorMessage: formState.addressErrorMessage,
      canSubmit: formState.canSubmit,
      isSubmitting: formState.isSubmitting,
      onNameChanged: controller.updateName,
      onImageTap: () {},
      onAddressTap: () =>
          controller.applyAddressSelection(_searchAddress(context)),
      onAddressClear: controller.clearAddress,
      onComplete: () => _submit(context, ref),
    );
  }

  Future<AddressSearchResult?> _searchAddress(BuildContext context) async {
    final result = await context.push<AddressSearchResult>(
      AppRoutePaths.addressSearch,
    );
    return context.mounted ? result : null;
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final provider = placeFormControllerProvider(placeId);
    final result = await ref.read(provider.notifier).submit();

    if (!context.mounted) {
      return;
    }

    switch (result?.destination) {
      case PlaceFormSubmitDestination.home:
        context.go(AppRoutePaths.home);
      case PlaceFormSubmitDestination.friendAdd:
        context.push(AppRoutePaths.placeFriendAddLocation(result!.placeCode));
      case null:
        final errorMessage = ref.read(provider).submitState.errorMessage;

        if (errorMessage != null) {
          showCommonSnackBar(context, errorMessage);
        }
    }
  }
}
