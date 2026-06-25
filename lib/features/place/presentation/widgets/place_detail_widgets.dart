import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selection_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_fab.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailFriendItem {
  const PlaceDetailFriendItem({
    required this.id,
    required this.name,
    this.imageAsset,
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final bool isOwner;

  PlaceFriendProfile toProfile() {
    return PlaceFriendProfile(id: id, name: name, imageAsset: imageAsset);
  }
}

class PlaceDetailPlantItem {
  const PlaceDetailPlantItem({
    required this.id,
    required this.name,
    required this.species,
    required this.description,
    required this.dDayLabel,
    required this.dateLabel,
    this.canWater = false,
  });

  final String id;
  final String name;
  final String species;
  final String description;
  final String dDayLabel;
  final String dateLabel;
  final bool canWater;
}

class PlaceDetailHeader extends StatelessWidget {
  const PlaceDetailHeader({
    super.key,
    required this.placeId,
    required this.name,
    required this.address,
    required this.sunlightLabel,
    required this.humidityLabel,
    required this.friends,
  });

  final String placeId;
  final String name;
  final String address;
  final String sunlightLabel;
  final String humidityLabel;
  final List<PlaceDetailFriendItem> friends;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        boxShadow: [
          BoxShadow(
            color: AppColors.textStrong.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x20,
          AppSpacing.x16,
          AppSpacing.x20,
          AppSpacing.x16,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PlaceTitleBlock(name: name, address: address),
                ),
                const SizedBox(width: AppSpacing.x12),
                _PlaceMetricStrip(
                  sunlightLabel: sunlightLabel,
                  humidityLabel: humidityLabel,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x24),
            _PlaceFriendStrip(friends: friends, placeId: placeId),
          ],
        ),
      ),
    );
  }
}

class PlacePlantList extends StatelessWidget {
  const PlacePlantList({
    super.key,
    required this.placeId,
    required this.plants,
  });

  final String placeId;
  final List<PlaceDetailPlantItem> plants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x24,
        AppSpacing.x20,
        120,
      ),
      child: Column(
        children: [
          for (final plant in plants) ...[
            CommonPlacePlantCard(
              width: double.infinity,
              name: plant.name,
              species: plant.species,
              description: plant.description,
              imageProvider: const AssetImage(
                AppImageAssets.placeDetailMonstera,
              ),
              action: CommonWateringButton(
                onPressed: plant.canWater ? () {} : null,
              ),
              trailing: _PlantDueInfo(
                dDayLabel: plant.dDayLabel,
                dateLabel: plant.dateLabel,
                isPrimary: plant.canWater,
              ),
              onTap: () => context.push(
                AppRoutePaths.plantDetailLocation(plant.id, placeId: placeId),
              ),
            ),
            if (plant != plants.last) const SizedBox(height: AppSpacing.x16),
          ],
        ],
      ),
    );
  }
}

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

class _PlaceTitleBlock extends StatelessWidget {
  const _PlaceTitleBlock({required this.name, required this.address});

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size24Medium.copyWith(
            color: AppColors.textHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size16Medium.copyWith(
            color: AppColors.textStrong,
          ),
        ),
      ],
    );
  }
}

class _PlaceMetricStrip extends StatelessWidget {
  const _PlaceMetricStrip({
    required this.sunlightLabel,
    required this.humidityLabel,
  });

  final String sunlightLabel;
  final String humidityLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlaceMetric(
          icon: AppIconAssets.tagSunlight,
          label: sunlightLabel,
          semanticsLabel: '햇빛',
        ),
        const SizedBox(width: AppSpacing.x16),
        _PlaceMetric(
          icon: AppIconAssets.tagHumidity,
          label: humidityLabel,
          semanticsLabel: '습도',
        ),
      ],
    );
  }
}

class _PlaceMetric extends StatelessWidget {
  const _PlaceMetric({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
  });

  final String icon;
  final String label;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonSvgIcon(
          icon,
          width: AppSizes.iconMedium,
          height: AppSizes.iconMedium,
          semanticsLabel: semanticsLabel,
        ),
        const SizedBox(height: AppSpacing.x8),
        Text(
          label,
          style: AppTextStyles.size14Medium.copyWith(
            color: AppColors.textHeadline,
          ),
        ),
      ],
    );
  }
}

class _PlaceFriendStrip extends StatelessWidget {
  const _PlaceFriendStrip({required this.friends, required this.placeId});

  final List<PlaceDetailFriendItem> friends;
  final String placeId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final friend in friends)
          _PlaceFriendMark(friend: friend, profile: friend.toProfile()),
        _FriendManagementShortcut(
          onPressed: () =>
              context.push(AppRoutePaths.friendManagementLocation(placeId)),
        ),
      ],
    );
  }
}

class _PlaceFriendMark extends StatelessWidget {
  const _PlaceFriendMark({required this.friend, required this.profile});

  final PlaceDetailFriendItem friend;
  final PlaceFriendProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (friend.isOwner)
                  Positioned(
                    left: 1,
                    top: 2,
                    child: Transform.rotate(
                      angle: -0.8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(AppRadius.xSmall),
                        ),
                        child: const SizedBox(width: 18, height: 10),
                      ),
                    ),
                  ),
                PlaceFriendAvatar(friend: profile, dimension: 36),
              ],
            ),
          ),
          Text(
            friend.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size12Medium.copyWith(
              color: AppColors.iconInactive,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendManagementShortcut extends StatelessWidget {
  const _FriendManagementShortcut({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '친구 관리',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Align(
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceDisabled,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 36,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.iconInactive,
                  size: AppSizes.iconMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantDueInfo extends StatelessWidget {
  const _PlantDueInfo({
    required this.dDayLabel,
    required this.dateLabel,
    required this.isPrimary,
  });

  final String dDayLabel;
  final String dateLabel;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dDayLabel,
          style: AppTextStyles.size16Bold.copyWith(
            color: isPrimary ? AppColors.brandPrimary : AppColors.iconInactive,
          ),
        ),
        Text(
          dateLabel,
          style: AppTextStyles.size12Medium.copyWith(color: AppColors.textBody),
        ),
      ],
    );
  }
}
