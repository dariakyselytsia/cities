import 'package:flutter/material.dart';

/// Design tokens for the "Cities" vibrant/playful palette (from the shared
/// design file). Text is dark slate on warm cream; primary actions are coral,
/// secondary are teal, with yellow/purple accents.
abstract final class AppColors {
  static const Color coral = Color(0xFFFF6B5B); // primary / brand CTA
  static const Color teal = Color(0xFF17B0A6); // secondary CTA
  static const Color yellow = Color(0xFFFFE9A8); // highlight accent
  static const Color purple = Color(0xFF5B3AA8); // accent
  static const Color green = Color(0xFF2FB16B); // success / player accent
  static const Color tealDark = Color(0xFF0D6D66);

  static const Color background = Color(0xFFFBF7F0); // app surface (cream)
  static const Color surfaceAlt = Color(0xFFEDEAE3); // slightly deeper cream
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF22303A); // primary text
  static const Color inkSoft = Color(0xFF5B6770); // muted text
  static const Color disabled = Color(0xFFCFCABF); // muted/disabled CTA

  // Rejection banner (wrong / used / unknown answer).
  static const Color rejectionBg = Color(0xFFFFE1DC);
  static const Color rejectionInk = Color(0xFFA1341C);

  /// Colored glow shadows for primary/secondary buttons.
  static const List<BoxShadow> coralGlow = [
    BoxShadow(color: Color(0x59FF6B5B), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const List<BoxShadow> tealGlow = [
    BoxShadow(color: Color(0x4D17B0A6), blurRadius: 24, offset: Offset(0, 10)),
  ];
}

/// Corner radii used across the design (very rounded, friendly).
abstract final class AppRadii {
  static const double button = 24;
  static const double card = 24;
  static const double input = 18;
  static const double hero = 44;
}

/// Bundled font families (see `pubspec.yaml`). Both cover Cyrillic — the
/// design's original Baloo 2 / Poppins don't, so Ukrainian text fell back to
/// the system font.
abstract final class AppFonts {
  /// Rounded display face for the logo, headings, and button labels.
  /// Bundled weights: 600, 700, 800.
  static const String heading = 'Nunito';

  /// Body and label text. Bundled weights: 400, 500, 600.
  static const String body = 'Rubik';
}

/// Heading style (Nunito) for the logo, headings, and button labels.
TextStyle heading({
  double? size,
  FontWeight weight = FontWeight.w700,
  Color color = AppColors.ink,
}) =>
    TextStyle(
      fontFamily: AppFonts.heading,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

/// Builds the app [ThemeData]: Rubik body, Nunito headings, coral/teal
/// accents, rounded components.
ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.coral,
    onPrimary: Colors.white,
    secondary: AppColors.teal,
    onSecondary: Colors.white,
    tertiary: AppColors.purple,
    onTertiary: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.ink,
    error: Color(0xFFB3261E),
    onError: Colors.white,
  );

  final baseText = ThemeData.light().textTheme.apply(
    fontFamily: AppFonts.body,
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );

  // Headlines/titles use Nunito; body/labels stay Rubik.
  final textTheme = baseText.copyWith(
    displayLarge: heading(size: 40, weight: FontWeight.w800),
    displayMedium: heading(size: 32, weight: FontWeight.w800),
    headlineMedium: heading(size: 26, weight: FontWeight.w700),
    headlineSmall: heading(size: 22, weight: FontWeight.w700),
    titleLarge: heading(size: 20, weight: FontWeight.w600),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.body,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: heading(size: 22, weight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        elevation: 8,
        shadowColor: AppColors.coral.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: heading(size: 18, weight: FontWeight.w700, color: Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: heading(size: 18, weight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: const BorderSide(color: AppColors.coral, width: 2),
      ),
    ),
  );
}
