import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PlaceDetailViewRequest = ({String placeId, PlaceDetailRole? role});

final placeDetailViewProvider =
    Provider.family<
      AsyncValue<PlaceDetailFixtureData?>,
      PlaceDetailViewRequest
    >((ref, request) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(ref.watch(placeLocalDetailViewProvider(request)));
      }

      return ref.watch(placeRemoteDetailViewProvider(request));
    });

final placeLocalDetailViewProvider =
    Provider.family<PlaceDetailFixtureData, PlaceDetailViewRequest>((
      ref,
      request,
    ) {
      return placeDetailFixture(request.placeId, role: request.role);
    });

final placeRemoteDetailViewProvider =
    FutureProvider.family<PlaceDetailFixtureData?, PlaceDetailViewRequest>((
      ref,
      request,
    ) async {
      final fixture = ref.watch(placeLocalDetailViewProvider(request));
      final summary = await ref.watch(
        placeDetailProvider(request.placeId).future,
      );

      return applyRemotePlaceSummaryToFixture(
        fixture: fixture,
        summary: summary,
      );
    }, retry: (retryCount, error) => null);

PlaceDetailFixtureData? applyRemotePlaceSummaryToFixture({
  required PlaceDetailFixtureData fixture,
  required PlaceSummary summary,
}) {
  if (summary.name.trim().isEmpty) {
    return null;
  }

  return fixture.applySummary(summary);
}

void invalidatePlaceDetailView(WidgetRef ref, PlaceDetailViewRequest request) {
  ref.invalidate(placeDetailProvider(request.placeId));
  ref.invalidate(placeRemoteDetailViewProvider(request));
}
