import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final memoListProvider =
    NotifierProvider<MemoListNotifier, Map<String, List<MemoItem>>>(
      MemoListNotifier.new,
    );

final memoItemsProvider = Provider.family<List<MemoItem>, String>((
  ref,
  plantId,
) {
  return ref.watch(
    memoListProvider.select(
      (memosByPlant) => memosByPlant[plantId] ?? const <MemoItem>[],
    ),
  );
});

class MemoItem {
  const MemoItem({
    required this.id,
    required this.author,
    required this.content,
    required this.dateLabel,
    this.avatarAsset,
    this.imageAsset,
    this.imageAlignment = Alignment.center,
  });

  final String id;
  final String author;
  final String content;
  final String dateLabel;
  final String? avatarAsset;
  final String? imageAsset;
  final Alignment imageAlignment;
}

class MemoListNotifier extends Notifier<Map<String, List<MemoItem>>> {
  int _nextId = 1;

  @override
  Map<String, List<MemoItem>> build() {
    return const {'plant-1': _defaultMemoItems};
  }

  MemoItem addMemo({
    required String plantId,
    required String content,
    bool hasPhoto = false,
  }) {
    final memo = MemoItem(
      id: 'local-memo-${_nextId++}',
      author: '커먼플랜트',
      content: content,
      dateLabel: '오늘',
      avatarAsset: AppImageAssets.profileSetupSampleAvatar,
      imageAsset: hasPhoto ? AppImageAssets.placeDetailMonstera : null,
    );
    final currentMemos = state[plantId] ?? const <MemoItem>[];

    state = {
      ...state,
      plantId: [memo, ...currentMemos],
    };

    return memo;
  }

  void deleteMemo({required String plantId, required String memoId}) {
    final currentMemos = state[plantId] ?? const <MemoItem>[];

    state = {
      ...state,
      plantId: [
        for (final memo in currentMemos)
          if (memo.id != memoId) memo,
      ],
    };
  }
}

const List<MemoItem> _defaultMemoItems = [
  MemoItem(
    id: 'sample-memo-1',
    author: '커먼플랜트',
    content:
        '장마여서 물주는 날짜를 조금 늦춤 하지만 해는 맑구나 몬테랑 함께한 지 벌써 56일이 되었구나 요즘 잎이 갈라지니 채광이 더 드는 곳으로 자리를 옮겨야 할 것 같다.',
    dateLabel: '2022.11.20',
    avatarAsset: AppImageAssets.profileSetupSampleAvatar,
    imageAsset: AppImageAssets.memoListMonstera,
  ),
  MemoItem(
    id: 'sample-memo-2',
    author: '커먼맘',
    content: '오늘은 잎이 조금 시들하구나 커먼아 해결책은?',
    dateLabel: '2022.11.20',
    avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
  ),
  MemoItem(
    id: 'sample-memo-3',
    author: '커먼맘',
    content:
        '오늘은 잎의 상태가 매우 좋다 커먼아 앱에서 알려준 물주기의 주기가 아주 딱 맞는 것 같구나. 요즘 내가 물 주기 누르는 거 자꾸 깜빡깜빡하니 커먼이 네가 조금 더 신경써주길 바란다.',
    dateLabel: '2022.11.20',
    avatarAsset: AppImageAssets.placeDetailAvatarCommonMom,
    imageAsset: AppImageAssets.memoListMonstera,
    imageAlignment: Alignment.topCenter,
  ),
  MemoItem(
    id: 'sample-memo-4',
    author: '커먼 파파',
    content: '오늘도 맑음',
    dateLabel: '2022.11.20',
  ),
];
