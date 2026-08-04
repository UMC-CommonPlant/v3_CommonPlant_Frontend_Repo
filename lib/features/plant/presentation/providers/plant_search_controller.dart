import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_search_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_candidate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantSearchControllerProvider =
    NotifierProvider.autoDispose<PlantSearchController, PlantSearchState>(
      PlantSearchController.new,
    );

class PlantSearchState {
  const PlantSearchState({required this.query, required this.results});

  final String query;
  final List<PlantCandidate> results;

  bool get hasQuery => _normalize(query).isNotEmpty;
}

class PlantSearchController extends Notifier<PlantSearchState> {
  @override
  PlantSearchState build() {
    return const PlantSearchState(query: '', results: []);
  }

  void updateQuery(String query) {
    state = PlantSearchState(query: query, results: _matchingPlants(query));
  }

  List<PlantCandidate> _matchingPlants(String value) {
    final query = _normalize(value);

    if (query.isEmpty) {
      return const [];
    }

    return List.unmodifiable(
      plantSearchFixture.where(
        (plant) => _normalize(plant.name).contains(query),
      ),
    );
  }
}

String _normalize(String value) {
  return value.replaceAll(RegExp(r'\s+'), '').toLowerCase();
}
