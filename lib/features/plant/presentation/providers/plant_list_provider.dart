import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantListProvider =
    NotifierProvider<PlantListNotifier, List<PlantSummary>>(
      PlantListNotifier.new,
    );

class PlantSummary {
  const PlantSummary({
    required this.id,
    required this.name,
    this.placeName,
    this.description,
  });

  final String id;
  final String name;
  final String? placeName;
  final String? description;

  PlantSummary copyWith({
    String? id,
    String? name,
    String? placeName,
    String? description,
  }) {
    return PlantSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      placeName: placeName ?? this.placeName,
      description: description ?? this.description,
    );
  }
}

class PlantListNotifier extends Notifier<List<PlantSummary>> {
  int _nextId = 1;

  @override
  List<PlantSummary> build() {
    return const [];
  }

  PlantSummary addPlant({
    required String name,
    String? placeName,
    String? description,
  }) {
    final plant = PlantSummary(
      id: 'plant-${_nextId++}',
      name: name,
      placeName: placeName,
      description: description,
    );
    state = [...state, plant];
    return plant;
  }

  void updatePlant({
    required String id,
    required String name,
    String? placeName,
    String? description,
  }) {
    state = [
      for (final plant in state)
        if (plant.id == id)
          plant.copyWith(
            name: name,
            placeName: placeName,
            description: description,
          )
        else
          plant,
    ];
  }
}
