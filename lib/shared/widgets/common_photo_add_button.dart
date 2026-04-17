import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonPhotoAddButton extends StatelessWidget {
  const CommonPhotoAddButton({
    super.key,
    this.onTap,
    this.currentCount = 0,
    this.maxCount = 1,
    this.size = AppSizes.photoAddButtonSize,
  });

  final VoidCallback? onTap;
  final int currentCount;
  final int maxCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CommonSvgIcon(
            AppIconAssets.cameraAlt,
            width: 32,
            height: 32,
            color: AppColors.textHeadline,
            semanticsLabel: '사진 추가',
          ),
          const SizedBox(height: AppSpacing.x8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textBody,
              ),
              children: [
                TextSpan(
                  text: '$currentCount',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '/$maxCount'),
              ],
            ),
          ),
        ],
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
