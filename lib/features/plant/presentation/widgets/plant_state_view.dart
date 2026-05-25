import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class PlantStateScaffold extends StatelessWidget {
  const PlantStateScaffold({
    super.key,
    required this.title,
    required this.statusTitle,
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
    this.showNavigationBar = true,
    this.showBackButton = true,
  });

  final String title;
  final String statusTitle;
  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showNavigationBar;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      showNavigationBar: showNavigationBar,
      showBackButton: showBackButton,
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
            child: SizedBox(
              height: AppSizes.mobileWidth,
              child: _PlantStateContent(
                title: statusTitle,
                message: message,
                isLoading: isLoading,
                actionLabel: actionLabel,
                onAction: onAction,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantStateContent extends StatelessWidget {
  const _PlantStateContent({
    required this.title,
    required this.message,
    required this.isLoading,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
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
              )
            else
              const CommonSvgIcon(
                AppIconAssets.plantEmpty,
                width: AppSizes.iconLarge,
                height: AppSizes.iconLarge,
                color: AppColors.iconInactive,
                semanticsLabel: '식물 정보 없음',
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
    );
  }
}
