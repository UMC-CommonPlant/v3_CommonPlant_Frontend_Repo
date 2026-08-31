import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_search_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_candidate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantSearchControllerProvider =
    NotifierProvider.autoDispose<PlantSearchController, PlantSearchState>(
      PlantSearchController.new,
    );

class PlantSearchState {
  const PlantSearchState({
    required this.query,
    required this.results,
    this.isAvailable = true,
  });

  const PlantSearchState.unavailable()
    : this(query: '', results: const [], isAvailable: false);

  final String query;
  final List<PlantCandidate> results;
  final bool isAvailable;

  bool get hasQuery => _normalize(query).isNotEmpty;
}

class PlantSearchController extends Notifier<PlantSearchState> {
  @override
  PlantSearchState build() {
    // 백엔드 검색 계약이 연결되기 전에는 fixture를 원격 결과로 사용하지 않는다.
    if (ref.watch(useRemoteApiProvider)) {
      return const PlantSearchState.unavailable();
    }

    return const PlantSearchState(query: '', results: []);
  }

  void updateQuery(String query) {
    if (!state.isAvailable) return;

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
