import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeListProvider =
    NotifierProvider<PlaceListNotifier, List<PlaceSummary>>(
      PlaceListNotifier.new,
    );

class PlaceSummary {
  const PlaceSummary({required this.id, required this.name, this.address});

  final String id;
  final String name;
  final String? address;

  PlaceSummary copyWith({String? id, String? name, String? address}) {
    return PlaceSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}

class PlaceListNotifier extends Notifier<List<PlaceSummary>> {
  int _nextId = 1;

  @override
  List<PlaceSummary> build() {
    return const [];
  }

  PlaceSummary addPlace({required String name, String? address}) {
    final place = PlaceSummary(
      id: 'place-${_nextId++}',
      name: name,
      address: address,
    );
    state = [...state, place];
    return place;
  }

  void updatePlace({
    required String id,
    required String name,
    String? address,
  }) {
    state = [
      for (final place in state)
        if (place.id == id)
          place.copyWith(name: name, address: address)
        else
          place,
    ];
  }
}
