import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const double _profileActionSheetButtonHeight = 56;
const double _profileActionSheetHorizontalInset = 8;
const double _profileActionSheetRadius = 14;

enum ProfileImageSheetAction { selectFromAlbum, resetToDefault }

class ProfileImageActionSheet extends StatelessWidget {
  const ProfileImageActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _profileActionSheetHorizontalInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_profileActionSheetRadius),
              child: ColoredBox(
                color: AppColors.white,
                child: Column(
                  children: [
                    _ProfileActionSheetTitle(label: '프로필 사진 설정'),
                    _ProfileActionSheetButton(
                      label: '앨범에서 사진 선택',
                      onTap: () => Navigator.of(
                        context,
                      ).pop(ProfileImageSheetAction.selectFromAlbum),
                    ),
                    _ProfileActionSheetButton(
                      label: '기본 이미지로 변경',
                      onTap: () => Navigator.of(
                        context,
                      ).pop(ProfileImageSheetAction.resetToDefault),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x12),
            ClipRRect(
              borderRadius: BorderRadius.circular(_profileActionSheetRadius),
              child: ColoredBox(
                color: AppColors.white,
                child: _ProfileActionSheetButton(
                  label: '취소',
                  isEmphasized: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionSheetTitle extends StatelessWidget {
  const _ProfileActionSheetTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _profileActionSheetButtonHeight,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size12Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const _ProfileSheetDivider(),
        ],
      ),
    );
  }
}

class _ProfileActionSheetButton extends StatelessWidget {
  const _ProfileActionSheetButton({
    required this.label,
    required this.onTap,
    this.isEmphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasized
        ? AppTextStyles.size18Medium.copyWith(
            color: AppColors.actionBlue,
            fontWeight: FontWeight.w700,
          )
        : AppTextStyles.size18Medium.copyWith(color: AppColors.actionBlue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _profileActionSheetButtonHeight,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
              if (!isEmphasized) const _ProfileSheetDivider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSheetDivider extends StatelessWidget {
  const _ProfileSheetDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColorPrimitives.separatorColors.withValues(alpha: 0.36),
    );
  }
}
