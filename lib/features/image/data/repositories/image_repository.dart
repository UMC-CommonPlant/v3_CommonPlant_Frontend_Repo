import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';
import 'package:commonplant_frontend/features/image/data/datasources/image_remote_data_source.dart';
import 'package:commonplant_frontend/features/image/data/models/image_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageRemoteDataSourceProvider = Provider<ImageRemoteDataSource>((ref) {
  return ImageRemoteDataSource(ref.watch(dioProvider));
});

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository(ref.watch(imageRemoteDataSourceProvider));
});

class ImageRepository {
  const ImageRepository(this._remoteDataSource);

  final ImageRemoteDataSource _remoteDataSource;

  Future<ImageInfo> getImage(String key) async {
    final response = await _remoteDataSource.getImage(key);
    return ImageInfo.fromJson(
      _imageResult(response, context: '이미지 조회'),
      requireImageUrl: true,
    );
  }

  Future<List<ImageInfo>> uploadImages(List<MultipartFile> images) async {
    final expectedCount = images.length;
    final response = await _remoteDataSource.uploadImages(images);
    final uploaded = _imageResult(response, context: '이미지 업로드')['images'];
    if (uploaded is! List || uploaded.length != expectedCount) {
      throw const ApiException(message: '이미지 업로드 결과가 요청한 파일 수와 다릅니다.');
    }

    return [
      for (final (index, item) in uploaded.indexed)
        if (item is JsonMap)
          ImageInfo.fromJson(item)
        else
          throw ApiException(
            message: '이미지 업로드 결과의 ${index + 1}번째 항목이 올바르지 않습니다.',
          ),
    ];
  }

  Future<ImageInfo> updateImage({
    required String key,
    required MultipartFile image,
  }) async {
    final response = await _remoteDataSource.updateImage(
      key: key,
      image: image,
    );
    return ImageInfo.fromJson(_imageResult(response, context: '이미지 수정'));
  }

  Future<void> deleteImage(String key) {
    return _remoteDataSource.deleteImage(key);
  }
}

JsonMap _imageResult(Object? data, {required String context}) {
  final result = jsonObjectFromResponse(data, context: context)['result'];
  if (result is! JsonMap) {
    throw ApiException(message: '$context 응답에 결과 객체가 없습니다.');
  }
  return result;
}
