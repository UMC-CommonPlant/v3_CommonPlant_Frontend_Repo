import 'dart:ui' as ui;

import 'package:commonplant_frontend/features/image/data/models/selected_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

const imageMaxSizeBytes = 10 * 1024 * 1024;
const imageSelectionFailureMessage = '사진을 불러오지 못했어요. 다시 선택해 주세요.';

final imageSelectionGatewayProvider = Provider(
  (ref) => ImageSelectionGateway(),
);

class ImageSelectionException implements Exception {
  const ImageSelectionException(this.message);
  final String message;
}

class ImageSelectionGateway {
  ImageSelectionGateway({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  bool _isPicking = false;

  Future<SelectedImage?> pickImage() async {
    if (_isPicking) return null;
    _isPicking = true;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      return file == null ? null : await readImage(file);
    } on ImageSelectionException {
      rethrow;
    } on PlatformException catch (error) {
      if (error.code == 'photo_access_denied' ||
          error.code == 'photo_access_restricted') {
        throw const ImageSelectionException(
          '사진 접근이 제한되어 있어요. 기기 설정에서 접근 권한을 확인해 주세요.',
        );
      }
      throw const ImageSelectionException(imageSelectionFailureMessage);
    } catch (_) {
      throw const ImageSelectionException(imageSelectionFailureMessage);
    } finally {
      _isPicking = false;
    }
  }

  Future<SelectedImage> readImage(XFile file) async {
    final length = await file.length();
    if (length == 0 || length > imageMaxSizeBytes) {
      throw const ImageSelectionException('10MB 이하의 사진을 선택해 주세요.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > imageMaxSizeBytes) {
      throw const ImageSelectionException('10MB 이하의 사진을 선택해 주세요.');
    }
    // 확장자나 OS가 제공한 MIME만으로 파일 형식을 신뢰하지 않는다.
    final type = _contentType(bytes);
    if (type == null) {
      throw const ImageSelectionException('JPG, PNG, WebP 사진을 선택해 주세요.');
    }
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1,
        targetHeight: 1,
      );
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
    } catch (_) {
      throw const ImageSelectionException('손상된 사진이에요. 다른 사진을 선택해 주세요.');
    }
    return SelectedImage(bytes: bytes, contentType: type);
  }
}

String? _contentType(Uint8List bytes) {
  bool startsWith(List<int> signature) =>
      bytes.length >= signature.length &&
      listEquals(bytes.sublist(0, signature.length), signature);
  if (startsWith([0xff, 0xd8, 0xff])) return 'image/jpeg';
  if (startsWith([137, 80, 78, 71, 13, 10, 26, 10])) return 'image/png';
  if (startsWith([82, 73, 70, 70]) &&
      bytes.length >= 12 &&
      listEquals(bytes.sublist(8, 12), [87, 69, 66, 80])) {
    return 'image/webp';
  }
  return null;
}

/// 프로세스 종료로 사라진 폼의 결과를 다른 폼이나 계정에 연결하지 않는다.
/// 현재 폼 초안은 영속 저장하지 않으므로 재실행 후에는 다시 선택해야 한다.
Future<void> discardOrphanedImageSelection() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await ImagePicker().retrieveLostData();
  } on PlatformException {
    // 복구 실패가 앱 시작이나 새 사진 선택을 차단하지 않게 한다.
  }
}
