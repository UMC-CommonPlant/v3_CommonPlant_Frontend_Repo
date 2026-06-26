import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PlaceDetailViewRequest = ({String placeId, PlaceDetailRole? role});

final placeDetailViewProvider =
    Provider.family<
      AsyncValue<PlaceDetailFixtureData?>,
      PlaceDetailViewRequest
    >((ref, request) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(
          placeDetailFixture(request.placeId, role: request.role),
        );
      }

      return ref.watch(remotePlaceDetailViewProvider(request));
    });

final remotePlaceDetailViewProvider =
    FutureProvider.family<PlaceDetailFixtureData?, PlaceDetailViewRequest>((
      ref,
      request,
    ) async {
      final fixture = placeDetailFixture(request.placeId, role: request.role);
      final summary = await ref.watch(
        placeDetailProvider(request.placeId).future,
      );

      if (summary.name.trim().isEmpty) {
        return null;
      }

      return fixture.applySummary(summary);
    }, retry: (retryCount, error) => null);

void invalidatePlaceDetailView(WidgetRef ref, PlaceDetailViewRequest request) {
  ref.invalidate(placeDetailProvider(request.placeId));
  ref.invalidate(remotePlaceDetailViewProvider(request));
}
