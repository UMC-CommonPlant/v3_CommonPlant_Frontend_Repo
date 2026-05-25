import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
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
  late final String _initialName;
  late final String? _initialAddress;
  String? _address;
  bool _isSubmitting = false;

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
    final currentName = _nameController.text.trim();
    final hasChanges =
        !widget.isEdit ||
        currentName != _initialName ||
        _address != _initialAddress;
    final canSubmit = currentName.isNotEmpty && hasChanges && !_isSubmitting;

    if (!widget.isEdit) {
      return _PlaceCreateScaffold(
        nameController: _nameController,
        address: _address,
        canSubmit: canSubmit,
        isSubmitting: _isSubmitting,
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
      isSubmitting: _isSubmitting,
      onNameChanged: (_) => setState(() {}),
      onImageTap: () {},
      onAddressTap: () => context.push(AppRoutePaths.addressSearch),
      onAddressClear: () => setState(() => _address = null),
      onComplete: () => _submit(),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final name = _nameController.text.trim();
    final notifier = ref.read(placeListProvider.notifier);
    final address = _address?.trim();

    if (!widget.isEdit &&
        ref.read(useRemoteApiProvider) &&
        (address == null || address.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('장소 주소를 입력해 주세요.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.placeId case final placeId?) {
        notifier.updatePlace(id: placeId, name: name, address: _address);
        if (mounted) {
          context.go(AppRoutePaths.home);
        }
      } else {
        if (ref.read(useRemoteApiProvider)) {
          try {
            await ref
                .read(placeRepositoryProvider)
                .createPlace(CreatePlaceRequest(name: name, address: address!));
            ref.invalidate(remotePlaceListProvider);
          } catch (error) {
            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('장소 생성에 실패했어요: $error')));
            return;
          }
        }

        if (!mounted) {
          return;
        }

        notifier.addPlace(name: name, address: _address);
        context.push(AppRoutePaths.placeFriendAdd);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
