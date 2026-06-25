import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_memo_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlantDetailMemoItem {
  const PlantDetailMemoItem({
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

class PlantDetailContentWidth extends StatelessWidget {
  const PlantDetailContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
        child: child,
      ),
    );
  }
}

class PlantHero extends StatelessWidget {
  const PlantHero({
    super.key,
    required this.placeName,
    required this.name,
    required this.species,
  });

  final String placeName;
  final String name;
  final String species;

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
          _PlantHeroImage(placeName: placeName),
          const SizedBox(height: AppSpacing.x8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            species,
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

class PlantCareSummary extends StatelessWidget {
  const PlantCareSummary({
    super.key,
    required this.name,
    required this.daysTogether,
    required this.dDayLabel,
    required this.startDate,
    required this.lastWateredDate,
  });

  final String name;
  final int daysTogether;
  final String dDayLabel;
  final String startDate;
  final String lastWateredDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionDivider(),
        PlantDetailContentWidth(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.x24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.size16Medium.copyWith(
                    color: AppColors.textBody,
                  ),
                  children: [
                    TextSpan(text: '$name와 함께한지 '),
                    TextSpan(
                      text: '$daysTogether일',
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
                    dDayLabel,
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
                startDate: startDate,
                lastWateredDate: lastWateredDate,
              ),
              const SizedBox(height: AppSpacing.x24),
            ],
          ),
        ),
      ],
    );
  }
}

class MemoPreviewSection extends StatelessWidget {
  const MemoPreviewSection({
    super.key,
    required this.plantId,
    required this.memos,
  });

  final String plantId;
  final List<PlantDetailMemoItem> memos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionDivider(),
        PlantDetailContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MemoSectionHeader(
                onPressed: () =>
                    context.push(AppRoutePaths.memoListLocation(plantId)),
              ),
              SizedBox(
                height: AppSizes.memoCardHeight,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      _PlantMemoCard(memo: memos[index]),
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.x8),
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
          ),
        ),
      ],
    );
  }
}

class PlantInfoSection extends StatelessWidget {
  const PlantInfoSection({super.key, required this.wateringCycleLabel});

  final String wateringCycleLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionDivider(),
        PlantDetailContentWidth(
          child: Padding(
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
                            wateringCycleLabel,
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
        ),
      ],
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

  final PlantDetailMemoItem memo;

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

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: ValueKey('plant-detail-section-divider'),
      height: AppSpacing.x8,
      width: double.infinity,
      child: ColoredBox(color: AppColors.surfaceDisabled),
    );
  }
}
