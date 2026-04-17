import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

const commonDialogBarrierColor = Color(0x66000000);

Future<T?> showCommonDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color barrierColor = commonDialogBarrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: (context) => child,
  );
}

class CommonDialogCard extends StatelessWidget {
  const CommonDialogCard({
    super.key,
    required this.title,
    this.message,
    required this.actions,
  });

  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return Dialog(
      backgroundColor: tokens.surfaceBase,
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      child: SizedBox(
        width: AppSizes.dialogWidth,
        height: AppSizes.dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AppSizes.dialogContentHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size16Bold.copyWith(
                        color: AppColors.textHeadline,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.size14Medium.copyWith(
                          color: AppColors.textStrong,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (actions.isNotEmpty) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: AppColorPrimitives.separatorColors.withValues(
                  alpha: 0.36,
                ),
              ),
              SizedBox(
                height: AppSizes.dialogActionHeight,
                child: Row(
                  children: [
                    for (var index = 0; index < actions.length; index++) ...[
                      if (index > 0)
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: AppColorPrimitives.separatorColors.withValues(
                            alpha: 0.36,
                          ),
                        ),
                      Expanded(child: actions[index]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CommonDialogActionButton extends StatelessWidget {
  const CommonDialogActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.foregroundColor,
    this.isEmphasized = false,
  });

  const CommonDialogActionButton.confirm({
    super.key,
    this.label = '확인',
    this.onPressed,
    this.foregroundColor,
  }) : isEmphasized = true;

  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;
    final textColor = onPressed == null
        ? tokens.textDisabled
        : foregroundColor ?? tokens.brandStrong;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (isEmphasized
                        ? AppTextStyles.size16Bold
                        : AppTextStyles.size16Medium)
                    .copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
