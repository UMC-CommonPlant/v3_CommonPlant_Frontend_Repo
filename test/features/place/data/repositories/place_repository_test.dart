import 'package:commonplant_frontend/features/place/data/datasources/place_remote_data_source.dart';
import 'package:commonplant_frontend/features/place/data/dtos/place_requests.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceRepository', () {
    test('myGarden 응답의 장소 목록을 반환한다', () async {
      final repository = PlaceRepositoryImpl(
        _ResponsePlaceRemoteDataSource(
          myGardenResponse: {
            'result': {
              'name': '커먼이',
              'placeList': [
                {'code': 'place-1', 'name': '거실', 'member': '2'},
              ],
            },
          },
        ),
      );

      final places = await repository.fetchMyGardenPlaces();

      expect(places.single.id, 'place-1');
      expect(places.single.name, '거실');
      expect(places.single.memberCount, 2);
    });

    test('장소 상세 응답을 멤버와 식물 도메인 모델로 반환한다', () async {
      final repository = PlaceRepositoryImpl(
        _ResponsePlaceRemoteDataSource(
          placeResponse: {
            'result': {
              'code': 'place-1',
              'name': '거실',
              'address': '서울시',
              'owner': true,
              'userList': [
                {'name': '커먼맘'},
              ],
              'plantList': [
                {'plantId': 1, 'scientificNameKo': '몬스테라'},
              ],
            },
          },
        ),
      );

      final detail = await repository.fetchPlaceDetail('place-1');

      expect(detail.code, 'place-1');
      expect(detail.isOwner, isTrue);
      expect(detail.members.single.name, '커먼맘');
      expect(detail.plants.single.id, '1');
    });

    test('장소 생성은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlaceRemoteDataSource();
      final repository = PlaceRepositoryImpl(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'place.png',
      );

      final code = await repository.createPlace(
        name: '거실',
        address: '서울시 성북구',
        image: image,
      );

      expect(code, 'created-place');
      expect(dataSource.latestCreateImage, same(image));
      expect(dataSource.latestCreateRequest?.toJson(), {
        'name': '거실',
        'address': '서울시 성북구',
      });
    });

    test('장소 수정은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImagePlaceRemoteDataSource();
      final repository = PlaceRepositoryImpl(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'place.png',
      );

      final place = await repository.updatePlace(
        code: 'place-1',
        name: '거실',
        address: '서울시 성북구',
        image: image,
      );

      expect(place.id, 'place-1');
      expect(place.name, '거실');
      expect(place.imageUrl, 'https://example.com/place.png');
      expect(dataSource.latestUpdateImage, same(image));
      expect(dataSource.latestUpdateRequest?.toJson(), {
        'name': '거실',
        'address': '서울시 성북구',
      });
    });
  });
}

class _ResponsePlaceRemoteDataSource extends Fake
    implements PlaceRemoteDataSource {
  _ResponsePlaceRemoteDataSource({this.myGardenResponse, this.placeResponse});

  final Object? myGardenResponse;
  final Object? placeResponse;

  @override
  Future<Object?> getMyGarden() async => myGardenResponse;

  @override
  Future<Object?> getPlace(String code) async => placeResponse;
}

class _ImagePlaceRemoteDataSource extends Fake
    implements PlaceRemoteDataSource {
  CreatePlaceRequest? latestCreateRequest;
  UpdatePlaceRequest? latestUpdateRequest;
  MultipartFile? latestCreateImage;
  MultipartFile? latestUpdateImage;

  @override
  Future<Object?> createPlace(
    CreatePlaceRequest request, {
    MultipartFile? image,
  }) async {
    latestCreateRequest = request;
    latestCreateImage = image;

    return {'result': 'created-place'};
  }

  @override
  Future<Object?> updatePlace({
    required String code,
    required UpdatePlaceRequest request,
    MultipartFile? image,
  }) async {
    latestUpdateRequest = request;
    latestUpdateImage = image;

    return {
      'result': {
        'code': code,
        'name': request.name,
        'address': request.address,
        'imgUrl': 'https://example.com/place.png',
      },
    };
  }
}
