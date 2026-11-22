import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_sections.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _homeSectionContentGap = 26;

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placeSummariesProvider);
    final plantsAsync = ref.watch(plantSummariesProvider);
    final invitationCountAsync = ref.watch(placeInvitationRequestCountProvider);
    final hasPlaces = placesAsync.asData?.value.isNotEmpty ?? false;
    final hasPlants = plantsAsync.asData?.value.isNotEmpty ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.x24, bottom: 120),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.smallButtonHeight,
              ),
              child: HomeSectionHeader(
                title: 'My place',
                addSemanticsLabel: '장소 추가',
                action: invitationCountAsync.when(
                  skipLoadingOnRefresh: false,
                  data: (count) => count > 0
                      ? HomePlaceRequestButton(
                          count: count,
                          onPressed: () =>
                              context.push(AppRoutePaths.placeInvitations),
                        )
                      : null,
                  loading: HomePlaceRequestButton.loading,
                  error: (_, _) => HomePlaceRequestButton.error(
                    onRetry: () =>
                        ref.invalidate(remotePlaceInvitationsProvider),
                  ),
                ),
                onAddPressed: hasPlaces
                    ? () => context.push(AppRoutePaths.placeCreate)
                    : null,
              ),
            ),
            const SizedBox(height: _homeSectionContentGap),
            placesAsync.when(
              loading: () => const _HomeListStatus(
                height: AppSizes.placeAddTileHeight,
                child: CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                  semanticsLabel: '장소 목록 불러오는 중',
                ),
              ),
              error: (_, _) => _HomeListError(
                height: AppSizes.placeAddTileHeight,
                message: '장소 목록을 불러오지 못했어요.',
                onRetry: () => ref.invalidate(remotePlaceListProvider),
              ),
              data: (places) => _buildPlaces(context, places),
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
            plantsAsync.when(
              loading: () => const _HomeListStatus(
                height: AppSizes.plantCardHeight,
                child: CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                  semanticsLabel: '식물 목록 불러오는 중',
                ),
              ),
              error: (_, _) => _HomeListError(
                height: AppSizes.plantCardHeight,
                message: '식물 목록을 불러오지 못했어요.',
                onRetry: () => ref.invalidate(remotePlantListProvider),
              ),
              data: (plants) => _buildPlants(context, plants, hasPlaces),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaces(BuildContext context, List<PlaceSummary> places) {
    return SizedBox(
      height: AppSizes.placeAddTileHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (places.isNotEmpty)
            for (final place in places) ...[
              CommonPlaceCard(
                title: place.name,
                imageProvider: place.imageUrl == null
                    ? null
                    : NetworkImage(place.imageUrl!),
                onTap: () =>
                    context.push(AppRoutePaths.placeDetailLocation(place.id)),
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
    );
  }

  Widget _buildPlants(
    BuildContext context,
    List<PlantSummary> plants,
    bool hasPlaces,
  ) {
    if (plants.isEmpty) {
      return HomeAddTile(
        label: '식물 추가하기',
        width: AppSizes.plantAddTileWidth,
        height: AppSizes.plantAddTileHeight,
        borderColor: hasPlaces ? AppColors.brandStrong : AppColors.textDisabled,
        foregroundColor: hasPlaces
            ? AppColors.brandPrimary
            : AppColors.textDisabled,
        backgroundColor: hasPlaces
            ? AppColors.white
            : AppColors.surfaceDisabled,
        iconAsset: hasPlaces ? AppIconAssets.plusGreen : AppIconAssets.plusGray,
        onTap: hasPlaces ? () => context.push(AppRoutePaths.plantSearch) : null,
      );
    }

    return SizedBox(
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
    );
  }
}

class _HomeListStatus extends StatelessWidget {
  const _HomeListStatus({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _HomeListError extends StatelessWidget {
  const _HomeListError({
    required this.height,
    required this.message,
    required this.onRetry,
  });

  final double height;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _HomeListStatus(
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
          CommonButton.text(
            label: '다시 시도',
            onPressed: onRetry,
            size: CommonButtonSize.medium,
            foregroundColor: AppColors.brandStrong,
          ),
        ],
      ),
    );
  }
}
