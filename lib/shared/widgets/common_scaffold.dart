import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  const CommonScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.trailing,
    this.floatingActionButton,
    this.bodyPadding,
    this.showNavigationBar = true,
    this.showBackButton = true,
    this.onBackPressed,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? trailing;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? bodyPadding;
  final bool showNavigationBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return Scaffold(
      backgroundColor: tokens.canvas,
      floatingActionButton: floatingActionButton,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              if (showNavigationBar)
                CommonNavigationBar(
                  title: title,
                  showBackButton: showBackButton,
                  onBackPressed: onBackPressed,
                  trailing: trailing ?? _actionsTrailing(actions),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      bodyPadding ??
                      const EdgeInsets.fromLTRB(
                        AppSpacing.x20,
                        AppSpacing.x24,
                        AppSpacing.x20,
                        AppSpacing.x24,
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!showNavigationBar) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            if (actions case final actions?)
                              ...actions.expand(
                                (widget) => <Widget>[
                                  const SizedBox(width: AppSpacing.x8),
                                  widget,
                                ],
                              ),
                          ],
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.x8),
                          Text(subtitle!, style: theme.textTheme.bodyLarge),
                        ],
                        const SizedBox(height: AppSpacing.x24),
                      ] else if (subtitle != null) ...[
                        Text(subtitle!, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.x24),
                      ],
                      child,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _actionsTrailing(List<Widget>? actions) {
    if (actions == null || actions.isEmpty) {
      return null;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }
}

class CommonNavigationBar extends StatelessWidget {
  const CommonNavigationBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.navigationBarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: AppSizes.navigationBarSideWidth,
            child: showBackButton
                ? IconButton(
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    iconSize: AppSizes.navigationBackIconSize,
                    color: AppColors.textStrong,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: AppSizes.navigationBarSideWidth,
                      height: AppSizes.navigationBarHeight,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.navigationBarSideWidth,
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.size16Bold.copyWith(
                color: AppColors.textStrong,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: AppSizes.navigationBarSideWidth,
            child: Center(child: trailing ?? const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
