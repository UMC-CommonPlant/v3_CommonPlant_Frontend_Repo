import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
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
  final TextEditingController _memoController = TextEditingController();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;
    final canSubmit = _memoController.text.trim().isNotEmpty;

    return CommonScaffold(
      title: '메모 작성',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘 식물 상태는 어땠나요?',
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.surfaceBase,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: tokens.borderDefault),
            ),
            child: TextField(
              controller: _memoController,
              minLines: 8,
              maxLines: 10,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.size16Medium.copyWith(
                color: AppColors.textStrong,
              ),
              decoration: InputDecoration(
                hintText: '물주기, 잎 상태, 위치 변경 등을 기록해 주세요.',
                hintStyle: AppTextStyles.size16Medium.copyWith(
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.x16),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          Text(
            '사진',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x12),
          const Row(
            children: [
              CommonPhotoAddButton(currentCount: 0, maxCount: 3),
              SizedBox(width: AppSpacing.x16),
              Expanded(child: Text('사진을 함께 남기면 변화 과정을 더 쉽게 확인할 수 있어요.')),
            ],
          ),
          const SizedBox(height: AppSpacing.x32),
          CommonButton(
            label: '저장',
            onPressed: canSubmit
                ? () =>
                      context.go(AppRoutePaths.memoListLocation(widget.plantId))
                : null,
          ),
        ],
      ),
    );
  }
}
