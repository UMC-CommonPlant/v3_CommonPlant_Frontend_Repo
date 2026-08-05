import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_write_controller.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_write_state.dart';
import 'package:commonplant_frontend/features/memo/presentation/widgets/memo_content_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_photo_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MemoWritePage extends ConsumerWidget {
  const MemoWritePage({super.key, required this.plantId});

  final String plantId;

  void _submit(BuildContext context, WidgetRef ref) {
    final provider = memoWriteControllerProvider(plantId);
    final didSubmit = ref.read(provider.notifier).submit();

    if (didSubmit) {
      context.go(AppRoutePaths.memoListLocation(plantId));
      return;
    }

    final errorMessage = ref.read(provider).errorMessage;
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = memoWriteControllerProvider(plantId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              CommonNavigationBar(
                title: '메모 작성',
                titleStyle: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x20,
                    AppSpacing.x24,
                    AppSpacing.x20,
                    AppSpacing.x24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MemoPhotoSection(
                        hasPhoto: state.hasPhoto,
                        onAddPhoto: controller.selectPhoto,
                        onRemovePhoto: controller.removePhoto,
                      ),
                      const SizedBox(height: AppSpacing.x32),
                      MemoContentField(
                        content: state.content,
                        maxLength: memoWriteMaxContentLength,
                        onChanged: controller.updateContent,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x20,
                  0,
                  AppSpacing.x20,
                  AppSpacing.x16,
                ),
                child: CommonButton(
                  label: '완료',
                  isLoading: state.isSubmitting,
                  onPressed: state.canSubmit
                      ? () => _submit(context, ref)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoPhotoSection extends StatelessWidget {
  const _MemoPhotoSection({
    required this.hasPhoto,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final bool hasPhoto;
  final VoidCallback onAddPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.photoAddButtonSize + AppSpacing.x4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.x4),
            child: CommonPhotoAddButton(
              currentCount: hasPhoto ? 1 : 0,
              maxCount: memoWriteMaxPhotoCount,
              backgroundColor: hasPhoto ? AppColors.surfaceDisabled : null,
              onTap: hasPhoto ? null : onAddPhoto,
            ),
          ),
          if (hasPhoto) ...[
            const SizedBox(width: AppSpacing.x16),
            _MemoSelectedPhoto(onRemove: onRemovePhoto),
          ],
        ],
      ),
    );
  }
}

class _MemoSelectedPhoto extends StatelessWidget {
  const _MemoSelectedPhoto({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.photoAddButtonSize + AppSpacing.x10,
      height: AppSizes.photoAddButtonSize + AppSpacing.x4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: AppSpacing.x4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(
                AppImageAssets.placeDetailMonstera,
                width: AppSizes.photoAddButtonSize,
                height: AppSizes.photoAddButtonSize,
                fit: BoxFit.cover,
                semanticLabel: '첨부된 메모 사진',
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox.square(
              dimension: AppSizes.iconMedium,
              child: IconButton(
                tooltip: '첨부 사진 삭제',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: AppSizes.iconMedium,
                  height: AppSizes.iconMedium,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.textBody,
                  foregroundColor: AppColors.white,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.close, size: AppSizes.iconSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
