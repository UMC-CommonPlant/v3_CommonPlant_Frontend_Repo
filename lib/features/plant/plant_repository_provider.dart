import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/features/plant/data/datasources/plant_remote_data_source.dart';
import 'package:commonplant_frontend/features/plant/data/repositories/plant_repository.dart';
import 'package:commonplant_frontend/features/plant/domain/repositories/plant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plantRemoteDataSourceProvider = Provider<PlantRemoteDataSource>((ref) {
  return DioPlantRemoteDataSource(ref.watch(dioProvider));
});

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  return PlantRepositoryImpl(ref.watch(plantRemoteDataSourceProvider));
});
