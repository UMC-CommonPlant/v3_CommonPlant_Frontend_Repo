const int memoWriteMaxContentLength = 200;
const int memoWriteMaxPhotoCount = 1;

enum MemoWriteSubmitStatus { idle, submitting, success, failure }

class MemoWriteState {
  const MemoWriteState({
    required this.plantId,
    required this.content,
    required this.hasPhoto,
    required this.submitStatus,
    this.errorMessage,
  });

  const MemoWriteState.initial(String plantId)
    : this(
        plantId: plantId,
        content: '',
        hasPhoto: false,
        submitStatus: MemoWriteSubmitStatus.idle,
      );

  final String plantId;
  final String content;
  final bool hasPhoto;
  final MemoWriteSubmitStatus submitStatus;
  final String? errorMessage;

  bool get isSubmitting => submitStatus == MemoWriteSubmitStatus.submitting;

  bool get canSubmit => content.trim().isNotEmpty && !isSubmitting;

  MemoWriteState copyWith({
    String? content,
    bool? hasPhoto,
    MemoWriteSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MemoWriteState(
      plantId: plantId,
      content: content ?? this.content,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
