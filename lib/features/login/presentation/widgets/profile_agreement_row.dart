import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

const double profileAgreementRowHeight = 56;

class ProfileAgreementRow extends StatelessWidget {
  const ProfileAgreementRow({
    required this.label,
    required this.isAccepted,
    required this.onCheckPressed,
    this.accessibilityLabel,
    this.onViewPressed,
    this.checkKey,
    super.key,
  });

  final String label;
  final bool isAccepted;
  final VoidCallback? onCheckPressed;
  final String? accessibilityLabel;
  final VoidCallback? onViewPressed;
  final Key? checkKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: profileAgreementRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
        child: Row(
          children: [
            Flexible(
              child: Semantics(
                container: true,
                checked: isAccepted,
                enabled: onCheckPressed != null,
                label: accessibilityLabel ?? label,
                child: GestureDetector(
                  key: checkKey,
                  behavior: HitTestBehavior.opaque,
                  onTap: onCheckPressed,
                  child: ExcludeSemantics(
                    child: SizedBox(
                      height: profileAgreementRowHeight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
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
                          const SizedBox(width: AppSpacing.x12),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.size16Medium.copyWith(
                                color: AppColors.textHeadline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (onViewPressed case final onViewPressed?) ...[
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
          ],
        ),
      ),
    );
  }
}
