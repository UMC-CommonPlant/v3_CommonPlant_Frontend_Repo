import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
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
  static const double _writeActionWidth = AppSpacing.x20 * 4;

  final List<_MemoItem> _memos = [
    const _MemoItem(
      author: '커먼플랜트',
      content:
          '장마여서 물주는 날짜를 조금 늦춤 하지만 해는 맑구나 몬테랑 함께한 지 벌써 56일이 되었구나 요즘 잎이 갈라지니 채광이 더 드는 곳으로 자리를 옮겨야 할 것 같다.',
      dateLabel: '2022.11.20',
      avatarAsset: AppImageAssets.profileSetupSampleAvatar,
      imageAsset: AppImageAssets.memoListMonstera,
    ),
    const _MemoItem(
      author: '커먼맘',
      content: '오늘은 잎이 조금 시들하구나 커먼아 해결책은?',
      dateLabel: '2022.11.20',
      avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
    ),
    const _MemoItem(
      author: '커먼맘',
      content:
          '오늘은 잎의 상태가 매우 좋다 커먼아 앱에서 알려준 물주기의 주기가 아주 딱 맞는 것 같구나. 요즘 내가 물 주기 누르는 거 자꾸 깜빡깜빡하니 커먼이 네가 조금 더 신경써주길 바란다.',
      dateLabel: '2022.11.20',
      avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
      imageAsset: AppImageAssets.memoListMonstera,
      imageAlignment: Alignment.topCenter,
    ),
    const _MemoItem(
      author: '커먼 파파',
      content: '오늘도 맑음',
      dateLabel: '2022.11.20',
    ),
  ];

  void _openWritePage() {
    context.push(AppRoutePaths.memoWriteLocation(widget.plantId));
  }

  void _showActionPopup(_MemoItem memo, BuildContext anchorContext) {
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
                (anchorOffset.dy + anchorSize.height + AppSpacing.x4)
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
                      _showDeleteDialog(memo);
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

  void _showDeleteDialog(_MemoItem memo) {
    showCommonDialog<void>(
      context: context,
      child: CommonDialogCard(
        title: '게시물 삭제',
        message: '해당 게시물을 삭제하시겠습니까?',
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

  Widget _buildWriteAction() {
    return SizedBox(
      width: _writeActionWidth,
      child: TextButton(
        onPressed: _openWritePage,
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
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Memo',
      bodyPadding: EdgeInsets.zero,
      trailingWidth: _writeActionWidth,
      trailing: _buildWriteAction(),
      floatingActionButton: FloatingActionButton(
        tooltip: '메모 작성',
        onPressed: _openWritePage,
        elevation: 0,
        backgroundColor: AppColors.brandStrong,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: AppSizes.iconLarge),
      ),
      child: _MemoFeedList(memos: _memos, onOpenMenu: _showActionPopup),
    );
  }
}

class _MemoFeedList extends StatelessWidget {
  const _MemoFeedList({required this.memos, required this.onOpenMenu});

  final List<_MemoItem> memos;
  final void Function(_MemoItem memo, BuildContext anchorContext) onOpenMenu;

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

  final _MemoItem memo;
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

class _MemoItem {
  const _MemoItem({
    required this.author,
    required this.content,
    required this.dateLabel,
    this.avatarAsset,
    this.imageAsset,
    this.imageAlignment = Alignment.center,
  });

  final String author;
  final String content;
  final String dateLabel;
  final String? avatarAsset;
  final String? imageAsset;
  final Alignment imageAlignment;
}
