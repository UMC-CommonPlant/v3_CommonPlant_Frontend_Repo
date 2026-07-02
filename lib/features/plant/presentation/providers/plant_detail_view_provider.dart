import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PlantDetailViewRequest = ({String plantId, String? placeCode});

final plantDetailViewProvider =
    Provider.family<
      AsyncValue<PlantDetailFixtureData?>,
      PlantDetailViewRequest
    >((ref, request) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(ref.watch(plantLocalDetailViewProvider(request)));
      }

      return ref.watch(plantRemoteDetailViewProvider(request));
    });

final plantLocalDetailViewProvider =
    Provider.family<PlantDetailFixtureData, PlantDetailViewRequest>((
      ref,
      request,
    ) {
      return plantDetailFixture(placeCode: request.placeCode);
    });

final plantRemoteDetailViewProvider =
    FutureProvider.family<PlantDetailFixtureData?, PlantDetailViewRequest>((
      ref,
      request,
    ) async {
      final fixture = ref.watch(plantLocalDetailViewProvider(request));
      final detail = await ref.watch(
        remotePlantDetailProvider(request.plantId).future,
      );

      return applyRemotePlantDetailToFixture(fixture: fixture, detail: detail);
    }, retry: (retryCount, error) => null);

PlantDetailFixtureData? applyRemotePlantDetailToFixture({
  required PlantDetailFixtureData fixture,
  required PlantDetail detail,
}) {
  if (detail.name.trim().isEmpty) {
    return null;
  }

  return fixture.applyRemote(detail);
}

void invalidatePlantDetailView(WidgetRef ref, PlantDetailViewRequest request) {
  ref.invalidate(remotePlantDetailProvider(request.plantId));
  ref.invalidate(plantRemoteDetailViewProvider(request));
}
