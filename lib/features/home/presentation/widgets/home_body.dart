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
import 'package:commonplant_frontend/shared/widgets/common_content_width.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _homeSectionContentGap = 26;

class HomeBody extends ConsumerWidget {
  const HomeBody({
    super.key,
    this.header,
    this.headerHeight = 0,
    this.headerMinHeight = 0,
    this.collapseHeader = false,
  });

  final Widget? header;
  final double headerHeight;
  final double headerMinHeight;
  final bool collapseHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placeSummariesProvider);
    final plantsAsync = ref.watch(plantSummariesProvider);
    final invitationCountAsync = ref.watch(placeInvitationRequestCountProvider);
    final isLoading = placesAsync.isLoading || plantsAsync.isLoading;
    final hasError = placesAsync.hasError || plantsAsync.hasError;
    final places = placesAsync.value ?? const [];
    final plants = plantsAsync.value ?? const [];

    return CustomScrollView(
      key: const PageStorageKey('home-scroll'),
      slivers: [
        if (header != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _HomeHeaderDelegate(
              height: headerHeight,
              minimumHeight: headerMinHeight,
              collapsible: collapseHeader,
              child: header!,
            ),
          ),
        if (isLoading || hasError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _HomeStatusBody(
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.brandPrimary,
                    )
                  : Text(
                      '데이터를 불러오지 못했어요',
                      style: AppTextStyles.size16Medium.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x20,
              AppSpacing.x24,
              AppSpacing.x20,
              120,
            ),
            sliver: SliverToBoxAdapter(
              child: CommonContentWidth(
                maxWidth: AppSizes.contentMaxWidth,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final expanded =
                        constraints.maxWidth >=
                        AppSizes.expandedLayoutMinWidth - AppSpacing.x40;
                    final placeCards = <Widget>[
                      for (final place in places)
                        CommonPlaceCard(
                          title: place.name,
                          imageProvider: place.imageUrl == null
                              ? null
                              : NetworkImage(place.imageUrl!),
                          onTap: () => context.push(
                            AppRoutePaths.placeDetailLocation(place.id),
                          ),
                        ),
                      if (places.isEmpty)
                        HomeAddTile(
                          label: '장소 추가하기',
                          width: AppSizes.placeAddTileWidth,
                          height: AppSizes.placeAddTileHeight,
                          borderColor: AppColors.brandStrong,
                          foregroundColor: AppColors.brandPrimary,
                          iconAsset: AppIconAssets.plusGreen,
                          onTap: () => context.push(AppRoutePaths.placeCreate),
                        ),
                    ];
                    final plantCards = <Widget>[
                      for (final plant in plants)
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
                      if (plants.isEmpty)
                        HomeAddTile(
                          label: '식물 추가하기',
                          width: AppSizes.plantAddTileWidth,
                          height: AppSizes.plantAddTileHeight,
                          borderColor: places.isNotEmpty
                              ? AppColors.brandStrong
                              : AppColors.textDisabled,
                          foregroundColor: places.isNotEmpty
                              ? AppColors.brandPrimary
                              : AppColors.textDisabled,
                          backgroundColor: places.isNotEmpty
                              ? AppColors.white
                              : AppColors.surfaceDisabled,
                          iconAsset: places.isNotEmpty
                              ? AppIconAssets.plusGreen
                              : AppIconAssets.plusGray,
                          onTap: places.isNotEmpty
                              ? () => context.push(AppRoutePaths.plantSearch)
                              : null,
                        ),
                    ];
                    return Flex(
                      key: const ValueKey('home-sections-layout'),
                      direction: expanded ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: expanded ? 1 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: expanded
                                    ? AppSizes.smallButtonHeight
                                    : null,
                                child: HomeSectionHeader(
                                  title: 'My place',
                                  addSemanticsLabel: '장소 추가',
                                  action: invitationCountAsync.when(
                                    skipLoadingOnRefresh: false,
                                    data: (count) => HomePlaceRequestButton(
                                      count: count,
                                      onPressed: () => context.push(
                                        AppRoutePaths.placeInvitations,
                                      ),
                                    ),
                                    loading: HomePlaceRequestButton.loading,
                                    error: (_, _) =>
                                        HomePlaceRequestButton.error(
                                          onRetry: () => ref.invalidate(
                                            remotePlaceInvitationsProvider,
                                          ),
                                        ),
                                  ),
                                  onAddPressed: places.isNotEmpty
                                      ? () => context.push(
                                          AppRoutePaths.placeCreate,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: _homeSectionContentGap),
                              _HomeCards(
                                storageKey: 'home-places',
                                expanded: expanded,
                                height: AppSizes.placeCardHeight,
                                children: placeCards,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: expanded ? AppSpacing.x32 : 0,
                          height: expanded ? 0 : AppSpacing.x32,
                        ),
                        Flexible(
                          flex: expanded ? 1 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: expanded
                                    ? AppSizes.smallButtonHeight
                                    : null,
                                child: HomeSectionHeader(
                                  title: 'My plant',
                                  addSemanticsLabel: '식물 추가',
                                  onAddPressed: plants.isNotEmpty
                                      ? () => context.push(
                                          AppRoutePaths.plantSearch,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: _homeSectionContentGap),
                              _HomeCards(
                                storageKey: 'home-plants',
                                expanded: expanded,
                                height: AppSizes.plantCardHeight,
                                children: plantCards,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeCards extends StatelessWidget {
  const _HomeCards({
    required this.storageKey,
    required this.expanded,
    required this.height,
    required this.children,
  });

  final String storageKey;
  final bool expanded;
  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Wrap(
        spacing: AppSpacing.x12,
        runSpacing: AppSpacing.x12,
        children: children,
      );
    }
    return SizedBox(
      height: height,
      child: ListView.separated(
        key: PageStorageKey(storageKey),
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.x12),
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.height,
    required this.minimumHeight,
    required this.collapsible,
    required this.child,
  });

  final double height;
  final double minimumHeight;
  final bool collapsible;
  final Widget child;

  @override
  double get minExtent => collapsible ? minimumHeight : height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: height,
        maxHeight: height,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_HomeHeaderDelegate oldDelegate) =>
      height != oldDelegate.height ||
      minimumHeight != oldDelegate.minimumHeight ||
      collapsible != oldDelegate.collapsible ||
      child != oldDelegate.child;
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
