import 'package:flutter/widgets.dart';

import 'theme.dart';

/// The brand mark (T21): a white map pin on a coral badge. It's the badge on
/// Home and the splash, and the app icon.
///
/// It's drawn as a path rather than the Material icon font so that
/// `tool/render_icons.dart` paints exactly the same shape into the launcher
/// icons and the native splash images.
abstract final class BrandMark {
  /// Corner radius of the badge, as a fraction of its side.
  static const double badgeRadius = 0.3;

  /// The pin's 24-unit box, as a fraction of the badge's side.
  static const double badgePin = 0.57;

  /// The pin (Material's rounded `location_on`) in a 24 × 24 box, with its
  /// dot cut out.
  static Path _pin24() => Path()
    ..moveTo(12, 2)
    ..cubicTo(7.8, 2, 4, 5.22, 4, 10.2)
    ..cubicTo(4, 13.38, 6.45, 17.12, 11.34, 21.43)
    ..cubicTo(11.72, 21.76, 12.29, 21.76, 12.67, 21.43)
    ..cubicTo(17.55, 17.12, 20, 13.38, 20, 10.2)
    ..cubicTo(20, 5.22, 16.2, 2, 12, 2)
    ..close()
    ..addOval(Rect.fromCircle(center: const Offset(12, 10), radius: 2))
    ..fillType = PathFillType.evenOdd;

  /// Paints the pin with its 24-unit box [boxSide] wide, centered on
  /// [center].
  static void paintPin(
    Canvas canvas,
    Offset center,
    double boxSide, {
    Color color = const Color(0xFFFFFFFF),
  }) {
    final scale = boxSide / 24;
    canvas
      ..save()
      ..translate(center.dx - boxSide / 2, center.dy - boxSide / 2)
      ..scale(scale)
      ..drawPath(
        _pin24(),
        Paint()
          ..color = color
          ..isAntiAlias = true,
      )
      ..restore();
  }

  /// Paints the badge filling [rect]: a coral square with corners of
  /// [cornerRadius] (a fraction of the side; 0 for the full-bleed iOS icon)
  /// and the pin's box [pin] of the side.
  static void paintBadge(
    Canvas canvas,
    Rect rect, {
    double cornerRadius = badgeRadius,
    double pin = badgePin,
  }) {
    final side = rect.shortestSide;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(side * cornerRadius)),
      Paint()
        ..color = AppColors.coral
        ..isAntiAlias = true,
    );
    paintPin(canvas, rect.center, side * pin);
  }
}

/// The brand badge as a widget, with the coral glow: Home's hero and the
/// splash.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * BrandMark.badgeRadius),
        boxShadow: AppColors.coralGlow,
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: const _BadgePainter(),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  const _BadgePainter();

  @override
  void paint(Canvas canvas, Size size) =>
      BrandMark.paintBadge(canvas, Offset.zero & size);

  @override
  bool shouldRepaint(_BadgePainter oldDelegate) => false;
}
