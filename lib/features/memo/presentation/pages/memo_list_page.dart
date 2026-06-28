import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_list_provider.dart';
import 'package:commonplant_frontend/features/memo/presentation/widgets/memo_delete_dialog.dart';
import 'package:commonplant_frontend/features/memo/presentation/widgets/memo_empty_view.dart';
import 'package:commonplant_frontend/features/memo/presentation/widgets/memo_list_content.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
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
      child: MemoDeleteDialog(
        onCancel: navigator.pop,
        onDelete: () {
          navigator.pop();
          ref
              .read(memoListProvider.notifier)
              .deleteMemo(plantId: plantId, memoId: memo.id);
        },
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
          ? const MemoEmptyView()
          : MemoListContent(
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
