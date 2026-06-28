import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_fab.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailFab extends StatelessWidget {
  const PlaceDetailFab({
    super.key,
    required this.placeId,
    required this.canEditPlace,
    required this.onExit,
  });

  final String placeId;
  final bool canEditPlace;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return CommonFabDial(
      actions: [
        CommonFabDialAction(
          label: '식물 추가하기',
          icon: const CommonSvgIcon(
            AppIconAssets.addPlant,
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
            color: AppColors.textStrong,
            semanticsLabel: '식물 추가',
          ),
          onPressed: () => context.push(AppRoutePaths.plantSearch),
        ),
        if (canEditPlace)
          CommonFabDialAction(
            label: '장소 수정하기',
            icon: const CommonSvgIcon(
              AppIconAssets.edit,
              width: AppSizes.iconMedium,
              height: AppSizes.iconMedium,
              color: AppColors.textStrong,
              semanticsLabel: '장소 수정',
            ),
            onPressed: () =>
                context.push(AppRoutePaths.placeEditLocation(placeId)),
          ),
        CommonFabDialAction(
          label: '장소 나가기',
          icon: const CommonSvgIcon(
            AppIconAssets.exit,
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
            color: AppColors.textStrong,
            semanticsLabel: '장소 나가기',
          ),
          onPressed: onExit,
        ),
      ],
      child: const CommonSvgIcon(
        AppIconAssets.shape,
        width: 5,
        height: 25,
        semanticsLabel: '장소 상세 메뉴',
      ),
    );
  }
}
