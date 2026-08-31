import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class CommonAddressOrPlaceField extends StatelessWidget {
  const CommonAddressOrPlaceField({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.onClear,
    this.errorText,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final String? errorText;

  bool get _hasValue => value != null && value!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: errorText == null
                        ? AppColorPrimitives.grayGray2
                        : AppColors.danger,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.addressOrPlaceFieldHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size18Medium.copyWith(
                        color: AppColors.textStrong,
                      ),
                    ),
                    if (_hasValue)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                value!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.size18Medium.copyWith(
                                  color: AppColors.textStrong,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x8),
                            _AddressOrPlaceClearButton(onPressed: onClear),
                          ],
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        size: AppSizes.addressOrPlaceDeleteIconSize,
                        color: AppColors.textStrong,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.x8),
          Text(
            errorText!,
            style: AppTextStyles.size12Medium.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

class _AddressOrPlaceClearButton extends StatelessWidget {
  const _AddressOrPlaceClearButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.addressOrPlaceDeleteIconSize,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: AppSizes.addressOrPlaceDeleteIconSize,
          height: AppSizes.addressOrPlaceDeleteIconSize,
        ),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const CommonSvgIcon(
          AppIconAssets.delete,
          width: AppSizes.addressOrPlaceDeleteIconSize,
          height: AppSizes.addressOrPlaceDeleteIconSize,
          semanticsLabel: '선택값 삭제',
        ),
      ),
    );
  }
}
