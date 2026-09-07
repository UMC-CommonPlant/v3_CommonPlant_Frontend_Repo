import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 폼이 보관하는 업로드 초안. 제출할 때마다 새 multipart stream을 만든다.
class SelectedImage {
  SelectedImage({required Uint8List bytes, required this.contentType})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  final Uint8List bytes;
  final String contentType;

  MultipartFile toMultipartFile() => MultipartFile.fromBytes(
    bytes,
    filename:
        'photo.${contentType == 'image/jpeg' ? 'jpg' : contentType.split('/').last}',
    contentType: DioMediaType.parse(contentType),
  );
}
