import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_list_provider.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_write_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String memoWriteSubmitFailureMessage = '메모 저장에 실패했어요';

final memoWriteControllerProvider = NotifierProvider.autoDispose
    .family<MemoWriteController, MemoWriteState, String>(
      MemoWriteController.new,
    );

class MemoWriteController extends Notifier<MemoWriteState> {
  MemoWriteController(this.plantId);

  final String plantId;

  @override
  MemoWriteState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return MemoWriteState.initial(plantId);
  }

  void updateContent(String content) {
    state = state.copyWith(
      content: content,
      submitStatus: MemoWriteSubmitStatus.idle,
      clearErrorMessage: true,
    );
  }

  void selectPhoto() {
    state = state.copyWith(hasPhoto: true);
  }

  void removePhoto() {
    state = state.copyWith(hasPhoto: false);
  }

  bool submit() {
    if (!state.canSubmit) {
      return false;
    }

    state = state.copyWith(
      submitStatus: MemoWriteSubmitStatus.submitting,
      clearErrorMessage: true,
    );

    try {
      ref
          .read(memoListProvider.notifier)
          .addMemo(
            plantId: plantId,
            content: state.content.trim(),
            hasPhoto: state.hasPhoto,
          );
      state = state.copyWith(submitStatus: MemoWriteSubmitStatus.success);

      return true;
    } catch (_) {
      state = state.copyWith(
        submitStatus: MemoWriteSubmitStatus.failure,
        errorMessage: memoWriteSubmitFailureMessage,
      );

      return false;
    }
  }
}
