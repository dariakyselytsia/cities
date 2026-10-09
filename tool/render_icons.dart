// Renders the app icons and native splash images from the brand mark in
// lib/core/brand.dart (T21), so they always match the in-app badge.
//
// Run from the project root (it needs the Flutter engine, hence a test):
//
//   flutter test tool/render_icons.dart
//
// It overwrites the PNGs under android/app/src/main/res and
// ios/Runner/Assets.xcassets, and store/play-icon-512.png. The XML around them (adaptive icon, splash
// themes, launch storyboard) is hand-written; see tool/README.md.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cities/core/brand.dart';
import 'package:cities/core/theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/png.dart';

/// Android density buckets and their scale from dp to px.
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

const _res = 'android/app/src/main/res';
const _xcassets = 'ios/Runner/Assets.xcassets';

/// The pin's box on the full-bleed iOS icon, as a fraction of its side.
const _iosPin = 0.6;

/// Legacy (pre-Android 8) launcher icon: a 48 dp canvas with the badge
/// 44 dp wide in it.
const _legacyCanvas = 48.0;
const _legacyBadge = 44.0;

/// Adaptive icon layers: a 108 dp canvas, of which launchers show the
/// middle 72 dp (66 dp is always safe). The pin's box is 44 dp.
const _adaptiveCanvas = 108.0;
const _adaptivePin = 44.0;

/// The splash icon: Android 12+ shows it in a 288 dp box (no icon
/// background; content within a 192 dp circle), and older Android centers
/// the same bitmap. The badge in it is 120 dp, as on the Flutter splash.
const _splashCanvas = 288.0;
const _splashBadge = 120.0;

/// The iOS launch image: the 120 pt badge alone.
const _launchBadge = 120.0;

void main() {
  test('render the app icons and splash images', () async {
    // iOS app icon: every size in AppIcon.appiconset, full-bleed and opaque
    // (the App Store rejects an icon with an alpha channel).
    final contents = jsonDecode(
      File('$_xcassets/AppIcon.appiconset/Contents.json').readAsStringSync(),
    );
    if (contents case {'images': final List<Object?> images}) {
      for (final image in images) {
        if (image case {
          'size': final String size,
          'scale': final String scale,
          'filename': final String filename,
        }) {
          final pt = double.parse(size.split('x').first);
          final px = (pt * double.parse(scale.replaceAll('x', ''))).round();
          await _write(
            '$_xcassets/AppIcon.appiconset/$filename',
            px,
            opaque: true,
            _fullBleed,
          );
        }
      }
    }

    // The Play Store's 512 × 512 icon (T22): full-bleed like iOS; Play
    // rounds it itself. Play asks for a 32-bit PNG, so it keeps alpha.
    await _write('store/play-icon-512.png', 512, _fullBleed);

    // iOS launch image, used by LaunchScreen.storyboard.
    for (final (suffix, scale) in [('', 1), ('@2x', 2), ('@3x', 3)]) {
      await _write(
        '$_xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
        (_launchBadge * scale).round(),
        (canvas, side) =>
            BrandMark.paintBadge(canvas, Rect.fromLTWH(0, 0, side, side)),
      );
    }

    for (final MapEntry(key: bucket, value: scale) in _densities.entries) {
      // Legacy launcher icon.
      await _write(
        '$_res/mipmap-$bucket/ic_launcher.png',
        (_legacyCanvas * scale).round(),
        (canvas, side) =>
            _centeredBadge(canvas, side, side * _legacyBadge / _legacyCanvas),
      );
      // Adaptive icon: the white pin over a coral background (a color
      // resource); the monochrome layer is the same pin, tinted by the
      // launcher for themed icons (Android 13+).
      for (final layer in ['foreground', 'monochrome']) {
        await _write(
          '$_res/mipmap-$bucket/ic_launcher_$layer.png',
          (_adaptiveCanvas * scale).round(),
          (canvas, side) => BrandMark.paintPin(
            canvas,
            Offset(side / 2, side / 2),
            side * _adaptivePin / _adaptiveCanvas,
          ),
        );
      }
      // Splash icon.
      await _write(
        '$_res/drawable-$bucket/splash_icon.png',
        (_splashCanvas * scale).round(),
        (canvas, side) =>
            _centeredBadge(canvas, side, side * _splashBadge / _splashCanvas),
      );
    }
  });
}

/// The coral square edge to edge with the pin: the iOS and store icons.
void _fullBleed(Canvas canvas, double side) {
  canvas.drawRect(
    Rect.fromLTWH(0, 0, side, side),
    Paint()..color = AppColors.coral,
  );
  BrandMark.paintPin(canvas, Offset(side / 2, side / 2), side * _iosPin);
}

/// The badge [badge] wide in the middle of a [side]-wide canvas.
void _centeredBadge(Canvas canvas, double side, double badge) {
  final inset = (side - badge) / 2;
  BrandMark.paintBadge(canvas, Rect.fromLTWH(inset, inset, badge, badge));
}

/// Paints a [px]-square image and saves it to [path] as a PNG: RGB when
/// [opaque], RGBA otherwise.
Future<void> _write(
  String path,
  int px,
  void Function(Canvas canvas, double side) paint, {
  bool opaque = false,
}) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder), px.toDouble());
  final image = await recorder.endRecording().toImage(px, px);
  await writePng(image, path, opaque: opaque);
  image.dispose();
}
