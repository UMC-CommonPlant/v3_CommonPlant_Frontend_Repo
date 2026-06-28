import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PlantDetailViewRequest = ({String plantId, String? placeCode});

final plantDetailViewProvider =
    Provider.family<
      AsyncValue<PlantDetailFixtureData?>,
      PlantDetailViewRequest
    >((ref, request) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(plantDetailFixture(placeCode: request.placeCode));
      }

      return ref.watch(remotePlantDetailViewProvider(request));
    });

final remotePlantDetailViewProvider =
    FutureProvider.family<PlantDetailFixtureData?, PlantDetailViewRequest>((
      ref,
      request,
    ) async {
      final fixture = plantDetailFixture(placeCode: request.placeCode);
      final detail = await ref.watch(
        remotePlantDetailProvider(request.plantId).future,
      );

      if (detail.name.trim().isEmpty) {
        return null;
      }

      return fixture.applyRemote(detail);
    }, retry: (retryCount, error) => null);

void invalidatePlantDetailView(WidgetRef ref, PlantDetailViewRequest request) {
  ref.invalidate(remotePlantDetailProvider(request.plantId));
  ref.invalidate(remotePlantDetailViewProvider(request));
}
