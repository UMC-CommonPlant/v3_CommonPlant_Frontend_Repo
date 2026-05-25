import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MemoListPage extends ConsumerWidget {
  const MemoListPage({super.key, required this.plantId});

  final String plantId;

  static const double _writeActionWidth = AppSpacing.x20 * 4;
  static const double _actionPopupTopAdjustment = 50;

  void _openWritePage(BuildContext context) {
    context.push(AppRoutePaths.memoWriteLocation(plantId));
  }

  void _showActionPopup({
    required BuildContext context,
    required WidgetRef ref,
    required MemoItem memo,
    required BuildContext anchorContext,
  }) {
    final anchorRenderObject = anchorContext.findRenderObject();
    final overlayRenderObject = Overlay.maybeOf(
      context,
    )?.context.findRenderObject();

    if (anchorRenderObject is! RenderBox || overlayRenderObject is! RenderBox) {
      return;
    }

    final anchorOffset = anchorRenderObject.localToGlobal(
      Offset.zero,
      ancestor: overlayRenderObject,
    );
    final anchorSize = anchorRenderObject.size;

    showDialog<void>(
      context: context,
      barrierColor: commonDialogBarrierColor,
      builder: (dialogContext) {
        void closePopup() => Navigator.of(dialogContext).pop();

        return LayoutBuilder(
          builder: (context, constraints) {
            final popupLeft =
                (anchorOffset.dx +
                        anchorSize.width -
                        AppSizes.editDeletePopupWidth)
                    .clamp(
                      AppSpacing.x8,
                      constraints.maxWidth -
                          AppSizes.editDeletePopupWidth -
                          AppSpacing.x8,
                    )
                    .toDouble();
            final popupTop =
                (anchorOffset.dy +
                        anchorSize.height +
                        AppSpacing.x4 -
                        _actionPopupTopAdjustment)
                    .clamp(
                      AppSpacing.x8,
                      constraints.maxHeight -
                          AppSizes.editDeletePopupHeight -
                          AppSpacing.x8,
                    )
                    .toDouble();

            return Stack(
              children: [
                Positioned(
                  top: popupTop,
                  left: popupLeft,
                  child: CommonEditDeletePopup(
                    onEdit: closePopup,
                    onDelete: () {
                      closePopup();
                      _showDeleteDialog(context: context, ref: ref, memo: memo);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required MemoItem memo,
  }) {
    final navigator = Navigator.of(context);

    showCommonDialog<void>(
      context: context,
      child: CommonDialogCard(
        title: '게시물 삭제',
        message: '해당 게시물을 삭제하시겠습니까?',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            foregroundColor: AppColors.textBody,
            onPressed: navigator.pop,
          ),
          CommonDialogActionButton.confirm(
            label: '삭제',
            foregroundColor: AppColors.danger,
            onPressed: () {
              navigator.pop();
              ref
                  .read(memoListProvider.notifier)
                  .deleteMemo(plantId: plantId, memoId: memo.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWriteAction(BuildContext context) {
    return SizedBox(
      width: _writeActionWidth,
      child: TextButton(
        onPressed: () => _openWritePage(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandStrong,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: AppTextStyles.size14Medium,
        ),
        child: const Text(
          '작성하기',
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memoItemsProvider(plantId));

    return CommonScaffold(
      title: 'Memo',
      bodyPadding: EdgeInsets.zero,
      trailingWidth: _writeActionWidth,
      trailing: _buildWriteAction(context),
      floatingActionButton: FloatingActionButton(
        tooltip: '메모 작성',
        onPressed: () => _openWritePage(context),
        elevation: 0,
        backgroundColor: AppColors.brandStrong,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: AppSizes.iconLarge),
      ),
      child: memos.isEmpty
          ? const _MemoEmptyView()
          : _MemoFeedList(
              memos: memos,
              onOpenMenu: (memo, anchorContext) {
                _showActionPopup(
                  context: context,
                  ref: ref,
                  memo: memo,
                  anchorContext: anchorContext,
                );
              },
            ),
    );
  }
}

class _MemoEmptyView extends StatelessWidget {
  const _MemoEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonSvgIcon(
              AppIconAssets.plantEmpty,
              width: AppSizes.iconLarge,
              height: AppSizes.iconLarge,
              color: AppColors.iconInactive,
              semanticsLabel: '메모 없음',
            ),
            const SizedBox(height: AppSpacing.x16),
            Text(
              '아직 작성된 메모가 없어요',
              textAlign: TextAlign.center,
              style: AppTextStyles.size18Medium.copyWith(
                color: AppColors.textStrong,
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
            Text(
              '식물의 변화를 메모로 남겨보세요',
              textAlign: TextAlign.center,
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoFeedList extends StatelessWidget {
  const _MemoFeedList({required this.memos, required this.onOpenMenu});

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
