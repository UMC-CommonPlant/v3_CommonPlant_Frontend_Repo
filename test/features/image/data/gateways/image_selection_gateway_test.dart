import 'dart:async';

import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../helpers/image_selection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('파일 내용으로 MIME을 확인하고 재시도마다 독립 multipart를 만든다', () async {
    final image = await ImageSelectionGateway().readImage(
      XFile.fromData(
        testSelectedImage().bytes,
        name: 'misleading.heic',
        mimeType: 'image/heic',
      ),
    );
    expect(image.contentType, 'image/png');
    final first = image.toMultipartFile();
    final second = image.toMultipartFile();
    expect(first.contentType.toString(), 'image/png');
    expect(first.filename, 'photo.png');
    expect(
      await first.finalize().expand((bytes) => bytes).toList(),
      image.bytes,
    );
    expect(
      await second.finalize().expand((bytes) => bytes).toList(),
      image.bytes,
    );
  });

  test('빈 파일·10MB 초과·미지원 형식·손상된 파일은 거부한다', () async {
    final gateway = ImageSelectionGateway();
    for (final data in [
      Uint8List(0),
      Uint8List(imageMaxSizeBytes + 1),
      Uint8List.fromList([1, 2, 3]),
      Uint8List.fromList([0xff, 0xd8, 0xff, 0]),
    ]) {
      await expectLater(
        gateway.readImage(XFile.fromData(data, name: 'fake.jpg')),
        throwsA(isA<ImageSelectionException>()),
      );
    }
  });

  test('중복 선택을 막고 취소 뒤 다시 열 수 있다', () async {
    final pending = Completer<XFile?>();
    final picker = _Picker(() => pending.future);
    final gateway = ImageSelectionGateway(picker: picker);
    final first = gateway.pickImage();
    expect(await gateway.pickImage(), isNull);
    expect(picker.calls, 1);
    pending.complete(null);
    expect(await first, isNull);
    expect(await gateway.pickImage(), isNull);
    expect(picker.calls, 2);
  });

  test('권한 오류·SDK 오류는 사용자 안내로 바꾸고 선택 잠금을 해제한다', () async {
    for (final code in [
      'photo_access_denied',
      'photo_access_restricted',
      'unknown',
    ]) {
      final picker = _Picker(
        () => Future.error(
          PlatformException(code: code, message: 'private path'),
        ),
      );
      final gateway = ImageSelectionGateway(picker: picker);
      await expectLater(
        gateway.pickImage(),
        throwsA(
          isA<ImageSelectionException>().having(
            (e) => e.message,
            'message',
            isNot(contains('private path')),
          ),
        ),
      );
      await expectLater(
        gateway.pickImage(),
        throwsA(isA<ImageSelectionException>()),
      );
      expect(picker.calls, 2);
    }
  });
}

class _Picker extends ImagePicker {
  _Picker(this.action);
  final Future<XFile?> Function() action;
  int calls = 0;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
    expect(source, ImageSource.gallery);
    expect(requestFullMetadata, isFalse);
    calls++;
    return action();
  }
}
