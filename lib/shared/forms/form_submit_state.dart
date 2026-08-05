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
