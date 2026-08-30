import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart';
import 'package:commonplant_frontend/features/plant/plant_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:commonplant_frontend/features/plant/domain/entities/plant_detail.dart'
    show PlantEditInfo;

const String plantFormDefaultEditName = '몬테';

final plantFormEditInfoProvider =
    Provider.family<AsyncValue<PlantEditInfo?>, String>((ref, plantId) {
      if (!ref.watch(useRemoteApiProvider)) {
        return const AsyncData(PlantEditInfo(name: plantFormDefaultEditName));
      }

      return ref
          .watch(remotePlantEditInfoProvider(plantId))
          .whenData((info) => info.name.trim().isEmpty ? null : info)
          .unwrapPrevious();
    });

final remotePlantEditInfoProvider =
    FutureProvider.family<PlantEditInfo, String>((ref, plantId) {
      requireUserDataSession(ref);
      return ref
          .watch(plantRepositoryProvider)
          .fetchPlantEditInfo(plantId: plantId);
    }, retry: (retryCount, error) => null);
