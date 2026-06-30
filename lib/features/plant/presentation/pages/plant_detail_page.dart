import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_delete_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_view_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_care_summary.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_delete_dialog.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_content_width.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_menu_button.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_hero.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_info_section.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_memo_preview_section.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_state_view.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlantDetailPage extends ConsumerStatefulWidget {
  const PlantDetailPage({super.key, required this.plantId, this.placeId});

  final String plantId;
  final String? placeId;

  @override
  ConsumerState<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends ConsumerState<PlantDetailPage> {
  void _showDeleteDialog(BuildContext context, String? placeCode) {
    final isDeleting = ref.read(plantDeleteControllerProvider).isSubmitting;

    unawaited(
      showPlantDeleteDialog(
        context: context,
        isDeleting: isDeleting,
        onConfirm: () => _handleDeleteConfirmed(context, placeCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = (plantId: widget.plantId, placeCode: widget.placeId);
    final detailState = ref.watch(plantDetailViewProvider(request));

    return detailState.when(
      data: (detail) {
        if (detail == null) {
          return const PlantStateScaffold(
            title: 'My plant',
            statusTitle: '식물 정보를 찾을 수 없어요',
            message: '다시 식물 목록에서 선택해 주세요',
          );
        }

        return _buildScaffold(context, detail);
      },
      error: (error, stackTrace) => PlantStateScaffold(
        title: 'My plant',
        statusTitle: '식물 정보를 불러오지 못했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () => invalidatePlantDetailView(ref, request),
      ),
      loading: () => const PlantStateScaffold(
        title: 'My plant',
        statusTitle: '식물 정보를 불러오고 있어요',
        message: '식물과 메모 정보를 준비하고 있어요',
        isLoading: true,
      ),
    );
  }

  void _handleDeleteConfirmed(BuildContext context, String? placeCode) {
    Navigator.of(context).pop();
    unawaited(_handleDeleteResult(context, placeCode));
  }

  Future<void> _handleDeleteResult(
    BuildContext context,
    String? placeCode,
  ) async {
    final result = await ref
        .read(plantDeleteControllerProvider.notifier)
        .delete(plantId: widget.plantId, placeCode: placeCode);

    if (!mounted || !context.mounted) {
      return;
    }

    if (result?.destination == PlantDeleteDestination.home) {
      context.go(AppRoutePaths.home);
      return;
    }

    final errorMessage = ref.read(plantDeleteControllerProvider).errorMessage;

    if (errorMessage == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Widget _buildScaffold(BuildContext context, PlantDetailFixtureData detail) {
    return CommonScaffold(
      title: 'My plant',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      trailing: PlantDetailMenuButton(
        onEdit: () {
          context.push(
            AppRoutePaths.plantEditLocation(
              widget.plantId,
              placeId: detail.placeCode,
            ),
          );
        },
        onDelete: () => _showDeleteDialog(context, detail.placeCode),
      ),
      bodyPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlantDetailContentWidth(
              child: PlantHero(
                placeName: detail.placeName,
                name: detail.name,
                species: detail.species,
              ),
            ),
            PlantCareSummary(
              name: detail.name,
              daysTogether: detail.daysTogether,
              dDayLabel: detail.dDayLabel,
              startDate: detail.startDate,
              lastWateredDate: detail.lastWateredDate,
            ),
            MemoPreviewSection(plantId: widget.plantId, memos: detail.memos),
            PlantInfoSection(wateringCycleLabel: detail.wateringCycleLabel),
            const SizedBox(height: 82),
          ],
        ),
      ),
    );
  }
}
