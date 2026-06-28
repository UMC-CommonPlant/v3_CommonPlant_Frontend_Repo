import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class MemoListContent extends StatelessWidget {
  const MemoListContent({
    super.key,
    required this.memos,
    required this.onOpenMenu,
  });

  final List<MemoItem> memos;
  final void Function(MemoItem memo, BuildContext anchorContext) onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.x32),
          for (final memo in memos) ...[
            _MemoFeedItem(
              memo: memo,
              onOpenMenu: (anchorContext) => onOpenMenu(memo, anchorContext),
            ),
            if (memo != memos.last)
              const ColoredBox(
                color: AppColors.surfaceDisabled,
                child: SizedBox(width: double.infinity, height: AppSpacing.x8),
              ),
          ],
        ],
      ),
    );
  }
}

class _MemoFeedItem extends StatelessWidget {
  const _MemoFeedItem({required this.memo, required this.onOpenMenu});

  final MemoItem memo;
  final ValueChanged<BuildContext> onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        0,
        AppSpacing.x20,
        AppSpacing.x20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _MemoAvatar(asset: memo.avatarAsset),
              const SizedBox(width: AppSpacing.x8),
              Expanded(
                child: Text(
                  memo.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.size16Medium.copyWith(
                    color: AppColors.textStrong,
                  ),
                ),
              ),
              Builder(
                builder: (anchorContext) {
                  return Semantics(
                    button: true,
                    label: '메모 메뉴 열기: ${memo.author}',
                    child: ExcludeSemantics(
                      child: IconButton(
                        tooltip: '메모 메뉴 열기',
                        onPressed: () => onOpenMenu(anchorContext),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: AppSizes.iconButtonSize,
                          height: AppSizes.iconButtonSize,
                        ),
                        icon: const Icon(
                          Icons.more_horiz,
                          color: AppColors.textStrong,
                          size: AppSizes.iconMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (memo.imageAsset case final imageAsset?) ...[
            const SizedBox(height: AppSpacing.x12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: AspectRatio(
                aspectRatio: 335 / 207,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  alignment: memo.imageAlignment,
                  semanticLabel: '${memo.author} 메모 사진',
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.x12),
          Text(
            memo.content,
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              memo.dateLabel,
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.iconInactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoAvatar extends StatelessWidget {
  const _MemoAvatar({this.asset});

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.square(
        dimension: AppSizes.memoAvatarSize,
        child: asset == null
            ? const ColoredBox(
                color: AppColors.borderDefault,
                child: Center(
                  child: CommonSvgIcon(
                    AppIconAssets.userIllustration,
                    width: AppSizes.iconMedium,
                    height: AppSizes.iconMedium,
                    color: AppColors.white,
                    semanticsLabel: '기본 프로필 이미지',
                  ),
                ),
              )
            : Image.asset(asset!, fit: BoxFit.cover),
      ),
    );
  }
}
