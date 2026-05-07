import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';

class Phase0Section extends StatelessWidget {
  const Phase0Section({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.size20Medium.copyWith(
                  color: AppColors.textHeadline,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.x4),
          Text(
            subtitle!,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.x12),
        child,
      ],
    );
  }
}

class Phase0Surface extends StatelessWidget {
  const Phase0Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.x16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: tokens.borderDefault),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: content,
    );
  }
}

class Phase0Chip extends StatelessWidget {
  const Phase0Chip({super.key, required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive ? tokens.brandSoft : tokens.surfaceDisabled,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12,
          vertical: AppSpacing.x4,
        ),
        child: Text(
          label,
          style: AppTextStyles.size12Medium.copyWith(
            color: isActive ? tokens.brandStrong : tokens.textBody,
          ),
        ),
      ),
    );
  }
}

class Phase0EmptyState extends StatelessWidget {
  const Phase0EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return Phase0Surface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x20,
        vertical: AppSpacing.x24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(height: AppSpacing.x16)],
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.size16Bold.copyWith(color: tokens.textStrong),
          ),
          const SizedBox(height: AppSpacing.x8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.size14Medium.copyWith(color: tokens.textBody),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.x16),
            CommonButton(
              label: actionLabel!,
              onPressed: onAction,
              size: CommonButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}

class Phase0UserAvatar extends StatelessWidget {
  const Phase0UserAvatar({
    super.key,
    required this.label,
    this.size = 40,
    this.backgroundColor,
  });

  final String label;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? tokens.brandSoft,
      child: Text(
        label,
        style: AppTextStyles.size14Bold.copyWith(color: tokens.brandStrong),
      ),
    );
  }
}

class Phase0InfoRow extends StatelessWidget {
  const Phase0InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textStrong,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.x8),
          trailing!,
        ],
      ],
    );
  }
}
