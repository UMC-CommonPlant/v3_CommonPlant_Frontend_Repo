import 'dart:collection';

import 'package:dio/dio.dart';

enum ApiFailureKind {
  validation,
  unauthenticated,
  forbidden,
  notFound,
  conflict,
  rateLimited,
  server,
  timeout,
  certificate,
  cancelled,
  network,
  unknown,
}

class ApiFieldError {
  const ApiFieldError({required this.field, required this.reason});

  final String field;
  final String reason;

  @override
  bool operator ==(Object other) {
    return other is ApiFieldError &&
        other.field == field &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(field, reason);
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.traceId,
    this.kind = ApiFailureKind.unknown,
    this.fieldErrors = const [],
    this.cause,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? traceId;
  final ApiFailureKind kind;
  final List<ApiFieldError> fieldErrors;
  final Object? cause;

  factory ApiException.fromDio(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final data = response?.data;
    final parsedMessage = _messageFromData(data);
    final code = _codeFromData(data);
    final fieldErrors = _fieldErrorsFromData(data);

    return ApiException(
      statusCode: statusCode,
      code: code,
      traceId: _traceIdFromData(data),
      message: parsedMessage ?? _messageFromType(exception.type),
      kind: _failureKind(
        type: exception.type,
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      ),
      fieldErrors: List.unmodifiable(fieldErrors),
      cause: exception,
    );
  }

  bool get requiresReauthentication =>
      statusCode == 401 && const {'A003', 'A004', 'A009'}.contains(code);

  Map<String, String> get fieldErrorMessages {
    final messages = <String, String>{};

    for (final error in fieldErrors) {
      messages.putIfAbsent(_normalizeField(error.field), () => error.reason);
    }

    final mapped = _fieldErrorFromCode(code);
    if (mapped != null) {
      messages.putIfAbsent(mapped.field, () => mapped.reason);
    }

    return UnmodifiableMapView(messages);
  }

  String userMessage({required String fallback}) {
    return switch (kind) {
      ApiFailureKind.validation => '입력 내용을 확인해 주세요.',
      ApiFailureKind.unauthenticated =>
        requiresReauthentication ? sessionExpiredMessage : '인증 정보를 다시 확인해 주세요.',
      ApiFailureKind.forbidden => '이 작업을 수행할 권한이 없어요.',
      ApiFailureKind.notFound => '요청한 정보를 찾을 수 없어요.',
      ApiFailureKind.conflict => '이미 처리되었거나 현재 상태와 맞지 않아요.',
      ApiFailureKind.rateLimited => '요청이 많아요. 잠시 후 다시 시도해 주세요.',
      ApiFailureKind.server => '서버에 문제가 발생했어요. 잠시 후 다시 시도해 주세요.',
      ApiFailureKind.timeout => '요청 시간이 초과됐어요. 다시 시도해 주세요.',
      ApiFailureKind.certificate => '안전한 서버 연결을 확인하지 못했어요.',
      ApiFailureKind.cancelled => '요청이 취소되었어요.',
      ApiFailureKind.network => '네트워크 연결을 확인한 뒤 다시 시도해 주세요.',
      ApiFailureKind.unknown => fallback,
    };
  }

  @override
  String toString() {
    final codeLabel = code == null ? '' : '[$code] ';
    final statusLabel = statusCode == null ? '' : 'HTTP $statusCode ';
    final traceLabel = traceId == null ? '' : 'trace=$traceId ';

    return 'ApiException: $statusLabel$codeLabel$traceLabel$message';
  }
}

const String sessionExpiredMessage = '로그인이 만료되었어요. 다시 로그인해 주세요.';

String apiUserMessage(Object error, {required String fallback}) {
  return error is ApiException
      ? error.userMessage(fallback: fallback)
      : fallback;
}

String? _messageFromData(Object? data) {
  if (data is Map<String, Object?>) {
    final message = data['message'] ?? data['error'] ?? data['detail'];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
  }

  if (data is String && data.trim().isNotEmpty) {
    return data.trim();
  }

  return null;
}

String? _codeFromData(Object? data) {
  if (data is! Map<String, Object?>) {
    return null;
  }

  final code = data['code'] ?? data['errorCode'];
  final normalized = code is String ? code.trim() : null;

  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _traceIdFromData(Object? data) {
  if (data is! Map<String, Object?>) {
    return null;
  }

  final traceId = data['traceId'];
  final normalized = traceId is String ? traceId.trim() : null;

  return normalized == null || normalized.isEmpty ? null : normalized;
}

List<ApiFieldError> _fieldErrorsFromData(Object? data) {
  if (data is! Map<String, Object?> || data['errors'] is! List) {
    return const [];
  }

  final errors = <ApiFieldError>[];
  for (final item in data['errors']! as List) {
    if (item is! Map<String, Object?>) continue;

    final field = item['field'];
    final reason = item['reason'];
    if (field is! String || reason is! String) continue;

    final normalizedField = field.trim();
    final normalizedReason = reason.trim();
    if (normalizedField.isEmpty || normalizedReason.isEmpty) continue;

    // rejected value는 개인정보가 될 수 있으므로 읽거나 보존하지 않는다.
    errors.add(ApiFieldError(field: normalizedField, reason: normalizedReason));
  }

  return errors;
}

ApiFailureKind _failureKind({
  required DioExceptionType type,
  required int? statusCode,
  required List<ApiFieldError> fieldErrors,
}) {
  switch (type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ApiFailureKind.timeout;
    case DioExceptionType.badCertificate:
      return ApiFailureKind.certificate;
    case DioExceptionType.cancel:
      return ApiFailureKind.cancelled;
    case DioExceptionType.connectionError:
      return ApiFailureKind.network;
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  if (fieldErrors.isNotEmpty || statusCode == 400 || statusCode == 422) {
    return ApiFailureKind.validation;
  }
  if (statusCode == 401) return ApiFailureKind.unauthenticated;
  if (statusCode == 403) return ApiFailureKind.forbidden;
  if (statusCode == 404) return ApiFailureKind.notFound;
  if (statusCode == 409) return ApiFailureKind.conflict;
  if (statusCode == 429) return ApiFailureKind.rateLimited;
  if (statusCode != null && statusCode >= 500) return ApiFailureKind.server;

  return ApiFailureKind.unknown;
}

ApiFieldError? _fieldErrorFromCode(String? code) {
  return switch (code) {
    'P107' => const ApiFieldError(
      field: 'name',
      reason: '장소 이름은 최대 10자까지 입력해 주세요.',
    ),
    'P108' => const ApiFieldError(field: 'address', reason: '장소 주소를 입력해 주세요.'),
    'P109' => const ApiFieldError(field: 'name', reason: '장소 이름을 입력해 주세요.'),
    'P004' => const ApiFieldError(
      field: 'nickname',
      reason: '식물 애칭을 다시 확인해 주세요.',
    ),
    _ => null,
  };
}

String _normalizeField(String field) {
  final segments = field.split('.');
  return segments.last.trim();
}

String _messageFromType(DioExceptionType type) {
  return switch (type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => '요청 시간이 초과되었습니다.',
    DioExceptionType.badCertificate => '서버 인증서가 유효하지 않습니다.',
    DioExceptionType.badResponse => '서버 요청에 실패했습니다.',
    DioExceptionType.cancel => '요청이 취소되었습니다.',
    DioExceptionType.connectionError => '네트워크 연결을 확인해 주세요.',
    DioExceptionType.unknown => '알 수 없는 네트워크 오류가 발생했습니다.',
  };
}
