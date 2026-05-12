import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_memo_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage({super.key, required this.plantId});

  final String plantId;

  void _showPlantMenu(BuildContext context) {
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
                top: MediaQuery.paddingOf(dialogContext).top + 92,
                right: AppSpacing.x20,
                child: CommonEditDeletePopup(
                  onEdit: () {
                    Navigator.of(dialogContext).pop();
                    context.push(AppRoutePaths.plantEditLocation(plantId));
                  },
                  onDelete: () {
                    Navigator.of(dialogContext).pop();
                    _showDeleteDialog(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _PlantDetailData.mock();

    return CommonScaffold(
      title: 'My plant',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
            child: Column(
              children: [
                _PlantDetailMenuRow(onPressed: () => _showPlantMenu(context)),
                _PlantHero(detail: detail),
                _PlantCareSummary(detail: detail),
                _MemoPreviewSection(plantId: plantId, memos: detail.memos),
                _PlantInfoSection(detail: detail),
                const SizedBox(height: 82),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantDetailData {
  const _PlantDetailData({
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

  final String placeName;
  final String name;
  final String species;
  final int daysTogether;
  final String dDayLabel;
  final String startDate;
  final String lastWateredDate;
  final String wateringCycleLabel;
  final List<_PlantMemo> memos;

  static _PlantDetailData mock() {
    return const _PlantDetailData(
      placeName: '스윗홈_거실',
      name: '몬테',
      species: 'Monstera deliciosa',
      daysTogether: 1,
      dDayLabel: 'D-3',
      startDate: '2022.11.24',
      lastWateredDate: '2022.11.24',
      wateringCycleLabel: '10 Day',
      memos: [
        _PlantMemo(
          author: '커먼플랜트',
          content: '장마여서 물주는 날짜를 조금 늦춤 하지만 해는 맑구나 몬테랑 함께...',
          dateLabel: '2022.11.20',
          avatarAsset: AppImageAssets.placeDetailAvatarMe,
          thumbnailAsset: AppImageAssets.placeDetailMonstera,
        ),
        _PlantMemo(
          author: '커먼맘',
          content: '오늘은 잎이 조금 시들하구나 커먼아 해결책은?',
          dateLabel: '2022.11.20',
          avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
        ),
        _PlantMemo(
          author: '커먼맘',
          content: '오늘은 잎의 상태가 매우 좋다 커먼아 앱에서 알려준 물주기의 주기...',
          dateLabel: '2022.11.20',
          avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
          thumbnailAsset: AppImageAssets.plantEditMonstera,
        ),
        _PlantMemo(author: '커먼 파파', content: '오늘도 맑음', dateLabel: '2022.11.20'),
      ],
    );
  }
}

class _PlantMemo {
  const _PlantMemo({
    required this.author,
    required this.content,
    required this.dateLabel,
    this.avatarAsset,
    this.thumbnailAsset,
  });

  final String author;
  final String content;
  final String dateLabel;
  final String? avatarAsset;
  final String? thumbnailAsset;
}

class _PlantDetailMenuRow extends StatelessWidget {
  const _PlantDetailMenuRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.x20),
          child: Semantics(
            button: true,
            label: '식물 상세 메뉴',
            child: ExcludeSemantics(
              child: IconButton(
                onPressed: onPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: const CommonSvgIcon(
                  AppIconAssets.shape,
                  width: 4,
                  height: 20,
                  color: AppColors.textStrong,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantHero extends StatelessWidget {
  const _PlantHero({required this.detail});

  final _PlantDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        0,
        AppSpacing.x20,
        AppSpacing.x16,
      ),
      child: Column(
        children: [
          _PlantHeroImage(placeName: detail.placeName),
          const SizedBox(height: AppSpacing.x8),
          Text(
            detail.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            detail.species,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantHeroImage extends StatelessWidget {
  const _PlantHeroImage({required this.placeName});

  final String placeName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 335 ? constraints.maxWidth : 335.0;
        final scale = width / 335;
        final height = 208 * scale;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.surfaceMuted),
                Positioned(
                  left: 0,
                  top: -126 * scale,
                  child: Image.asset(
                    AppImageAssets.plantEditMonstera,
                    width: 495 * scale,
                    height: 369 * scale,
                    fit: BoxFit.cover,
                    semanticLabel: '몬테 식물 사진',
                  ),
                ),
                Positioned(
                  top: AppSpacing.x8 * scale,
                  left: 0,
                  right: 0,
                  child: Center(child: _PlaceBadge(label: placeName)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlaceBadge extends StatelessWidget {
  const _PlaceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandStrong,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x10,
            AppSpacing.x4,
            AppSpacing.x16,
            AppSpacing.x4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_home_outlined,
                color: AppColors.onBrand,
                size: AppSizes.iconMedium,
              ),
              const SizedBox(width: AppSpacing.x4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.size14Bold.copyWith(
                    color: AppColors.onBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantCareSummary extends StatelessWidget {
  const _PlantCareSummary({required this.detail});

  final _PlantDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionDivider(),
        const SizedBox(height: AppSpacing.x24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textBody,
            ),
            children: [
              TextSpan(text: '${detail.name}와 함께한지 '),
              TextSpan(
                text: '${detail.daysTogether}일',
                style: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: '이 지났어요!'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CommonSvgIcon(
              AppIconAssets.watering,
              width: 32,
              height: 25,
              color: AppColors.brandAccent,
              semanticsLabel: '물주기',
            ),
            const SizedBox(width: AppSpacing.x8),
            Text(
              detail.dDayLabel,
              style: AppTextStyles.size24Medium.copyWith(
                fontSize: 28,
                height: 36 / 28,
                color: AppColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x12),
        _PlantDateSummary(
          startDate: detail.startDate,
          lastWateredDate: detail.lastWateredDate,
        ),
        const SizedBox(height: AppSpacing.x24),
      ],
    );
  }
}

class _PlantDateSummary extends StatelessWidget {
  const _PlantDateSummary({
    required this.startDate,
    required this.lastWateredDate,
  });

  final String startDate;
  final String lastWateredDate;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.size14Medium.copyWith(
      color: AppColors.iconInactive,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('처음 함께한 날', style: textStyle),
            Text('마지막으로 물 준 날짜', style: textStyle),
          ],
        ),
        const SizedBox(width: 34),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startDate, style: textStyle),
            Text(lastWateredDate, style: textStyle),
          ],
        ),
      ],
    );
  }
}

class _MemoPreviewSection extends StatelessWidget {
  const _MemoPreviewSection({required this.plantId, required this.memos});

  final String plantId;
  final List<_PlantMemo> memos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionDivider(),
        _MemoSectionHeader(
          onPressed: () =>
              context.push(AppRoutePaths.memoListLocation(plantId)),
        ),
        SizedBox(
          height: AppSizes.memoCardHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _PlantMemoCard(memo: memos[index]),
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.x8),
            itemCount: memos.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x20,
            AppSpacing.x16,
            AppSpacing.x20,
            AppSpacing.x24,
          ),
          child: CommonButton(
            label: '작성하기',
            size: CommonButtonSize.medium,
            onPressed: () =>
                context.push(AppRoutePaths.memoWriteLocation(plantId)),
          ),
        ),
      ],
    );
  }
}

class _MemoSectionHeader extends StatelessWidget {
  const _MemoSectionHeader({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x4,
        AppSpacing.x20,
        AppSpacing.x4,
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.x10),
            Expanded(
              child: Text(
                'Memo',
                style: AppTextStyles.size18Medium.copyWith(
                  color: AppColors.iconInactive,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: '메모 전체보기',
              child: ExcludeSemantics(
                child: IconButton(
                  onPressed: onPressed,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textStrong,
                    size: AppSizes.iconMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantMemoCard extends StatelessWidget {
  const _PlantMemoCard({required this.memo});

  final _PlantMemo memo;

  @override
  Widget build(BuildContext context) {
    return CommonMemoCard(
      author: memo.author,
      content: memo.content,
      dateLabel: memo.dateLabel,
      avatar: memo.avatarAsset == null
          ? const _EmptyAvatar()
          : Image.asset(memo.avatarAsset!, fit: BoxFit.cover),
      thumbnail: memo.thumbnailAsset == null
          ? const _EmptyThumbnail()
          : Image.asset(memo.thumbnailAsset!, fit: BoxFit.cover),
    );
  }
}

class _EmptyAvatar extends StatelessWidget {
  const _EmptyAvatar();

  @override
  Widget build(BuildContext context) {
    return const CommonSvgIcon(
      AppIconAssets.plantEmpty,
      fit: BoxFit.cover,
      semanticsLabel: '기본 프로필 이미지',
    );
  }
}

class _EmptyThumbnail extends StatelessWidget {
  const _EmptyThumbnail();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.white),
      child: SizedBox.expand(),
    );
  }
}

class _PlantInfoSection extends StatelessWidget {
  const _PlantInfoSection({required this.detail});

  final _PlantDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.x10),
                    child: Text(
                      '식물정보',
                      style: AppTextStyles.size18Medium.copyWith(
                        color: AppColors.iconInactive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FBF9),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x16),
                    child: Row(
                      children: [
                        const CommonSvgIcon(
                          AppIconAssets.watering,
                          width: 24,
                          height: 24,
                          semanticsLabel: '물주기 주기',
                        ),
                        const SizedBox(width: AppSpacing.x8),
                        Text(
                          detail.wateringCycleLabel,
                          style: AppTextStyles.size14Medium.copyWith(
                            color: AppColors.textStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppSpacing.x8,
      width: double.infinity,
      child: ColoredBox(color: AppColors.surfaceDisabled),
    );
  }
}
