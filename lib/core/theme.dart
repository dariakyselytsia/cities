import 'package:flutter/material.dart';

/// App theme.
///
/// PLACEHOLDER palette/typography — to be replaced by the shared visual design.
/// The structure (Material 3, seeded ColorScheme) stays; only the values change.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D32),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
  );
}
