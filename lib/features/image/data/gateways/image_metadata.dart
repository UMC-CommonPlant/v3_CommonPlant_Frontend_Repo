import 'dart:typed_data';

/// Keeps the encoded image data and display orientation. Coordinates and other
/// free-form metadata are discarded from the copy that will be uploaded.
Uint8List stripImageLocationMetadata(Uint8List bytes, String contentType) {
  return switch (contentType) {
    'image/jpeg' => _stripJpeg(bytes),
    'image/png' => _stripPng(bytes),
    'image/webp' => _stripWebp(bytes),
    _ => throw const FormatException('Unsupported image format'),
  };
}

const _exifPrefix = [0x45, 0x78, 0x69, 0x66, 0, 0];
const _iccProfilePrefix = [
  0x49,
  0x43,
  0x43,
  0x5f,
  0x50,
  0x52,
  0x4f,
  0x46,
  0x49,
  0x4c,
  0x45,
  0,
];

Uint8List _stripJpeg(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final output = BytesBuilder(copy: false)..add([0xff, 0xd8]);
  var offset = 2;
  while (offset < bytes.length) {
    final start = offset;
    if (bytes[offset++] != 0xff) break;
    while (offset < bytes.length && bytes[offset] == 0xff) {
      offset++;
    }
    if (offset == bytes.length) break;
    final marker = bytes[offset++];
    if (marker == 0xd9) {
      return (output..add([0xff, 0xd9])).takeBytes();
    }
    if (marker == 0x01) {
      output.add(_slice(bytes, start, offset));
      continue;
    }
    if (offset + 2 > bytes.length) break;
    final segmentLength = data.getUint16(offset);
    final end = offset + segmentLength;
    if (segmentLength < 2 || end > bytes.length) break;
    final payload = _slice(bytes, offset + 2, end);

    if (marker == 0xe1 && _startsWith(payload, _exifPrefix)) {
      final orientation = _orientationExif(_slice(payload, _exifPrefix.length));
      if (orientation != null) {
        output.add([
          0xff,
          0xe1,
          0,
          2 + _exifPrefix.length + orientation.length,
        ]);
        output.add(_exifPrefix);
        output.add(orientation);
      }
    } else if (_keepJpegSegment(marker, payload)) {
      output.add(_slice(bytes, start, end));
    }

    offset = end;
    if (marker == 0xda) {
      offset = _jpegScanEnd(bytes, offset);
      output.add(_slice(bytes, end, offset));
    }
  }
  throw const FormatException('Invalid JPEG segments');
}

bool _keepJpegSegment(int marker, Uint8List payload) {
  if (marker == 0xfe) return false; // COM
  if (marker < 0xe0 || marker > 0xef) return true;
  return switch (marker) {
    0xe0 => _startsWith(payload, const [0x4a, 0x46, 0x49, 0x46, 0]), // JFIF
    0xe2 => _startsWith(payload, _iccProfilePrefix),
    0xee => _startsWith(payload, const [0x41, 0x64, 0x6f, 0x62, 0x65]), // Adobe
    _ => false,
  };
}

int _jpegScanEnd(Uint8List bytes, int offset) {
  while (offset < bytes.length) {
    if (bytes[offset++] != 0xff) continue;
    final start = offset - 1;
    while (offset < bytes.length && bytes[offset] == 0xff) {
      offset++;
    }
    if (offset == bytes.length) return start;
    final marker = bytes[offset];
    // Stuffed bytes and restart markers are part of the compressed scan.
    if (marker != 0 && !(0xd0 <= marker && marker <= 0xd7)) return start;
    offset++;
  }
  return offset;
}

const _pngExif = 0x65584966; // eXIf
const _pngEnd = 0x49454e44; // IEND
const _pngTextChunks = {0x74455874, 0x7a545874, 0x69545874}; // tEXt, zTXt, iTXt

Uint8List _stripPng(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final output = BytesBuilder(copy: false)..add(_slice(bytes, 0, 8));
  var offset = 8;
  while (offset + 12 <= bytes.length) {
    final length = data.getUint32(offset);
    final type = data.getUint32(offset + 4);
    final payloadStart = offset + 8;
    final end = payloadStart + length + 4;
    if (end > bytes.length) break;

    if (type == _pngExif) {
      final orientation = _orientationExif(
        _slice(bytes, payloadStart, end - 4),
      );
      if (orientation != null) {
        output.add(_encodePngExif(orientation));
      }
    } else if (!_pngTextChunks.contains(type)) {
      output.add(_slice(bytes, offset, end));
    }
    if (type == _pngEnd && length == 0) return output.takeBytes();
    offset = end;
  }
  throw const FormatException('Invalid PNG chunks');
}

Uint8List _encodePngExif(Uint8List payload) {
  final chunk = Uint8List(payload.length + 12);
  final data = ByteData.sublistView(chunk)
    ..setUint32(0, payload.length)
    ..setUint32(4, _pngExif);
  chunk.setRange(8, 8 + payload.length, payload);
  var crc = 0xffffffff;
  for (var index = 4; index < chunk.length - 4; index++) {
    crc ^= chunk[index];
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc >>> 1) ^ (crc.isOdd ? 0xedb88320 : 0);
    }
  }
  data.setUint32(chunk.length - 4, crc ^ 0xffffffff);
  return chunk;
}

const _webpExtended = 0x56503858; // VP8X
const _webpExif = 0x45584946; // EXIF
const _webpXmp = 0x584d5020; // XMP

Uint8List _stripWebp(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final end = 8 + data.getUint32(4, Endian.little);
  if (end < 12 || end > bytes.length) {
    throw const FormatException('Invalid WebP RIFF length');
  }
  final output = BytesBuilder(copy: false)..add(_slice(bytes, 0, 12));
  int? extendedFlags;
  var keepsExif = false;
  var offset = 12;
  while (offset + 8 <= end) {
    final type = data.getUint32(offset);
    final size = data.getUint32(offset + 4, Endian.little);
    final payloadStart = offset + 8;
    final next = payloadStart + size + (size.isOdd ? 1 : 0);
    if (next > end) break;

    if (type == _webpExif) {
      final payload = _slice(bytes, payloadStart, payloadStart + size);
      final hasPrefix = _startsWith(payload, _exifPrefix);
      final orientation = _orientationExif(
        hasPrefix ? _slice(payload, _exifPrefix.length) : payload,
      );
      if (orientation != null) {
        final header = ByteData(8)
          ..setUint32(0, _webpExif)
          ..setUint32(
            4,
            orientation.length + (hasPrefix ? _exifPrefix.length : 0),
            Endian.little,
          );
        output.add(header.buffer.asUint8List());
        if (hasPrefix) output.add(_exifPrefix);
        output.add(orientation);
        keepsExif = true;
      }
    } else if (type != _webpXmp) {
      if (type == _webpExtended && size == 10) {
        extendedFlags = output.length + 8;
      }
      output.add(_slice(bytes, offset, next));
    }
    offset = next;
  }
  if (offset != end) throw const FormatException('Invalid WebP chunks');
  final result = output.takeBytes();
  ByteData.sublistView(result).setUint32(4, result.length - 8, Endian.little);
  if (extendedFlags != null) {
    result[extendedFlags] &= keepsExif ? 0xfb : 0xf3;
  }
  return result;
}

/// Rebuilds a TIFF directory containing just the standard orientation tag.
Uint8List? _orientationExif(Uint8List tiff) {
  if (tiff.length < 8) return null;
  final data = ByteData.sublistView(tiff);
  final endian = switch (data.getUint16(0)) {
    0x4949 => Endian.little,
    0x4d4d => Endian.big,
    _ => null,
  };
  if (endian == null || data.getUint16(2, endian) != 42) return null;
  final directory = data.getUint32(4, endian);
  if (directory < 8 || directory + 2 > tiff.length) return null;
  final count = data.getUint16(directory, endian);
  if (directory + 2 + count * 12 > tiff.length) return null;
  for (var index = 0; index < count; index++) {
    final tag = directory + 2 + index * 12;
    if (data.getUint16(tag, endian) != 0x112 ||
        data.getUint16(tag + 2, endian) != 3 ||
        data.getUint32(tag + 4, endian) != 1) {
      continue;
    }
    final orientation = data.getUint16(tag + 8, endian);
    if (orientation < 2 || orientation > 8) return null;
    final clean = ByteData(26)
      ..setUint16(0, 0x4d4d)
      ..setUint16(2, 42)
      ..setUint32(4, 8)
      ..setUint16(8, 1)
      ..setUint16(10, 0x112)
      ..setUint16(12, 3)
      ..setUint32(14, 1)
      ..setUint16(18, orientation);
    return clean.buffer.asUint8List();
  }
  return null;
}

Uint8List _slice(Uint8List bytes, int start, [int? end]) =>
    Uint8List.sublistView(bytes, start, end);

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}
