import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/address_search_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String initialAddressSearchQuery = '신도림역';

final addressSearchControllerProvider =
    NotifierProvider.autoDispose<AddressSearchController, AddressSearchState>(
      AddressSearchController.new,
    );

class AddressSearchState {
  const AddressSearchState({
    required this.query,
    required this.results,
    this.isAvailable = true,
  });

  const AddressSearchState.unavailable()
    : this(query: '', results: const [], isAvailable: false);

  final String query;
  final List<AddressSearchResult> results;
  final bool isAvailable;
}

class AddressSearchController extends Notifier<AddressSearchState> {
  @override
  AddressSearchState build() {
    // 실제 검색 adapter가 연결되기 전에는 fixture로 대체하지 않는다.
    if (ref.watch(useRemoteApiProvider)) {
      return const AddressSearchState.unavailable();
    }

    return AddressSearchState(
      query: initialAddressSearchQuery,
      results: _matchingAddresses(initialAddressSearchQuery),
    );
  }

  void updateQuery(String query) {
    if (!state.isAvailable) return;

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
