import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_delete_controller.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_widgets.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_state_view.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
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
  void _showPlantMenu(BuildContext context, String? placeCode) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '식물 상세 메뉴 닫기',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                top:
                    MediaQuery.paddingOf(dialogContext).top +
                    AppSizes.navigationBarHeight +
                    AppSpacing.x8,
                right: AppSpacing.x20,
                child: CommonEditDeletePopup(
                  onEdit: () {
                    Navigator.of(dialogContext).pop();
                    context.push(
                      AppRoutePaths.plantEditLocation(
                        widget.plantId,
                        placeId: placeCode,
                      ),
                    );
                  },
                  onDelete: () {
                    Navigator.of(dialogContext).pop();
                    _showDeleteDialog(context, placeCode);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String? placeCode) {
    final isDeleting = ref.read(plantDeleteControllerProvider).isSubmitting;

    showCommonDialog<void>(
      context: context,
      child: CommonDialogCard(
        title: '식물을 삭제할까요?',
        message: '삭제하면 기록된 메모도 함께 사라져요.',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            foregroundColor: AppColors.textBody,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CommonDialogActionButton.confirm(
            label: '삭제',
            foregroundColor: AppColors.danger,
            onPressed: isDeleting
                ? null
                : () => _confirmDelete(context, placeCode),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockDetail = _PlantDetailData.mock(placeCode: widget.placeId);

    if (!ref.watch(useRemoteApiProvider)) {
      return _buildScaffold(context, mockDetail);
    }

    final remoteDetail = ref.watch(remotePlantDetailProvider(widget.plantId));

    return remoteDetail.when(
      data: (detail) {
        if (_isEmptyRemoteDetail(detail)) {
          return const PlantStateScaffold(
            title: 'My plant',
            statusTitle: '식물 정보를 찾을 수 없어요',
            message: '다시 식물 목록에서 선택해 주세요',
          );
        }

        return _buildScaffold(context, mockDetail.applyRemote(detail));
      },
      error: (error, stackTrace) => PlantStateScaffold(
        title: 'My plant',
        statusTitle: '식물 정보를 불러오지 못했어요',
        message: '잠시 후 다시 시도해 주세요',
        actionLabel: '다시 시도',
        onAction: () =>
            ref.invalidate(remotePlantDetailProvider(widget.plantId)),
      ),
      loading: () => const PlantStateScaffold(
        title: 'My plant',
        statusTitle: '식물 정보를 불러오고 있어요',
        message: '식물과 메모 정보를 준비하고 있어요',
        isLoading: true,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String? placeCode) {
    Navigator.of(context).pop();
    unawaited(_deletePlant(context, placeCode));
  }

  Future<void> _deletePlant(BuildContext context, String? placeCode) async {
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

  Widget _buildScaffold(BuildContext context, _PlantDetailData detail) {
    return CommonScaffold(
      title: 'My plant',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      trailing: _PlantDetailMenuButton(
        onPressed: () => _showPlantMenu(context, detail.placeCode),
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

  bool _isEmptyRemoteDetail(PlantDetail detail) {
    return detail.name.trim().isEmpty;
  }
}

class _PlantDetailData {
  const _PlantDetailData({
    required this.placeCode,
    required this.placeName,
    required this.name,
    required this.species,
    required this.daysTogether,
    required this.dDayLabel,
    required this.startDate,
    required this.lastWateredDate,
    required this.wateringCycleLabel,
    required this.memos,
  });

  final String? placeCode;
  final String placeName;
  final String name;
  final String species;
  final int daysTogether;
  final String dDayLabel;
  final String startDate;
  final String lastWateredDate;
  final String wateringCycleLabel;
  final List<PlantDetailMemoItem> memos;

  _PlantDetailData applyRemote(PlantDetail detail) {
    return _PlantDetailData(
      placeCode: detail.placeId ?? placeCode,
      placeName: detail.placeName ?? placeName,
      name: detail.name,
      species: detail.species ?? species,
      daysTogether: daysTogether,
      dDayLabel: dDayLabel,
      startDate: startDate,
      lastWateredDate: detail.lastWateredDate ?? lastWateredDate,
      wateringCycleLabel: wateringCycleLabel,
      memos: memos,
    );
  }

  static _PlantDetailData mock({String? placeCode}) {
    return _PlantDetailData(
      placeCode: placeCode,
      placeName: '스윗홈_거실',
      name: '몬테',
      species: 'Monstera deliciosa',
      daysTogether: 1,
      dDayLabel: 'D-3',
      startDate: '2022.11.24',
      lastWateredDate: '2022.11.24',
      wateringCycleLabel: '10 Day',
      memos: const [
        PlantDetailMemoItem(
          author: '커먼플랜트',
          content: '장마여서 물주는 날짜를 조금 늦춤 하지만 해는 맑구나 몬테랑 함께...',
          dateLabel: '2022.11.20',
          avatarAsset: AppImageAssets.placeDetailAvatarMe,
          thumbnailAsset: AppImageAssets.placeDetailMonstera,
        ),
        PlantDetailMemoItem(
          author: '커먼맘',
          content: '오늘은 잎이 조금 시들하구나 커먼아 해결책은?',
          dateLabel: '2022.11.20',
          avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
        ),
        PlantDetailMemoItem(
          author: '커먼맘',
          content: '오늘은 잎의 상태가 매우 좋다 커먼아 앱에서 알려준 물주기의 주기...',
          dateLabel: '2022.11.20',
          avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
          thumbnailAsset: AppImageAssets.plantEditMonstera,
        ),
        PlantDetailMemoItem(
          author: '커먼 파파',
          content: '오늘도 맑음',
          dateLabel: '2022.11.20',
        ),
      ],
    );
  }
}

class _PlantDetailMenuButton extends StatelessWidget {
  const _PlantDetailMenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '식물 상세 메뉴',
      child: ExcludeSemantics(
        child: IconButton(
          tooltip: '식물 상세 메뉴',
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: AppSizes.navigationBarSideWidth,
            height: AppSizes.navigationBarHeight,
          ),
          icon: const CommonSvgIcon(
            AppIconAssets.shape,
            width: 4,
            height: 20,
            color: AppColors.textStrong,
          ),
        ),
      ),
    );
  }
}
