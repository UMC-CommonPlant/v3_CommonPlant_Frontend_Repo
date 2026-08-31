import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:flutter/foundation.dart';

enum FormSubmitStatus { idle, submitting, failure }

class FormSubmitState {
  const FormSubmitState.idle() : this._(FormSubmitStatus.idle);

  const FormSubmitState.submitting() : this._(FormSubmitStatus.submitting);

  const FormSubmitState.failure(
    String message, {
    Map<String, String> fieldErrors = const {},
  }) : this._(
         FormSubmitStatus.failure,
         errorMessage: message,
         fieldErrors: fieldErrors,
       );

  factory FormSubmitState.failureFrom(
    Object error, {
    required String fallbackMessage,
  }) {
    if (error is ApiException) {
      return FormSubmitState.failure(
        error.userMessage(fallback: fallbackMessage),
        fieldErrors: error.fieldErrorMessages,
      );
    }

    return FormSubmitState.failure(fallbackMessage);
  }

  const FormSubmitState._(
    this.status, {
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final FormSubmitStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  bool get isSubmitting => status == FormSubmitStatus.submitting;

  bool get hasError =>
      status == FormSubmitStatus.failure && errorMessage != null;

  String? fieldError(String field) => fieldErrors[field];

  @override
  bool operator ==(Object other) {
    return other is FormSubmitState &&
        other.status == status &&
        other.errorMessage == errorMessage &&
        mapEquals(other.fieldErrors, fieldErrors);
  }

  @override
  int get hashCode => Object.hash(
    status,
    errorMessage,
    Object.hashAllUnordered(
      fieldErrors.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  @override
  String toString() {
    return 'FormSubmitState(status: $status, errorMessage: $errorMessage, '
        'fieldErrorKeys: ${fieldErrors.keys.toList()})';
  }
}
