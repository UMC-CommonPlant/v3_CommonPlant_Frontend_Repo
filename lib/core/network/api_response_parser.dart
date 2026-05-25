import 'dart:convert';

import 'package:commonplant_frontend/core/network/api_exception.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap jsonObjectFromResponse(Object? data, {required String context}) {
  final normalized = _normalizeResponseData(data);

  if (normalized is JsonMap) {
    return normalized;
  }

  throw ApiException(message: '$context 응답이 JSON object 형식이 아닙니다.');
}

List<JsonMap> jsonListFromResponse(Object? data, {required String context}) {
  final normalized = _normalizeResponseData(data);
  final unwrapped = _unwrapData(normalized);

  if (unwrapped is List) {
    return [
      for (final item in unwrapped)
        if (item is JsonMap) item,
    ];
  }

  if (unwrapped is JsonMap) {
    for (final key in const ['items', 'content', 'list', 'places', 'plants']) {
      final value = unwrapped[key];
      if (value is List) {
        return [
          for (final item in value)
            if (item is JsonMap) item,
        ];
      }
    }
  }

  throw ApiException(message: '$context 응답에서 목록 데이터를 찾을 수 없습니다.');
}

JsonMap unwrapJsonObject(Object? data, {required String context}) {
  final object = jsonObjectFromResponse(data, context: context);
  final unwrapped = _unwrapData(object);

  if (unwrapped is JsonMap) {
    return unwrapped;
  }

  return object;
}

String readRequiredString(JsonMap json, List<String> keys, String context) {
  final value = readOptionalString(json, keys);

  if (value != null && value.isNotEmpty) {
    return value;
  }

  throw ApiException(message: '$context 필드가 응답에 없습니다: ${keys.join(', ')}');
}

String? readOptionalString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];

    if (value == null) {
      continue;
    }

    if (value is String) {
      return value;
    }

    if (value is num || value is bool) {
      return value.toString();
    }
  }

  return null;
}

int? readOptionalInt(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }
  }

  return null;
}

Object? _normalizeResponseData(Object? data) {
  if (data is String && data.isNotEmpty) {
    return jsonDecode(data);
  }

  return data;
}

Object? _unwrapData(Object? data) {
  if (data is! JsonMap) {
    return data;
  }

  for (final key in const ['data', 'result', 'payload', 'body']) {
    final value = data[key];
    if (value != null) {
      return value;
    }
  }

  return data;
}
