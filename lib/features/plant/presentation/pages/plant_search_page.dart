import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_add_tile.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
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
    _PlantCandidate(name: '몬스테라', species: 'Monstera deliciosa'),
    _PlantCandidate(name: '스투키', species: 'Sansevieria stuckyi'),
    _PlantCandidate(name: '아레카야자', species: 'Dypsis lutescens'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = query.isEmpty
        ? _plants
        : _plants
              .where(
                (plant) =>
                    plant.name.contains(query) || plant.species.contains(query),
              )
              .toList();

    return CommonScaffold(
      title: '식물 등록',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonSearchTextField(
            controller: _searchController,
            hintText: '식물을 입력해 주세요.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          Phase0Section(
            title: '식물 선택',
            subtitle: '등록할 식물을 검색하거나 직접 입력할 수 있어요.',
            child: Column(
              children: [
                for (final plant in results) ...[
                  Phase0Surface(
                    onTap: () => context.push(AppRoutePaths.plantCreateDetails),
                    child: Row(
                      children: [
                        const CommonSvgIcon(
                          AppIconAssets.plantEmpty,
                          height: 56,
                          semanticsLabel: '식물',
                        ),
                        const SizedBox(width: AppSpacing.x16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.name,
                                style: AppTextStyles.size16Bold.copyWith(
                                  color: AppColors.textStrong,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.x4),
                              Text(
                                plant.species,
                                style: AppTextStyles.size14Medium.copyWith(
                                  color: AppColors.textBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textStrong,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x12),
                ],
                CommonAddTile(
                  label: '직접 입력하기',
                  helper: '검색 결과에 없는 식물을 등록해요.',
                  icon: const CommonSvgIcon(
                    AppIconAssets.plusGreen,
                    width: 24,
                    height: 24,
                    semanticsLabel: '직접 입력',
                  ),
                  onTap: () => context.push(AppRoutePaths.plantCreateDetails),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantCandidate {
  const _PlantCandidate({required this.name, required this.species});

  final String name;
  final String species;
}
