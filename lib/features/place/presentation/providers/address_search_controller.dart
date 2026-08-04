import 'package:commonplant_frontend/features/place/presentation/fixtures/address_search_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String initialAddressSearchQuery = '신도림역';

final addressSearchControllerProvider =
    NotifierProvider.autoDispose<AddressSearchController, AddressSearchState>(
      AddressSearchController.new,
    );

class AddressSearchState {
  const AddressSearchState({required this.query, required this.results});

  final String query;
  final List<AddressSearchResult> results;
}

class AddressSearchController extends Notifier<AddressSearchState> {
  @override
  AddressSearchState build() {
    return AddressSearchState(
      query: initialAddressSearchQuery,
      results: _matchingAddresses(initialAddressSearchQuery),
    );
  }

  void updateQuery(String query) {
    state = AddressSearchState(
      query: query,
      results: _matchingAddresses(query),
    );
  }

  List<AddressSearchResult> _matchingAddresses(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      return addressSearchFixture;
    }

    return List.unmodifiable(
      addressSearchFixture.where(
        (result) =>
            result.title.contains(query) || result.address.contains(query),
      ),
    );
  }
}
