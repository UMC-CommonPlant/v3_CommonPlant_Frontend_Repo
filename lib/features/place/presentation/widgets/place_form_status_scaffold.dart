import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';

class PlaceFormStatusScaffold extends StatelessWidget {
  const PlaceFormStatusScaffold({
    super.key,
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
