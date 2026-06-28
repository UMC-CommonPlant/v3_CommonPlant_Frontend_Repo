import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart'
    show PlantEditInfo;

const String plantFormDefaultEditName = '몬테';

final plantFormEditInfoProvider =
    Provider.family<AsyncValue<PlantEditInfo?>, String>((ref, plantId) {
      if (!ref.watch(useRemoteApiProvider)) {
        return const AsyncData(PlantEditInfo(name: plantFormDefaultEditName));
      }

      return ref.watch(remotePlantFormEditInfoProvider(plantId));
    });

final remotePlantFormEditInfoProvider =
    FutureProvider.family<PlantEditInfo?, String>((ref, plantId) async {
      final info = await ref.watch(remotePlantEditInfoProvider(plantId).future);

      if (info.name.trim().isEmpty) {
        return null;
      }

      return info;
    }, retry: (retryCount, error) => null);

void invalidatePlantFormEditInfo(WidgetRef ref, String plantId) {
  ref.invalidate(remotePlantEditInfoProvider(plantId));
  ref.invalidate(remotePlantFormEditInfoProvider(plantId));
}

final remotePlantEditInfoProvider =
    FutureProvider.family<PlantEditInfo, String>(
      (ref, plantId) => ref
          .watch(plantRepositoryProvider)
          .fetchPlantEditInfo(plantId: plantId),
      retry: (retryCount, error) => null,
    );
