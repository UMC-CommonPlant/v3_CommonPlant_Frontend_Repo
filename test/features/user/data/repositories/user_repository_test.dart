import 'package:commonplant_frontend/features/user/data/datasources/user_remote_data_source.dart';
import 'package:commonplant_frontend/features/user/data/dtos/user_requests.dart';
import 'package:commonplant_frontend/features/user/data/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRepository', () {
    test('내 정보 수정은 선택된 이미지 파일을 datasource에 전달한다', () async {
      final dataSource = _ImageUpdateUserRemoteDataSource();
      final repository = UserRepository(dataSource);
      final image = MultipartFile.fromString(
        'image-bytes',
        filename: 'profile.png',
      );

      await repository.updateMe(
        const UpdateUserRequest(name: '커먼'),
        image: image,
      );

      expect(dataSource.latestImage, same(image));
    });
  });
}

class _ImageUpdateUserRemoteDataSource extends UserRemoteDataSource {
  _ImageUpdateUserRemoteDataSource() : super(Dio());

  MultipartFile? latestImage;

  @override
  Future<Object?> updateMe(
    UpdateUserRequest request, {
    MultipartFile? image,
  }) async {
    latestImage = image;

    return {
      'result': {'id': 'user-1', 'name': request.name},
    };
  }
}
