import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';
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

class PlantDetailPage extends ConsumerWidget {
  const PlantDetailPage({super.key, required this.plantId, this.placeId});

  final String plantId;
  final String? placeId;

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String? placeCode,
  ) {
    final isDeleting = ref.read(plantDeleteControllerProvider).isSubmitting;

    unawaited(
      showPlantDeleteDialog(
        context: context,
        isDeleting: isDeleting,
        onConfirm: () => _handleDeleteConfirmed(context, ref, placeCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (plantId: plantId, placeCode: placeId);
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

        return _buildScaffold(context, ref, detail);
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
        message: '식물 상세 정보를 준비하고 있어요',
        isLoading: true,
      ),
    );
  }

  void _handleDeleteConfirmed(
    BuildContext context,
    WidgetRef ref,
    String? placeCode,
  ) {
    Navigator.of(context).pop();
    unawaited(_handleDeleteResult(context, ref, placeCode));
  }

  Future<void> _handleDeleteResult(
    BuildContext context,
    WidgetRef ref,
    String? placeCode,
  ) async {
    final result = await ref
        .read(plantDeleteControllerProvider.notifier)
        .delete(plantId: plantId, placeCode: placeCode);

    if (!context.mounted) {
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

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    PlantDetailViewData detail,
  ) {
    return CommonScaffold(
      title: 'My plant',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      trailing: PlantDetailMenuButton(
        onEdit: () {
          context.push(
            AppRoutePaths.plantEditLocation(plantId, placeId: detail.placeCode),
          );
        },
        onDelete: () => _showDeleteDialog(context, ref, detail.placeCode),
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
                imageUrl: detail.imageUrl,
                imageAsset: detail.imageAsset,
              ),
            ),
            PlantCareSummary(
              name: detail.name,
              daysTogether: detail.daysTogether,
              dDayLabel: detail.dDayLabel,
              startDate: detail.startDate,
              lastWateredDate: detail.lastWateredDate,
            ),
            MemoPreviewSection(
              plantId: plantId,
              memos: detail.memos,
              representativeMemo: detail.representativeMemo,
              supportsActions: detail.supportsMemoActions,
            ),
            PlantInfoSection(
              wateringCycleLabel: detail.wateringCycleLabel,
              plantInfo: detail.plantInfo,
            ),
            const SizedBox(height: 82),
          ],
        ),
      ),
    );
  }
}
