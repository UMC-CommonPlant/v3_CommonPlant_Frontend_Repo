import 'dart:convert';

import 'package:commonplant_frontend/features/image/data/gateways/image_selection_gateway.dart';
import 'package:commonplant_frontend/features/image/data/models/selected_image.dart';

SelectedImage testSelectedImage() => SelectedImage(
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
  ),
  contentType: 'image/png',
);

class FakeImageSelectionGateway extends ImageSelectionGateway {
  FakeImageSelectionGateway(this.action);
  final Future<SelectedImage?> Function() action;
  int calls = 0;

  @override
  Future<SelectedImage?> pickImage() {
    calls++;
    return action();
  }
}
