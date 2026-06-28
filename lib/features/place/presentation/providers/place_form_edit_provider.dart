import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String placeFormDefaultEditName = '스윗 홈_ 거실';

class PlaceFormEditInfo {
  const PlaceFormEditInfo({required this.id, required this.name, this.address});

  factory PlaceFormEditInfo.fromSummary(PlaceSummary summary) {
    return PlaceFormEditInfo(
      id: summary.id,
      name: summary.name,
      address: summary.address,
    );
  }

  final String id;
  final String name;
  final String? address;
}

final placeFormEditInfoProvider =
    Provider.family<AsyncValue<PlaceFormEditInfo?>, String>((ref, placeId) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(
          PlaceFormEditInfo(id: placeId, name: placeFormDefaultEditName),
        );
      }

      return ref.watch(remotePlaceFormEditInfoProvider(placeId));
    });

final remotePlaceFormEditInfoProvider =
    FutureProvider.family<PlaceFormEditInfo?, String>((ref, placeId) async {
      final summary = await ref.watch(placeDetailProvider(placeId).future);

      if (summary.name.trim().isEmpty) {
        return null;
      }

      return PlaceFormEditInfo.fromSummary(summary);
    }, retry: (retryCount, error) => null);

void invalidatePlaceFormEditInfo(WidgetRef ref, String placeId) {
  ref.invalidate(placeDetailProvider(placeId));
  ref.invalidate(remotePlaceFormEditInfoProvider(placeId));
}
