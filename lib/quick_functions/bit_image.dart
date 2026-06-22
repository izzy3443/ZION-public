import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createResizedBitmapDescriptor({
  required String assetPath,
  required double height,
}) async {
  final ByteData data = await rootBundle.load(assetPath);
  final Uint8List bytes = data.buffer.asUint8List();

  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    targetHeight: height.toInt(),
  );

  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  final ByteData? resizedByteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(resizedBytes);
}
