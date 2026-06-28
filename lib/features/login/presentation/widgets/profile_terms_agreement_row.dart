import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const double _termsRowHeight = 56;

class ProfileTermsAgreementRow extends StatelessWidget {
  const ProfileTermsAgreementRow({
    required this.isAccepted,
    required this.onCheckPressed,
    required this.onViewPressed,
    super.key,
  });

  final bool isAccepted;
  final VoidCallback onCheckPressed;
  final VoidCallback onViewPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('profileTermsRow'),
      height: _termsRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x20,
          vertical: AppSpacing.x16,
        ),
        child: Row(
          children: [
            Semantics(
              button: true,
              container: true,
              label: isAccepted ? '개인정보 이용약관 동의됨' : '개인정보 이용약관 동의 필요',
              child: GestureDetector(
                key: const ValueKey('profileTermsCheckButton'),
                behavior: HitTestBehavior.opaque,
                onTap: onCheckPressed,
                child: ExcludeSemantics(
                  child: Container(
                    width: AppSizes.iconMedium,
                    height: AppSizes.iconMedium,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAccepted
                          ? AppColors.brandAccent
                          : AppColors.textDisabled,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: AppSizes.iconSmall,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x12),
            Flexible(
              child: Text(
                '개인정보 이용 약관 동의',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size16Medium.copyWith(
                  color: AppColors.textHeadline,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x8),
            GestureDetector(
              onTap: onViewPressed,
              child: Text(
                '보기',
                style: AppTextStyles.size16Bold.copyWith(
                  color: AppColors.iconInactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
