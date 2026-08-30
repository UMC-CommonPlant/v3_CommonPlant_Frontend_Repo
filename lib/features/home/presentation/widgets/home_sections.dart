import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    required this.addSemanticsLabel,
    this.action,
    this.onAddPressed,
    super.key,
  });

  final String title;
  final String addSemanticsLabel;
  final Widget? action;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.x12), action!],
        if (onAddPressed != null) const SizedBox(width: AppSpacing.x12),
        if (onAddPressed != null)
          Semantics(
            label: addSemanticsLabel,
            button: true,
            child: _HomeSectionAddButton(onPressed: onAddPressed!),
          ),
      ],
    );
  }
}

class HomePlaceRequestButton extends StatelessWidget {
  const HomePlaceRequestButton({
    required this.count,
    required this.onPressed,
    super.key,
  }) : _state = _HomePlaceRequestButtonState.count;

  const HomePlaceRequestButton.loading({super.key})
    : count = null,
      onPressed = null,
      _state = _HomePlaceRequestButtonState.loading;

  const HomePlaceRequestButton.error({required VoidCallback onRetry, super.key})
    : count = null,
      onPressed = onRetry,
      _state = _HomePlaceRequestButtonState.error;

  final int? count;
  final VoidCallback? onPressed;
  final _HomePlaceRequestButtonState _state;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = switch (_state) {
      _HomePlaceRequestButtonState.count => '장소 요청 $count건',
      _HomePlaceRequestButtonState.loading => '장소 요청 불러오는 중',
      _HomePlaceRequestButtonState.error => '장소 요청 조회 실패, 다시 시도',
    };
    final label = switch (_state) {
      _HomePlaceRequestButtonState.count => '요청 $count건',
      _HomePlaceRequestButtonState.loading => '',
      _HomePlaceRequestButtonState.error => '재시도',
    };

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: ExcludeSemantics(
        child: CommonButton(
          label: label,
          onPressed: onPressed,
          size: CommonButtonSize.small,
          width: AppSizes.smallButtonWidth,
          backgroundColor: _state == _HomePlaceRequestButtonState.error
              ? AppColors.danger
              : AppColors.brandAccent,
          foregroundColor: AppColors.white,
          isLoading: _state == _HomePlaceRequestButtonState.loading,
        ),
      ),
    );
  }
}

enum _HomePlaceRequestButtonState { count, loading, error }

class HomeAddTile extends StatelessWidget {
  const HomeAddTile({
    required this.label,
    required this.width,
    required this.height,
    required this.borderColor,
    required this.foregroundColor,
    required this.iconAsset,
    this.backgroundColor = AppColors.white,
    this.onTap,
    super.key,
  });

  final String label;
  final double width;
  final double height;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final String iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonSvgIcon(
              iconAsset,
              width: 24,
              height: 24,
              semanticsLabel: label,
            ),
            const SizedBox(width: AppSpacing.x10),
            Text(
              label,
              style: AppTextStyles.size14Medium.copyWith(
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: content,
    );
  }
}

class _HomeSectionAddButton extends StatelessWidget {
  const _HomeSectionAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: const SizedBox.square(
          dimension: AppSizes.iconMedium,
          child: CommonSvgIcon(
            AppIconAssets.plusGreen,
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
          ),
        ),
      ),
    );
  }
}
