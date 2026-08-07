import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/mappers/place_detail_view_mapper.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_view_data.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PlaceDetailViewRequest = ({String placeId, PlaceDetailRole? role});

final placeDetailViewProvider =
    Provider.family<AsyncValue<PlaceDetailViewData?>, PlaceDetailViewRequest>((
      ref,
      request,
    ) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(ref.watch(placeLocalDetailViewProvider(request)));
      }

      return ref.watch(placeRemoteDetailViewProvider(request));
    });

final placeLocalDetailViewProvider =
    Provider.family<PlaceDetailViewData, PlaceDetailViewRequest>((
      ref,
      request,
    ) {
      return placeDetailFixture(request.placeId, role: request.role);
    });

final placeRemoteDetailViewProvider =
    FutureProvider.family<PlaceDetailViewData?, PlaceDetailViewRequest>((
      ref,
      request,
    ) async {
      final fallback = ref.watch(placeLocalDetailViewProvider(request));
      final summary = await ref.watch(
        placeDetailProvider(request.placeId).future,
      );

      return mapPlaceSummaryToDetailViewData(
        fallback: fallback,
        summary: summary,
      );
    }, retry: (retryCount, error) => null);

void invalidatePlaceDetailView(WidgetRef ref, PlaceDetailViewRequest request) {
  ref.invalidate(placeDetailProvider(request.placeId));
  ref.invalidate(placeRemoteDetailViewProvider(request));
}
