import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _heroContentHeight = 200;
const double _homeSectionContentGap = 26;
const int _placeInvitationRequestCount = 3;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surfaceAlt,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: const _HomeBottomTabBar(),
        body: const _HomeFigmaFrame(),
      ),
    );
  }
}

class _HomeFigmaFrame extends StatelessWidget {
  const _HomeFigmaFrame();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + _heroContentHeight;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.white),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: heroHeight,
          child: _HomeHero(topInset: topInset),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: heroHeight,
          bottom: 0,
          child: const _HomeBody(),
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AppColors.surfaceAlt)),
        Positioned(
          left: 0,
          right: 0,
          top: topInset,
          height: _heroContentHeight,
          child: CommonSvgIcon(
            AppImageAssets.homeMainHeroBackground,
            fit: BoxFit.fill,
            semanticsLabel: '메인 배경',
          ),
        ),
        Positioned(
          left: AppSpacing.x20,
          top: topInset + 48,
          child: Text(
            '커먼(유저 네임',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColorPrimitives.unspecifiedGreenGray,
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.x20,
          top: topInset + 76,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 44,
                child: Container(
                  width: 70,
                  height: 10,
                  color: AppColorPrimitives.unspecifiedGreenGray.withValues(
                    alpha: 0.16,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.size20Medium.copyWith(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(text: '님과 함께 친환경 한 걸음을\n'),
                    TextSpan(
                      text: '한걸음에',
                      style: TextStyle(color: AppColors.brandStrong),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 23,
          top: topInset + 110,
          width: 88,
          height: 64,
          child: const CommonSvgIcon(
            AppIconAssets.userIllustration,
            fit: BoxFit.fill,
            semanticsLabel: '유저 일러스트',
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: topInset + 161,
          height: 27,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD8DEDD).withValues(alpha: 0.6),
                  const Color(0x00D8DEDD),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeContentFrame extends StatelessWidget {
  const _HomeContentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
      child: child,
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placeSummariesProvider);
    final plantsAsync = ref.watch(plantSummariesProvider);

    if (placesAsync.isLoading || plantsAsync.isLoading) {
      return const _HomeStatusBody(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    if (placesAsync.hasError || plantsAsync.hasError) {
      return _HomeStatusBody(
        child: Text(
          '데이터를 불러오지 못했어요',
          style: AppTextStyles.size16Medium.copyWith(color: AppColors.textBody),
        ),
      );
    }

    final places = placesAsync.value ?? const [];
    final hasPlaces = places.isNotEmpty;
    final plants = plantsAsync.value ?? const [];
    final hasPlants = plants.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.x24, bottom: 120),
      child: _HomeContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeSectionHeader(
              title: 'My place',
              addSemanticsLabel: '장소 추가',
              action: _HomePlaceRequestButton(
                count: _placeInvitationRequestCount,
                onPressed: () => context.push(AppRoutePaths.placeInvitations),
              ),
              onAddPressed: hasPlaces
                  ? () => context.push(AppRoutePaths.placeCreate)
                  : null,
            ),
            const SizedBox(height: _homeSectionContentGap),
            SizedBox(
              height: AppSizes.placeAddTileHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (hasPlaces)
                    for (final place in places) ...[
                      CommonPlaceCard(
                        title: place.name,
                        onTap: () => context.push(
                          AppRoutePaths.placeDetailLocation(place.id),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x12),
                    ]
                  else
                    _HomeAddTile(
                      label: '장소 추가하기',
                      width: AppSizes.placeAddTileWidth,
                      height: AppSizes.placeAddTileHeight,
                      borderColor: AppColors.brandStrong,
                      foregroundColor: AppColors.brandPrimary,
                      iconAsset: AppIconAssets.plusGreen,
                      onTap: () => context.push(AppRoutePaths.placeCreate),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x32),
            _HomeSectionHeader(
              title: 'My plant',
              addSemanticsLabel: '식물 추가',
              onAddPressed: hasPlants
                  ? () => context.push(AppRoutePaths.plantSearch)
                  : null,
            ),
            const SizedBox(height: _homeSectionContentGap),
            if (hasPlants)
              SizedBox(
                height: AppSizes.plantCardHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final plant in plants) ...[
                      Semantics(
                        label: plant.name,
                        button: true,
                        child: CommonPlantCard(
                          onTap: () => context.push(
                            AppRoutePaths.plantDetailLocation(
                              plant.id,
                              placeId: plant.placeId,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x12),
                    ],
                  ],
                ),
              )
            else
              _HomeAddTile(
                label: '식물 추가하기',
                width: AppSizes.plantAddTileWidth,
                height: AppSizes.plantAddTileHeight,
                borderColor: hasPlaces
                    ? AppColors.brandStrong
                    : AppColors.textDisabled,
                foregroundColor: hasPlaces
                    ? AppColors.brandPrimary
                    : AppColors.textDisabled,
                backgroundColor: hasPlaces
                    ? AppColors.white
                    : AppColors.surfaceDisabled,
                iconAsset: hasPlaces
                    ? AppIconAssets.plusGreen
                    : AppIconAssets.plusGray,
                onTap: hasPlaces
                    ? () => context.push(AppRoutePaths.plantSearch)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeStatusBody extends StatelessWidget {
  const _HomeStatusBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x20),
        child: child,
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    required this.addSemanticsLabel,
    this.action,
    this.onAddPressed,
  });

  final String title;
  final String addSemanticsLabel;
  final Widget? action;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.x12), action!],
        if (onAddPressed != null) const SizedBox(width: AppSpacing.x12),
        if (onAddPressed != null)
          Semantics(
            label: addSemanticsLabel,
            button: true,
            child: _HomeSectionAddButton(onPressed: onAddPressed!),
          ),
      ],
    );
  }
}

class _HomePlaceRequestButton extends StatelessWidget {
  const _HomePlaceRequestButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '장소 요청 $count건',
      button: true,
      child: CommonButton(
        label: '요청 $count건',
        onPressed: onPressed,
        size: CommonButtonSize.small,
        width: AppSizes.smallButtonWidth,
        backgroundColor: AppColors.brandAccent,
        foregroundColor: AppColors.white,
      ),
    );
  }
}

class _HomeSectionAddButton extends StatelessWidget {
  const _HomeSectionAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: const SizedBox.square(
          dimension: AppSizes.iconMedium,
          child: CommonSvgIcon(
            AppIconAssets.plusGreen,
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
          ),
        ),
      ),
    );
  }
}

class _HomeAddTile extends StatelessWidget {
  const _HomeAddTile({
    required this.label,
    required this.width,
    required this.height,
    required this.borderColor,
    required this.foregroundColor,
    required this.iconAsset,
    this.backgroundColor = AppColors.white,
    this.onTap,
  });

  final String label;
  final double width;
  final double height;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final String iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonSvgIcon(
              iconAsset,
              width: 24,
              height: 24,
              semanticsLabel: label,
            ),
            const SizedBox(width: AppSpacing.x10),
            Text(
              label,
              style: AppTextStyles.size14Medium.copyWith(
                color: foregroundColor,
              ),
            ),
          ],
        ),
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

class _HomeBottomTabBar extends StatelessWidget {
  const _HomeBottomTabBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFDFD),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: const [
                _HomeBottomTabItem(
                  icon: Icons.article_outlined,
                  semanticsLabel: '정보',
                ),
                _HomeBottomTabItem(
                  icon: Icons.chat_bubble_outline,
                  semanticsLabel: '이야기',
                ),
                _HomeGardenTabItem(isSelected: true),
                _HomeBottomTabItem(
                  icon: Icons.calendar_today_outlined,
                  semanticsLabel: '캘린더',
                ),
                _HomeBottomTabItem(
                  icon: Icons.person_outline,
                  semanticsLabel: '마이',
                  iconSize: AppSizes.iconLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomTabItem extends StatelessWidget {
  const _HomeBottomTabItem({
    required this.icon,
    required this.semanticsLabel,
    this.iconSize = AppSizes.iconMedium,
  });

  final IconData icon;
  final String semanticsLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: AppColors.textDisabled,
          semanticLabel: semanticsLabel,
        ),
      ),
    );
  }
}

class _HomeGardenTabItem extends StatelessWidget {
  const _HomeGardenTabItem({this.isSelected = true});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonSvgIcon(
              isSelected ? AppIconAssets.plantSelected : AppIconAssets.plant,
              width: 24,
              height: 24,
              semanticsLabel: '정원',
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.x8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.brandAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
