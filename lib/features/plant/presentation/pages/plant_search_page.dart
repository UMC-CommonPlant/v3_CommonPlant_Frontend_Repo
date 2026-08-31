import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_candidate.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_search_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlantSearchPage extends ConsumerWidget {
  const PlantSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(plantSearchControllerProvider);

    if (!searchState.isAvailable) {
      return CommonScaffold(
        title: '식물 등록  (1/2)',
        child: Text(
          '식물 검색 서비스가 아직 연결되지 않았어요.\n연결 전에는 새 식물을 선택할 수 없어요.',
          style: AppTextStyles.size16Medium.copyWith(color: AppColors.textBody),
        ),
      );
    }

    return CommonScaffold(
      title: '식물 등록  (1/2)',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonSearchTextField(
              hintText: '식물을 입력해 주세요.',
              horizontalPadding: AppSpacing.x20,
              iconTextSpacing: AppSpacing.x12,
              onChanged: ref
                  .read(plantSearchControllerProvider.notifier)
                  .updateQuery,
            ),
            if (searchState.results.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.x8),
              _PlantSearchResultList(
                plants: searchState.results,
                onSelected: (plant) => context.push(
                  Uri(
                    path: AppRoutePaths.plantCreateDetails,
                    queryParameters: {'name': plant.name},
                  ).toString(),
                ),
              ),
            ] else if (searchState.hasQuery)
              const _PlantSearchEmptyState(),
          ],
        ),
      ),
    );
  }
}

class _PlantSearchResultList extends StatelessWidget {
  const _PlantSearchResultList({
    required this.plants,
    required this.onSelected,
  });

  final List<PlantCandidate> plants;
  final ValueChanged<PlantCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in plants.indexed)
          _PlantSearchResultTile(
            plant: entry.$2,
            isHighlighted: entry.$1 == 0,
            onTap: () => onSelected(entry.$2),
          ),
      ],
    );
  }
}

class _PlantSearchResultTile extends StatelessWidget {
  const _PlantSearchResultTile({
    required this.plant,
    required this.isHighlighted,
    required this.onTap,
  });

  final PlantCandidate plant;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isHighlighted ? AppColors.surfaceDisabled : AppColors.surfaceBase,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: AppSizes.plantSearchResultTileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                plant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.size16Bold.copyWith(
                  color: AppColors.textHeadline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantSearchEmptyState extends StatelessWidget {
  const _PlantSearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x40,
        AppSpacing.x20,
        0,
      ),
      child: Column(
        children: [
          Text(
            '검색 결과가 없어요',
            textAlign: TextAlign.center,
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          Text(
            '다른 이름으로 다시 검색해 주세요',
            textAlign: TextAlign.center,
            style: AppTextStyles.size14Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
