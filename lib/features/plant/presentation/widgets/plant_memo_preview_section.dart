import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/plant/presentation/widgets/plant_detail_content_width.dart';
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
        const PlantDetailSectionDivider(),
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
