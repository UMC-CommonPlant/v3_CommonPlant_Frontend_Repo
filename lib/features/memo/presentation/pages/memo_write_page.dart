import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_photo_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemoWritePage extends StatefulWidget {
  const MemoWritePage({super.key, required this.plantId});

  final String plantId;

  @override
  State<MemoWritePage> createState() => _MemoWritePageState();
}

class _MemoWritePageState extends State<MemoWritePage> {
  static const int _maxMemoLength = 200;
  static const int _maxPhotoCount = 1;

  final TextEditingController _memoController = TextEditingController();
  bool _hasPhoto = false;

  bool get _canSubmit => _memoController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _memoController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _memoController.removeListener(_handleInputChanged);
    _memoController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    setState(() {});
  }

  void _selectPhoto() {
    setState(() => _hasPhoto = true);
  }

  void _removePhoto() {
    setState(() => _hasPhoto = false);
  }

  void _submit() {
    context.go(AppRoutePaths.memoListLocation(widget.plantId));
  }

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
                        hasPhoto: _hasPhoto,
                        onAddPhoto: _selectPhoto,
                        onRemovePhoto: _removePhoto,
                      ),
                      const SizedBox(height: AppSpacing.x32),
                      _MemoContentField(
                        controller: _memoController,
                        maxLength: _maxMemoLength,
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
                  onPressed: _canSubmit ? _submit : null,
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
              maxCount: _MemoWritePageState._maxPhotoCount,
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

class _MemoContentField extends StatelessWidget {
  const _MemoContentField({required this.controller, required this.maxLength});

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final currentLength = controller.text.characters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
          ),
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            minLines: 1,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textStrong,
            ),
            decoration: InputDecoration(
              hintText: '메모 내용을 입력해 주세요',
              hintStyle: AppTextStyles.size18Medium.copyWith(
                color: AppColors.textDisabled,
              ),
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.x16,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x8),
        RichText(
          text: TextSpan(
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
            children: [
              TextSpan(
                text: '$currentLength',
                style: AppTextStyles.size14Bold.copyWith(
                  color: AppColors.textBody,
                ),
              ),
              TextSpan(text: '/$maxLength'),
            ],
          ),
        ),
      ],
    );
  }
}
