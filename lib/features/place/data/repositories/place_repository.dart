import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
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
    final items = jsonListFromResponse(data, context: '내 정원 조회');

    return [for (final item in items) placeSummaryFromJson(item)];
  }

  Future<List<PlaceSummary>> fetchUserPlaces() async {
    final data = await _remoteDataSource.getUserPlaces();
    final items = jsonListFromResponse(data, context: '소속 장소 조회');

    return [for (final item in items) placeSummaryFromJson(item)];
  }

  Future<PlaceSummary> fetchPlace(String code) async {
    final data = await _remoteDataSource.getPlace(code);
    final object = unwrapJsonObject(data, context: '장소 조회');

    return placeSummaryFromJson(object, fallbackId: code);
  }

  Future<void> createPlace(CreatePlaceRequest request) {
    return _remoteDataSource.createPlace(request);
  }

  Future<void> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
  }) {
    return _remoteDataSource.updatePlace(code: code, request: request);
  }

  Future<void> deletePlace(String code) {
    return _remoteDataSource.deletePlace(code);
  }
}

PlaceSummary placeSummaryFromJson(JsonMap json, {String? fallbackId}) {
  return PlaceSummary(
    id:
        readOptionalString(json, const [
          'id',
          'placeId',
          'code',
          'placeCode',
        ]) ??
        fallbackId ??
        readRequiredString(json, const ['nanoId'], '장소 ID'),
    name: readRequiredString(json, const ['name', 'placeName'], '장소 이름'),
    address: readOptionalString(json, const ['address', 'placeAddress']),
  );
}
