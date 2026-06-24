String? requiredPathParameter(
  Map<String, String> pathParameters,
  String parameterName,
) {
  final value = pathParameters[parameterName]?.trim();

  if (value == null || value.isEmpty) {
    return null;
  }

  return value;
}
