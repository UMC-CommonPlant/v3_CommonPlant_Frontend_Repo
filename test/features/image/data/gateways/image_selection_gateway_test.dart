import 'dart:async';
import 'dart:convert';
import 'dart:typed_data' show Endian;
import 'dart:ui' as ui;

import 'package:commonplant_frontend/core/config/image_upload_limits.dart';
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

  test('JPEG EXIF의 GPS를 빼고 회전 정보와 압축 이미지 데이터는 유지한다', () async {
    final fixture = await rootBundle.load(
      'assets/images/place_edit_living_room.jpg',
    );
    final original = fixture.buffer.asUint8List(
      fixture.offsetInBytes,
      fixture.lengthInBytes,
    );
    final metadata = _jpegLocationMetadata();
    final withLocation = Uint8List.fromList([
      ...original.take(2),
      ...metadata,
      ...original.skip(2),
    ]);

    final upload = await _photoUpload(withLocation, 'garden.jpg');
    expect(upload[3], 0xe1);
    expect(ByteData.sublistView(upload).getUint16(4), 34);
    expect(ByteData.sublistView(upload).getUint16(20), 1);
    expect(ByteData.sublistView(upload).getUint16(22), 0x112);
    expect(ByteData.sublistView(upload).getUint16(30), 6);
    expect(List<int>.of(withLocation.skip(2).take(metadata.length)), metadata);

    final codec = await ui.instantiateImageCodec(upload);
    final frame = await codec.getNextFrame();
    try {
      expect(frame.image.width, 400);
      expect(frame.image.height, 600);
    } finally {
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('PNG 텍스트 위치 정보를 제거한 사본을 multipart에 사용한다', () async {
    final original = testSelectedImage().bytes;
    final textChunk = base64Decode(
      'AAAAHHRFWHRHUFNMYXRpdHVkZQBwcml2YXRlLWxvY2F0aW9uY/yXAw==',
    );
    final withLocation = Uint8List.fromList([
      ...original.take(33),
      ...textChunk,
      ...original.skip(33),
    ]);

    expect(await _photoUpload(withLocation, 'garden.png'), original);
  });

  test('WebP XMP와 EXIF를 제거하고 RIFF 길이와 플래그를 갱신한다', () async {
    final original = base64Decode(
      'UklGRiIAAABXRUJQVlA4IBYAAAAwAQCdASoBAAEADsD+JaQAA3AAAAAA',
    );
    final header = [
      ...ascii.encode('VP8X'),
      10,
      0,
      0,
      0,
      0x0c,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ];
    final withLocation = Uint8List.fromList([
      ...original.take(12),
      ...header,
      ...original.skip(12),
      ...ascii.encode('XMP '),
      4,
      0,
      0,
      0,
      ...ascii.encode('GPS!'),
      ...ascii.encode('EXIF'),
      4,
      0,
      0,
      0,
      ...ascii.encode('GPS!'),
    ]);
    ByteData.sublistView(
      withLocation,
    ).setUint32(4, withLocation.length - 8, Endian.little);

    final upload = await _photoUpload(withLocation, 'garden.webp');

    expect(
      ByteData.sublistView(upload).getUint32(4, Endian.little),
      upload.length - 8,
    );
    expect(upload[20], 0);
    expect(upload.skip(30), original.skip(12));
    expect(withLocation[20], 0x0c);
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

Future<Uint8List> _photoUpload(Uint8List bytes, String name) async {
  final photo = await ImageSelectionGateway().readImage(
    XFile.fromData(bytes, name: name),
  );
  return Uint8List.fromList(
    await photo.toMultipartFile().finalize().expand((bytes) => bytes).toList(),
  );
}

Uint8List _jpegLocationMetadata() {
  final tiff = ByteData(56)
    ..setUint16(0, 0x4d4d)
    ..setUint16(2, 42)
    ..setUint32(4, 8)
    ..setUint16(8, 2)
    ..setUint16(10, 0x112)
    ..setUint16(12, 3)
    ..setUint32(14, 1)
    ..setUint16(18, 6)
    ..setUint16(22, 0x8825)
    ..setUint16(24, 4)
    ..setUint32(26, 1)
    ..setUint32(30, 38)
    ..setUint16(38, 1)
    ..setUint16(40, 1)
    ..setUint16(42, 2)
    ..setUint32(44, 2)
    ..setUint8(48, 0x4e);
  return Uint8List.fromList([
    0xff,
    0xe1,
    0,
    64,
    ...ascii.encode('Exif'),
    0,
    0,
    ...tiff.buffer.asUint8List(),
  ]);
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
