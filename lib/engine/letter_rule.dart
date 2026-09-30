import 'normalize.dart';

/// The "next city" letter rule (game_design §2.3).
///
/// The next city must start with the **last playable letter** of the
/// previous one. Letters are read from the previous city's display name
/// after [normalizeName], so apostrophes and hyphens don't count and `ґ`
/// reads as `г`. Walking back from the end, every letter outside
/// `playableLetters` is skipped: the soft sign `ь`, which no city starts
/// with, and letters too few cities start with (see `LetterMinimums`).
/// "Кам'янець" → `ц` (in World), "Хмельницький" → `к`.
///
/// The rule is dataset-driven: `CityIndex.playableLetters` decides, so there
/// is no hard-coded letter list here.
abstract final class LetterRule {
  /// The letter the city after [previousName] must start with, or `null`
  /// when no letter of it is playable. `null` means any letter will do, as
  /// for the opening move.
  static String? requiredNextLetter(
    String previousName,
    Set<String> playableLetters,
  ) {
    final letters = normalizeName(previousName).runes.toList();
    for (var i = letters.length - 1; i >= 0; i--) {
      final letter = String.fromCharCode(letters[i]);
      if (playableLetters.contains(letter)) return letter;
    }
    return null;
  }

  /// Whether [answer] starts with [requiredLetter]. A `null` requirement
  /// (the opening move, or a dead end) accepts any answer.
  static bool startsWithRequired(String answer, String? requiredLetter) =>
      requiredLetter == null || firstLetter(answer) == requiredLetter;
}
