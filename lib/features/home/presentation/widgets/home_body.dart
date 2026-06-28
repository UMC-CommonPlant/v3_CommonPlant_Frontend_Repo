import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_sections.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _homeSectionContentGap = 26;
const int _placeInvitationRequestCount = 3;

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

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
            HomeSectionHeader(
              title: 'My place',
              addSemanticsLabel: '장소 추가',
              action: HomePlaceRequestButton(
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
                    HomeAddTile(
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
            HomeSectionHeader(
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
                          imageProvider: plant.imageUrl == null
                              ? null
                              : NetworkImage(plant.imageUrl!),
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
              HomeAddTile(
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
