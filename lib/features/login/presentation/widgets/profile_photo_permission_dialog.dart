import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const double _profilePermissionDialogWidth = 270;
const double _profilePermissionDialogHeight = 248;
const double _profilePermissionActionHeight = 44;

enum ProfilePhotoPermissionAction { selectLimited, allowAll, deny }

class ProfilePhotoPermissionDialog extends StatelessWidget {
  const ProfilePhotoPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.alertSurface,
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      child: SizedBox(
        width: _profilePermissionDialogWidth,
        height: _profilePermissionDialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x16,
                  vertical: AppSpacing.x16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '‘커먼플랜트’이(가) 사용자의 사진에 접근하려고 합니다.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size16Bold.copyWith(
                        color: AppColors.textHeadline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '프로필 사진, 장소, 식물을 등록하거나,\n식물에 관한 메모를 등록할 때 사용합니다.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size12Medium.copyWith(
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ProfilePermissionActionButton(
              label: '사진 선택...',
              onTap: () => Navigator.of(
                context,
              ).pop(ProfilePhotoPermissionAction.selectLimited),
            ),
            _ProfilePermissionActionButton(
              label: '모든 사진에 대한 접근 허용',
              onTap: () => Navigator.of(
                context,
              ).pop(ProfilePhotoPermissionAction.allowAll),
            ),
            _ProfilePermissionActionButton(
              label: '허용 안 함',
              onTap: () =>
                  Navigator.of(context).pop(ProfilePhotoPermissionAction.deny),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePermissionActionButton extends StatelessWidget {
  const _ProfilePermissionActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _profilePermissionActionHeight,
          child: Column(
            children: [
              const _ProfilePermissionDivider(),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.size16Medium.copyWith(
                      color: AppColors.actionBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePermissionDivider extends StatelessWidget {
  const _ProfilePermissionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColorPrimitives.separatorColors.withValues(alpha: 0.36),
    );
  }
}
