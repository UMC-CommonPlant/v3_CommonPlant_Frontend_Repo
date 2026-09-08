import 'package:commonplant_frontend/features/place/domain/entities/place_detail.dart';
import 'package:commonplant_frontend/features/place/domain/entities/place_summary.dart';
import 'package:dio/dio.dart';

abstract interface class PlaceRepository {
  Future<List<PlaceSummary>> fetchMyGardenPlaces();

  Future<List<PlaceSummary>> fetchUserPlaces();

  Future<PlaceSummary> fetchPlace(String code);

  Future<PlaceDetail> fetchPlaceDetail(String code);

  Future<List<PlaceMember>> fetchPlaceMembers(String code);

  Future<String> createPlace({
    MultipartFile? image,
    required String name,
    required String address,
  });

  Future<PlaceSummary> updatePlace({
    MultipartFile? image,
    required String code,
    required String name,
    required String address,
    String? imageKey,
  });

  Future<void> deletePlace(String code);
}
