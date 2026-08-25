import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/presentation/fixtures/plant_detail_fixture.dart';
import 'package:commonplant_frontend/features/plant/presentation/mappers/plant_detail_view_mapper.dart';
import 'package:commonplant_frontend/features/plant/presentation/models/plant_detail_view_data.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PlantDetailViewRequest = ({String plantId, String? placeCode});

final plantDetailNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final plantDetailViewProvider =
    Provider.family<AsyncValue<PlantDetailViewData?>, PlantDetailViewRequest>((
      ref,
      request,
    ) {
      if (!ref.watch(useRemoteApiProvider)) {
        return AsyncData(ref.watch(plantLocalDetailViewProvider(request)));
      }

      return ref.watch(plantRemoteDetailViewProvider(request));
    });

final plantLocalDetailViewProvider =
    Provider.family<PlantDetailViewData, PlantDetailViewRequest>((
      ref,
      request,
    ) {
      return plantDetailFixture(placeCode: request.placeCode);
    });

final plantRemoteDetailViewProvider =
    FutureProvider.family<PlantDetailViewData?, PlantDetailViewRequest>((
      ref,
      request,
    ) async {
      final now = ref.watch(plantDetailNowProvider);
      final detail = await ref.watch(
        remotePlantDetailProvider(request.plantId).future,
      );

      return mapPlantDetailToViewData(
        detail: detail,
        placeCode: request.placeCode,
        now: now(),
      );
    }, retry: (retryCount, error) => null);

void invalidatePlantDetailView(WidgetRef ref, PlantDetailViewRequest request) {
  ref.invalidate(remotePlantDetailProvider(request.plantId));
  ref.invalidate(plantRemoteDetailViewProvider(request));
}
