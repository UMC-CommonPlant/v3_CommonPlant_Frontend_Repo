import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/mappers/place_mapper.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:commonplant_frontend/features/place/domain/repositories/place_repository.dart';
import 'package:dio/dio.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  const PlaceRepositoryImpl(this._remoteDataSource);

  final PlaceRemoteDataSource _remoteDataSource;

  @override
  Future<List<PlaceSummary>> fetchMyGardenPlaces() async {
    final data = await _remoteDataSource.getMyGarden();

    return placeSummariesFromResponse(data);
  }

  @override
  Future<List<PlaceSummary>> fetchUserPlaces() async {
    final data = await _remoteDataSource.getUserPlaces();

    return placeSummariesFromResponse(data);
  }

  @override
  Future<PlaceSummary> fetchPlace(String code) async {
    final data = await _remoteDataSource.getPlace(code);

    return placeSummaryFromResponse(data, fallbackId: code);
  }

  @override
  Future<PlaceDetail> fetchPlaceDetail(String code) async {
    final data = await _remoteDataSource.getPlace(code);

    return placeDetailFromResponse(data, fallbackCode: code);
  }

  @override
  Future<List<PlaceMember>> fetchPlaceMembers(String code) async {
    final data = await _remoteDataSource.getPlaceMembers(code);

    return placeMembersFromResponse(data);
  }

  @override
  Future<String> createPlace({
    required String name,
    required String address,
    MultipartFile? image,
  }) async {
    final request = CreatePlaceRequest(name: name, address: address);
    final data = await _remoteDataSource.createPlace(request, image: image);

    return placeCodeFromCreateResponse(data);
  }

  @override
  Future<PlaceSummary> updatePlace({
    required String code,
    required String name,
    required String address,
    String? imageKey,
    MultipartFile? image,
  }) async {
    final request = UpdatePlaceRequest(
      name: name,
      address: address,
      imageKey: imageKey,
    );

    final data = await _remoteDataSource.updatePlace(
      code: code,
      request: request,
      image: image,
    );

    return updatedPlaceFromResponse(data, fallbackCode: code);
  }

  @override
  Future<void> deletePlace(String code) {
    return _remoteDataSource.deletePlace(code);
  }
}
