import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlantSearchPage extends StatefulWidget {
  const PlantSearchPage({super.key});

  @override
  State<PlantSearchPage> createState() => _PlantSearchPageState();
}

class _PlantSearchPageState extends State<PlantSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  static const List<_PlantCandidate> _plants = [
    _PlantCandidate(name: '몬스테라 델리오사'),
    _PlantCandidate(name: '몬스테라 알보 바리에가타'),
    _PlantCandidate(name: '몬스테라 보르시지아나'),
    _PlantCandidate(name: '무늬 몬스테라'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _matchingPlants(_searchController.text);

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
              controller: _searchController,
              hintText: '식물을 입력해 주세요.',
              horizontalPadding: AppSpacing.x20,
              iconTextSpacing: AppSpacing.x12,
              onChanged: (_) => setState(() {}),
            ),
            if (results.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.x8),
              _PlantSearchResultList(
                plants: results,
                onSelected: (plant) => context.push(
                  Uri(
                    path: AppRoutePaths.plantCreateDetails,
                    queryParameters: {'name': plant.name},
                  ).toString(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_PlantCandidate> _matchingPlants(String value) {
    final query = _normalize(value);

    if (query.isEmpty) {
      return const [];
    }

    return _plants
        .where((plant) => _normalize(plant.name).contains(query))
        .toList(growable: false);
  }

  String _normalize(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }
}

class _PlantSearchResultList extends StatelessWidget {
  const _PlantSearchResultList({
    required this.plants,
    required this.onSelected,
  });

  final List<_PlantCandidate> plants;
  final ValueChanged<_PlantCandidate> onSelected;

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

  final _PlantCandidate plant;
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

class _PlantCandidate {
  const _PlantCandidate({required this.name});

  final String name;
}
