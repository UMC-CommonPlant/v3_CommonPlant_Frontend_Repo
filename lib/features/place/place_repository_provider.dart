import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  return DioPlaceRemoteDataSource(ref.watch(dioProvider));
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepositoryImpl(ref.watch(placeRemoteDataSourceProvider));
});
