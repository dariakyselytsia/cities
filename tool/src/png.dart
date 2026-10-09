// A minimal PNG writer for the tool scripts that render images
// (render_icons.dart, render_store_images.dart). dart:ui only encodes RGBA,
// and some images must have no alpha channel (an iOS app icon; store
// screenshots), so this writes 8-bit RGB or RGBA itself.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Saves [image] to [path] as a PNG: RGB when [opaque], RGBA otherwise.
Future<void> writePng(
  ui.Image image,
  String path, {
  bool opaque = false,
}) async {
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  if (data == null) throw StateError('Could not read pixels for $path');
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(
      encodePng(
        data.buffer.asUint8List(),
        image.width,
        image.height,
        alpha: !opaque,
      ),
    );
}

/// Encodes straight (not premultiplied) [rgba] pixels as a PNG: 8-bit RGB
/// or RGBA, no filtering.
Uint8List encodePng(
  Uint8List rgba,
  int width,
  int height, {
  required bool alpha,
}) {
  final channels = alpha ? 4 : 3;
  final stride = 1 + width * channels;
  final raw = Uint8List(stride * height);
  for (var y = 0; y < height; y++) {
    var o = y * stride + 1; // byte 0 of each row: filter type "none"
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      for (var c = 0; c < channels; c++) {
        raw[o++] = rgba[i + c];
      }
    }
  }

  final out = BytesBuilder()..add(const [137, 80, 78, 71, 13, 10, 26, 10]);
  void chunk(String type, List<int> data) {
    final typed = [...ascii.encode(type), ...data];
    out
      ..add(_uint32(data.length))
      ..add(typed)
      ..add(_uint32(_crc32(typed)));
  }

  chunk('IHDR', [
    ..._uint32(width),
    ..._uint32(height),
    8, // bit depth
    alpha ? 6 : 2, // color type: RGBA or RGB
    0, 0, 0, // compression, filter, interlace
  ]);
  chunk('IDAT', ZLibCodec(level: 9).encode(raw));
  chunk('IEND', const []);
  return out.takeBytes();
}

List<int> _uint32(int value) => [
  (value >> 24) & 0xFF,
  (value >> 16) & 0xFF,
  (value >> 8) & 0xFF,
  value & 0xFF,
];

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}
