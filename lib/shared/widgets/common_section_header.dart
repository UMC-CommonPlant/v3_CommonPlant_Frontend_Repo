import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class CommonSectionHeader extends StatelessWidget {
  const CommonSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.size24Medium.copyWith(
              color: tokens.textHeadline,
            ),
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.x12), action!],
      ],
    );
  }
}
