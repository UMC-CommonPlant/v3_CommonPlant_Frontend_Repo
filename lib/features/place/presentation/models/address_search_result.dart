class AddressSearchResult {
  const AddressSearchResult({
    required this.titlePrefix,
    required this.titleSuffix,
    required this.address,
    this.highlighted = false,
  });

  final String titlePrefix;
  final String titleSuffix;
  final String address;
  final bool highlighted;

  String get title => '$titlePrefix $titleSuffix';
}
