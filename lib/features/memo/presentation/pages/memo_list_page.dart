import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_memo_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({super.key, required this.plantId});

  final String plantId;

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  final List<_MemoItem> _memos = [
    const _MemoItem(
      author: '커먼 파파',
      content: '새 잎이 올라오고 있어요.',
      dateLabel: '2026.05.06',
    ),
    const _MemoItem(
      author: '초록이',
      content: '흙이 말라서 물을 조금 줬어요.',
      dateLabel: '2026.05.05',
    ),
    const _MemoItem(
      author: '식집사',
      content: '잎 끝이 마르지 않도록 분무를 했어요.',
      dateLabel: '2026.05.01',
    ),
  ];

  void _showActionPopup(_MemoItem memo) {
    showDialog<void>(
      context: context,
      barrierColor: commonDialogBarrierColor,
      builder: (dialogContext) {
        void closePopup() => Navigator.of(dialogContext).pop();

        return Stack(
          children: [
            Positioned(
              top: 116,
              right: AppSpacing.x20,
              child: CommonEditDeletePopup(
                onEdit: closePopup,
                onDelete: () {
                  closePopup();
                  _showDeleteDialog(memo);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(_MemoItem memo) {
    showCommonDialog<void>(
      context: context,
      child: CommonDialogCard(
        title: '메모를 삭제할까요?',
        message: '삭제한 메모는 다시 복구할 수 없어요.',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            foregroundColor: AppColors.textBody,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CommonDialogActionButton.confirm(
            label: '삭제',
            foregroundColor: AppColors.danger,
            onPressed: () {
              setState(() => _memos.remove(memo));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '메모',
      trailing: IconButton(
        onPressed: () =>
            context.push(AppRoutePaths.memoWriteLocation(widget.plantId)),
        icon: const Icon(Icons.add, color: AppColors.textStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Phase0Surface(
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
                        '몬스테라',
                        style: AppTextStyles.size16Bold.copyWith(
                          color: AppColors.textStrong,
                        ),
                      ),
                      Text(
                        '총 ${_memos.length}개의 메모',
                        style: AppTextStyles.size14Medium.copyWith(
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                CommonButton(
                  label: '작성',
                  size: CommonButtonSize.small,
                  onPressed: () => context.push(
                    AppRoutePaths.memoWriteLocation(widget.plantId),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          if (_memos.isEmpty)
            Phase0EmptyState(
              title: '아직 메모가 없어요',
              description: '첫 관찰 메모를 남겨 보세요.',
              actionLabel: '메모 작성',
              onAction: () =>
                  context.push(AppRoutePaths.memoWriteLocation(widget.plantId)),
            )
          else
            for (final memo in _memos) ...[
              GestureDetector(
                onLongPress: () => _showActionPopup(memo),
                child: Stack(
                  children: [
                    CommonMemoCard(
                      author: memo.author,
                      content: memo.content,
                      dateLabel: memo.dateLabel,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: AppSpacing.x8,
                      right: AppSpacing.x8,
                      child: IconButton(
                        onPressed: () => _showActionPopup(memo),
                        icon: const Icon(Icons.more_horiz),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x12),
            ],
        ],
      ),
    );
  }
}

class _MemoItem {
  const _MemoItem({
    required this.author,
    required this.content,
    required this.dateLabel,
  });

  final String author;
  final String content;
  final String dateLabel;
}
