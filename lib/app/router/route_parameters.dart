String? requiredPathParameter(
  Map<String, String> pathParameters,
  String parameterName,
) {
  return _normalizedParameter(pathParameters[parameterName]);
}

String? optionalQueryParameter(
  Map<String, String> queryParameters,
  String parameterName,
) {
  return _normalizedParameter(queryParameters[parameterName]);
}

String? _normalizedParameter(String? value) {
  final normalized = value?.trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}
