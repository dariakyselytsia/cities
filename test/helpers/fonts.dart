import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the app's bundled fonts (and, with [icons], Material's icon font
/// from the Flutter SDK), so text is as wide as on a phone and icons are
/// drawn. Without this, tests use a placeholder font with square glyphs.
Future<void> loadAppFonts({bool icons = false}) async {
  for (final (family, files) in [
    ('Nunito', ['SemiBold', 'Bold', 'ExtraBold']),
    ('Rubik', ['Regular', 'Medium', 'SemiBold']),
  ]) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(_bytes('assets/fonts/$family-$file.ttf'));
    }
    await loader.load();
  }
  if (icons) {
    await (FontLoader('MaterialIcons')..addFont(_bytes(_materialIconsPath())))
        .load();
  }
}

Future<ByteData> _bytes(String path) async =>
    ByteData.sublistView(File(path).readAsBytesSync());

/// The icon font in the Flutter SDK that runs the test:
/// `<flutter>/bin/cache/artifacts/material_fonts/`.
String _materialIconsPath() {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      // The test runs on <flutter>/bin/cache/dart-sdk/bin/dart(.exe).
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  return '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf';
}
