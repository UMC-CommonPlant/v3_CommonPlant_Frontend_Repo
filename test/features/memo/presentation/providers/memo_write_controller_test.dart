import 'package:commonplant_frontend/features/memo/presentation/providers/memo_list_provider.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_write_controller.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_write_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('메모 내용에 따라 canSubmit을 계산한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = memoWriteControllerProvider('plant-1');
    final controller = container.read(provider.notifier);

    expect(container.read(provider).canSubmit, isFalse);

    controller.updateContent('   ');
    expect(container.read(provider).canSubmit, isFalse);

    controller.updateContent('오늘도 맑음');
    expect(container.read(provider).content, '오늘도 맑음');
    expect(container.read(provider).canSubmit, isTrue);
  });

  test('메모 사진을 선택하고 제거한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = memoWriteControllerProvider('plant-1');
    final controller = container.read(provider.notifier);

    controller.selectPhoto();
    expect(container.read(provider).hasPhoto, isTrue);

    controller.removePhoto();
    expect(container.read(provider).hasPhoto, isFalse);
  });

  test('제출 시 메모를 추가하고 submitting과 success 상태를 거친다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = memoWriteControllerProvider('new-plant');
    final statuses = <MemoWriteSubmitStatus>[];
    final subscription = container.listen(
      provider,
      (previous, next) => statuses.add(next.submitStatus),
    );
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);

    controller.updateContent('  새 잎이 올라왔다  ');
    controller.selectPhoto();

    expect(controller.submit(), isTrue);
    expect(
      statuses,
      containsAllInOrder([
        MemoWriteSubmitStatus.submitting,
        MemoWriteSubmitStatus.success,
      ]),
    );

    final memo = container.read(memoItemsProvider('new-plant')).single;
    expect(memo.content, '새 잎이 올라왔다');
    expect(memo.imageAsset, isNotNull);
  });

  test('메모 추가가 실패하면 failure 상태와 메시지를 제공한다', () {
    final container = ProviderContainer(
      overrides: [memoListProvider.overrideWith(_ThrowingMemoListNotifier.new)],
    );
    addTearDown(container.dispose);
    final provider = memoWriteControllerProvider('plant-1');
    final controller = container.read(provider.notifier);

    controller.updateContent('저장할 메모');

    expect(controller.submit(), isFalse);
    expect(
      container.read(provider).submitStatus,
      MemoWriteSubmitStatus.failure,
    );
    expect(
      container.read(provider).errorMessage,
      memoWriteSubmitFailureMessage,
    );
    expect(container.read(provider).canSubmit, isTrue);
  });
}

class _ThrowingMemoListNotifier extends MemoListNotifier {
  @override
  MemoItem addMemo({
    required String plantId,
    required String content,
    bool hasPhoto = false,
  }) {
    throw StateError('save failed');
  }
}
