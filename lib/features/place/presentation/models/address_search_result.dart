enum AddressSearchResultSource { fixture, searchService }

class AddressSearchResult {
  const AddressSearchResult({
    required this.titlePrefix,
    required this.titleSuffix,
    required this.address,
    required this.source,
    this.highlighted = false,
  });

  final String titlePrefix;
  final String titleSuffix;
  final String address;
  final AddressSearchResultSource source;
  final bool highlighted;

  String get title => '$titlePrefix $titleSuffix';
}
