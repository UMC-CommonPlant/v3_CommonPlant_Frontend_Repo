import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_circle_image_box.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_image_add_button.dart';
import 'package:flutter/material.dart';

/// 폼의 단일 사진 미리보기. 선택 취소는 저장 전 초안에만 적용한다.
class CommonFormImageField extends StatelessWidget {
  const CommonFormImageField({
    super.key,
    this.imageProvider,
    this.onPick,
    this.onReset,
    this.isPicking = false,
    this.isCircular = false,
    this.size = AppSizes.profileImageBoxSize,
  });

  final ImageProvider<Object>? imageProvider;
  final VoidCallback? onPick;
  final VoidCallback? onReset;
  final bool isPicking;
  final bool isCircular;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: imageProvider == null ? '사진 선택' : '사진 교체',
          button: true,
          enabled: onPick != null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCircular)
                CommonCircleImageBox(
                  imageProvider: imageProvider,
                  onTap: onPick,
                  size: size,
                )
              else
                CommonPlaceImageAddButton(
                  imageProvider: imageProvider,
                  onTap: onPick,
                  imageSemanticsLabel: '선택한 사진 미리보기',
                ),
              if (isPicking)
                const CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                  semanticsLabel: '사진 불러오는 중',
                ),
            ],
          ),
        ),
        if (onReset != null)
          TextButton(onPressed: onReset, child: const Text('선택 취소')),
      ],
    );
  }
}
