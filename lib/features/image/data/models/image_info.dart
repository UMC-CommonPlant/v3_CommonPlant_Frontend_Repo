import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/api_response_parser.dart';

class ImageInfo {
  const ImageInfo({
    required this.key,
    required this.contentType,
    required this.sizeBytes,
    this.placeId,
    this.imageUrl,
  });

  factory ImageInfo.fromJson(JsonMap json, {bool requireImageUrl = false}) {
    final key = json['key'];
    final contentType = json['contentType'];
    final sizeBytes = json['sizeBytes'];
    final placeId = json['placeId'];
    final imageUrl = json['imageUrl'];

    if (key is! String ||
        key.trim().isEmpty ||
        contentType is! String ||
        contentType.trim().isEmpty ||
        sizeBytes is! int ||
        sizeBytes < 0 ||
        (placeId != null && placeId is! int)) {
      throw const ApiException(message: '이미지 응답의 메타데이터가 올바르지 않습니다.');
    }

    if (imageUrl != null || requireImageUrl) {
      final uri = imageUrl is String ? Uri.tryParse(imageUrl) : null;
      if (uri == null ||
          (uri.scheme != 'https' && uri.scheme != 'http') ||
          uri.host.isEmpty) {
        throw const ApiException(message: '이미지 응답에 유효한 공개 URL이 없습니다.');
      }
    }

    return ImageInfo(
      key: key,
      contentType: contentType,
      sizeBytes: sizeBytes,
      placeId: placeId as int?,
      imageUrl: imageUrl as String?,
    );
  }

  final String key;
  final String contentType;
  final int sizeBytes;
  final int? placeId;
  final String? imageUrl;
}
