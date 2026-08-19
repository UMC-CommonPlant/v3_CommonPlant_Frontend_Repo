import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final svgFiles = _findSvgFiles();

  test('SVG asset 목록이 비어 있지 않다', () {
    expect(svgFiles, isNotEmpty);
  });

  for (final svgFile in svgFiles) {
    test('${svgFile.path}을 파싱하고 rasterize할 수 있다', () async {
      final pictureInfo = await vg.loadPicture(SvgFileLoader(svgFile), null);
      addTearDown(pictureInfo.picture.dispose);

      expect(pictureInfo.size.width, greaterThan(0));
      expect(pictureInfo.size.height, greaterThan(0));

      final image = await pictureInfo.picture.toImage(
        pictureInfo.size.width.ceil(),
        pictureInfo.size.height.ceil(),
      );
      image.dispose();
    });
  }
}

List<File> _findSvgFiles() {
  final svgFiles = <File>[];

  for (final assetDirectory in [
    Directory('assets/icons'),
    Directory('assets/images'),
  ]) {
    svgFiles.addAll(
      assetDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.svg')),
    );
  }

  return svgFiles..sort((left, right) => left.path.compareTo(right.path));
}
