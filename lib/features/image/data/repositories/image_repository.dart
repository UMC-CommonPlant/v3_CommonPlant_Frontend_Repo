import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/features/image/data/datasources/image_remote_data_source.dart';
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

  Future<Object?> getDownloadUrlRaw(String key) {
    return _remoteDataSource.getDownloadUrlRaw(key);
  }

  Future<void> uploadImages(List<MultipartFile> images) {
    return _remoteDataSource.uploadImages(images);
  }

  Future<void> updateImage({
    required String key,
    required MultipartFile image,
  }) {
    return _remoteDataSource.updateImage(key: key, image: image);
  }

  Future<void> deleteImage(String key) {
    return _remoteDataSource.deleteImage(key);
  }
}
