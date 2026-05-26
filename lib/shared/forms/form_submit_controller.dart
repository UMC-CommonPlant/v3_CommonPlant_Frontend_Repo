import 'package:flutter/foundation.dart';

enum FormSubmitStatus { idle, submitting, failure }

class FormSubmitState {
  const FormSubmitState.idle() : this._(FormSubmitStatus.idle);

  const FormSubmitState.submitting() : this._(FormSubmitStatus.submitting);

  const FormSubmitState.failure(String message)
    : this._(FormSubmitStatus.failure, errorMessage: message);

  const FormSubmitState._(this.status, {this.errorMessage});

  final FormSubmitStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == FormSubmitStatus.submitting;

  bool get hasError =>
      status == FormSubmitStatus.failure && errorMessage != null;

  @override
  bool operator ==(Object other) {
    return other is FormSubmitState &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, errorMessage);

  @override
  String toString() {
    return 'FormSubmitState(status: $status, errorMessage: $errorMessage)';
  }
}

class FormSubmitController extends ChangeNotifier {
  FormSubmitController({
    FormSubmitState initialState = const FormSubmitState.idle(),
  }) : _state = initialState;

  FormSubmitState _state;
  bool _isDisposed = false;

  FormSubmitState get state => _state;

  Future<void> submit(
    Future<void> Function() action, {
    String failureMessage = '요청 처리에 실패했어요',
    String Function(Object error)? failureMessageBuilder,
  }) async {
    if (_state.isSubmitting) {
      return;
    }

    _setState(const FormSubmitState.submitting());

    try {
      await action();
      _setState(const FormSubmitState.idle());
    } catch (error) {
      final message = failureMessageBuilder?.call(error) ?? failureMessage;
      _setState(FormSubmitState.failure(message));
    }
  }

  void reset() {
    _setState(const FormSubmitState.idle());
  }

  void fail(String message) {
    _setState(FormSubmitState.failure(message));
  }

  void _setState(FormSubmitState nextState) {
    if (_isDisposed || _state == nextState) {
      return;
    }

    _state = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
