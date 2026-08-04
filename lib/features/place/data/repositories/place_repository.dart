import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/mappers/place_mapper.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  return PlaceRemoteDataSource(ref.watch(dioProvider));
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository(ref.watch(placeRemoteDataSourceProvider));
});

class PlaceRepository {
  const PlaceRepository(this._remoteDataSource);

  final PlaceRemoteDataSource _remoteDataSource;

  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    final data = await _remoteDataSource.getMyGarden();

    return placeSummariesFromResponse(data);
  }

  Future<List<PlaceSummary>> fetchUserPlaces() async {
    final data = await _remoteDataSource.getUserPlaces();

    return placeSummariesFromResponse(data);
  }

  Future<PlaceSummary> fetchPlace(String code) async {
    final data = await _remoteDataSource.getPlace(code);

    return placeSummaryFromResponse(data, fallbackId: code);
  }

  Future<void> createPlace(CreatePlaceRequest request, {MultipartFile? image}) {
    return _remoteDataSource.createPlace(request, image: image);
  }

  Future<void> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) {
    return _remoteDataSource.updatePlace(
      code: code,
      request: request,
      image: image,
    );
  }

  Future<void> deletePlace(String code) {
    return _remoteDataSource.deletePlace(code);
  }
}
