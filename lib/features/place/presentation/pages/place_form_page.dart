import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_image_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const String _placeEditInitialName = '스윗 홈_ 거실';

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
  String? _remoteInitialPlaceId;

  @override
  void initState() {
    super.initState();
    _initialName = widget.isEdit ? _placeEditInitialName : '';
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
    if (widget.isEdit && ref.watch(useRemoteApiProvider)) {
      final placeId = widget.placeId!;
      final remoteDetail = ref.watch(placeDetailProvider(placeId));

      return remoteDetail.when(
        loading: () {
          return const _PlaceFormStatusScaffold(
            title: '장소 정보를 불러오고 있어요',
            message: '장소 수정 정보를 준비하고 있어요',
            isLoading: true,
          );
        },
        error: (error, stackTrace) {
          return _PlaceFormStatusScaffold(
            title: '장소 정보를 불러오지 못했어요',
            message: '잠시 후 다시 시도해 주세요',
            actionLabel: '다시 시도',
            onAction: () => ref.invalidate(placeDetailProvider(placeId)),
          );
        },
        data: (summary) {
          if (summary.name.trim().isEmpty) {
            return const _PlaceFormStatusScaffold(
              title: '장소 정보를 찾을 수 없어요',
              message: '다시 장소 목록에서 선택해 주세요',
            );
          }

          _applyRemoteSummary(summary);

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
      return _PlaceCreateScaffold(
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

    return _PlaceEditScaffold(
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

  void _applyRemoteSummary(PlaceSummary summary) {
    final placeId = widget.placeId;

    if (placeId == null || _remoteInitialPlaceId == placeId) {
      return;
    }

    _remoteInitialPlaceId = placeId;
    _initialName = summary.name;
    _initialAddress = summary.address;
    _address = summary.address;
    _nameController.text = summary.name;
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

class _PlaceFormStatusScaffold extends StatelessWidget {
  const _PlaceFormStatusScaffold({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonNavigationBar(
              title: '장소 수정',
              titleStyle: AppTextStyles.size18Medium.copyWith(
                color: AppColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        SizedBox.square(
                          dimension: AppSizes.iconLarge,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.brandStrong,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.x16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.size18Medium.copyWith(
                          color: AppColors.textStrong,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.size14Medium.copyWith(
                          color: AppColors.textBody,
                        ),
                      ),
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(height: AppSpacing.x24),
                        SizedBox(
                          width: AppSizes.smallButtonWidth,
                          child: CommonButton.secondary(
                            label: actionLabel!,
                            size: CommonButtonSize.medium,
                            onPressed: onAction,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceEditScaffold extends StatelessWidget {
  const _PlaceEditScaffold({
    required this.nameController,
    required this.address,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onNameChanged,
    required this.onImageTap,
    required this.onAddressTap,
    required this.onAddressClear,
    required this.onComplete,
  });

  final TextEditingController nameController;
  final String? address;
  final bool canSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onImageTap;
  final VoidCallback onAddressTap;
  final VoidCallback onAddressClear;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              CommonNavigationBar(
                title: '장소 수정',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x20,
                        AppSpacing.x24,
                        AppSpacing.x20,
                        AppSizes.buttonHeight + AppSpacing.x40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: CommonPlaceImageAddButton(
                              imageAsset: AppImageAssets.placeEditLivingRoom,
                              imageSemanticsLabel: '장소 대표 이미지',
                              onTap: onImageTap,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonTextField(
                            controller: nameController,
                            hintText: '장소 이름을 입력해 주세요',
                            maxLength: 10,
                            forceFocusedDecoration: true,
                            onChanged: onNameChanged,
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonAddressOrPlaceField(
                            label: '주소',
                            value: address,
                            onTap: onAddressTap,
                            onClear: onAddressClear,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.x20,
                      right: AppSpacing.x20,
                      bottom: AppSpacing.x16,
                      child: CommonButton(
                        label: '완료',
                        isLoading: isSubmitting,
                        onPressed: canSubmit ? onComplete : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceCreateScaffold extends StatelessWidget {
  const _PlaceCreateScaffold({
    required this.nameController,
    required this.address,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onNameChanged,
    required this.onImageTap,
    required this.onAddressTap,
    required this.onAddressClear,
    required this.onNext,
  });

  final TextEditingController nameController;
  final String? address;
  final bool canSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onImageTap;
  final VoidCallback onAddressTap;
  final VoidCallback onAddressClear;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              CommonNavigationBar(
                title: '장소 등록',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x20,
                        AppSpacing.x24,
                        AppSpacing.x20,
                        AppSizes.buttonHeight + AppSpacing.x40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: CommonPlaceImageAddButton(onTap: onImageTap),
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonTextField(
                            controller: nameController,
                            hintText: '장소의 이름을 입력해 주세요',
                            maxLength: 10,
                            onChanged: onNameChanged,
                          ),
                          const SizedBox(height: AppSpacing.x32),
                          CommonAddressOrPlaceField(
                            label: '주소',
                            value: address,
                            onTap: onAddressTap,
                            onClear: onAddressClear,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.x20,
                      right: AppSpacing.x20,
                      bottom: AppSpacing.x16,
                      child: CommonButton(
                        label: '다음',
                        isLoading: isSubmitting,
                        onPressed: canSubmit ? onNext : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
