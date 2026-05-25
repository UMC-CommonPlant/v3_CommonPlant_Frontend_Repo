import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Object? cause;

  factory ApiException.fromDio(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final data = response?.data;
    final parsedMessage = _messageFromData(data);

    return ApiException(
      statusCode: statusCode,
      code: _codeFromData(data),
      message: parsedMessage ?? _messageFromType(exception.type),
      cause: exception,
    );
  }

  @override
  String toString() {
    final codeLabel = code == null ? '' : '[$code] ';
    final statusLabel = statusCode == null ? '' : 'HTTP $statusCode ';

    return 'ApiException: $statusLabel$codeLabel$message';
  }
}

String? _messageFromData(Object? data) {
  if (data is Map<String, Object?>) {
    final message = data['message'] ?? data['error'] ?? data['detail'];

    if (message is String && message.isNotEmpty) {
      return message;
    }
  }

  if (data is String && data.isNotEmpty) {
    return data;
  }

  return null;
}

String? _codeFromData(Object? data) {
  if (data is! Map<String, Object?>) {
    return null;
  }

  final code = data['code'] ?? data['errorCode'];

  return code is String && code.isNotEmpty ? code : null;
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
