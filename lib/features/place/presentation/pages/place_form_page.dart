import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_edit_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_form_scaffold.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_form_status_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlaceFormPage extends ConsumerStatefulWidget {
  const PlaceFormPage({super.key, this.placeId});

  final String? placeId;

  bool get isEdit => placeId != null;

  @override
  ConsumerState<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends ConsumerState<PlaceFormPage> {
  late final TextEditingController _nameController;
  late String _initialName;
  String? _initialAddress;
  String? _address;
  String? _appliedEditPlaceId;

  @override
  void initState() {
    super.initState();
    _initialName = widget.isEdit ? placeFormDefaultEditName : '';
    _initialAddress = null;
    _nameController = TextEditingController(text: _initialName);
    _address = _initialAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEdit) {
      final placeId = widget.placeId!;
      final editInfo = ref.watch(placeFormEditInfoProvider(placeId));

      return editInfo.when(
        loading: () {
          return const PlaceFormStatusScaffold(
            title: '장소 정보를 불러오고 있어요',
            message: '장소 수정 정보를 준비하고 있어요',
            isLoading: true,
          );
        },
        error: (error, stackTrace) {
          return PlaceFormStatusScaffold(
            title: '장소 정보를 불러오지 못했어요',
            message: '잠시 후 다시 시도해 주세요',
            actionLabel: '다시 시도',
            onAction: () => invalidatePlaceFormEditInfo(ref, placeId),
          );
        },
        data: (info) {
          if (info == null) {
            return const PlaceFormStatusScaffold(
              title: '장소 정보를 찾을 수 없어요',
              message: '다시 장소 목록에서 선택해 주세요',
            );
          }

          _applyEditInfo(info);

          return _buildForm(context);
        },
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final submitState = ref.watch(placeFormControllerProvider);
    final isSubmitting = submitState.isSubmitting;
    final currentName = _nameController.text.trim();
    final hasChanges =
        !widget.isEdit ||
        currentName != _initialName ||
        _address != _initialAddress;
    final canSubmit = currentName.isNotEmpty && hasChanges && !isSubmitting;

    if (!widget.isEdit) {
      return PlaceCreateScaffold(
        nameController: _nameController,
        address: _address,
        canSubmit: canSubmit,
        isSubmitting: isSubmitting,
        onNameChanged: (_) => setState(() {}),
        onImageTap: () {},
        onAddressTap: () => context.push(AppRoutePaths.addressSearch),
        onAddressClear: () => setState(() => _address = null),
        onNext: () => _submit(),
      );
    }

    return PlaceEditScaffold(
      nameController: _nameController,
      address: _address,
      canSubmit: canSubmit,
      isSubmitting: isSubmitting,
      onNameChanged: (_) => setState(() {}),
      onImageTap: () {},
      onAddressTap: () => context.push(AppRoutePaths.addressSearch),
      onAddressClear: () => setState(() => _address = null),
      onComplete: () => _submit(),
    );
  }

  void _applyEditInfo(PlaceFormEditInfo info) {
    final placeId = widget.placeId;

    if (placeId == null || _appliedEditPlaceId == placeId) {
      return;
    }

    _appliedEditPlaceId = placeId;
    _initialName = info.name;
    _initialAddress = info.address;
    _address = info.address;
    _nameController.text = info.name;
  }

  Future<void> _submit() async {
    if (ref.read(placeFormControllerProvider).isSubmitting) {
      return;
    }

    final name = _nameController.text.trim();
    final address = _address?.trim();
    final input = switch (widget.placeId) {
      final placeId? => PlaceFormSubmitInput.update(
        placeId: placeId,
        name: name,
        address: address,
      ),
      null => PlaceFormSubmitInput.create(name: name, address: address),
    };
    final result = await ref
        .read(placeFormControllerProvider.notifier)
        .submit(input);

    if (!mounted) {
      return;
    }

    switch (result?.destination) {
      case PlaceFormSubmitDestination.home:
        context.go(AppRoutePaths.home);
      case PlaceFormSubmitDestination.friendAdd:
        context.push(AppRoutePaths.placeFriendAdd);
      case null:
        _showSubmitErrorIfNeeded();
    }
  }

  void _showSubmitErrorIfNeeded() {
    final errorMessage = ref.read(placeFormControllerProvider).errorMessage;

    if (!mounted || errorMessage == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
