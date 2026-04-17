import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class CommonMemoCard extends StatelessWidget {
  const CommonMemoCard({
    super.key,
    required this.author,
    required this.content,
    required this.dateLabel,
    this.avatar,
    this.thumbnail,
    this.width = AppSizes.memoCardWidth,
    this.height = AppSizes.memoCardHeight,
  });

  final String author;
  final String content;
  final String dateLabel;
  final Widget? avatar;
  final Widget? thumbnail;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceBase,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: tokens.borderDefault),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBody.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: AppSizes.memoHeaderHeight,
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox.square(
                        dimension: AppSizes.memoAvatarSize,
                        child:
                            avatar ??
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: tokens.surfaceAlt,
                                shape: BoxShape.circle,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x12),
                    Expanded(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.size16Medium.copyWith(
                          color: AppColors.textStrong,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: AppSizes.memoContentHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.size16Medium.copyWith(
                      color: AppColors.textStrong,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: AppSizes.memoThumbnailHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      child: SizedBox(
                        height: AppSizes.memoThumbnailHeight,
                        child: AspectRatio(
                          aspectRatio: 76 / 54,
                          child:
                              thumbnail ??
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: tokens.surfaceAlt,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: AppSizes.memoDatePaddingRight,
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              dateLabel,
                              maxLines: 1,
                              style: AppTextStyles.size14Medium.copyWith(
                                color: AppColors.iconInactive,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
