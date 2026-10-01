import 'package:equatable/equatable.dart';

import 'normalize.dart';

/// A character of a display name: the code units [start, end) that read as
/// [letter].
typedef LetterSpan = ({int start, int end, String letter});

/// The letters of a city's name the chat marks, so the player sees why
/// «Кременець» asks for «н»:
/// - [next]: the letter the next city must start with;
/// - [skipped]: rarer letters after it that the rule passed over («е», «ц»),
///   in reading order. The player may answer with these too
///   (`Match.extraLetters`). Letters no city starts with («ь») aren't
///   listed: no answer could use them.
final class LetterMarks extends Equatable {
  const LetterMarks({this.next, this.skipped = const []});

  final LetterSpan? next;
  final List<LetterSpan> skipped;

  @override
  List<Object?> get props => [next, skipped];
}

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

  /// The character of [name] that [requiredNextLetter] reads, or `null` when
  /// no letter of it is playable. See [letterMarks].
  static LetterSpan? nextLetterSpan(String name, Set<String> playableLetters) =>
      letterMarks(name, playableLetters).next;

  /// The [LetterMarks] of [name]: the character [requiredNextLetter] reads,
  /// and the characters after it whose letter is in [startingLetters] but
  /// not playable.
  ///
  /// It walks the display name back one character at a time and normalizes
  /// each on its own, so it points into the text the chat shows (with its
  /// case, apostrophes and diacritics) and agrees with [requiredNextLetter]
  /// (checked on the whole dataset). A base letter and its combining marks
  /// count as one character.
  static LetterMarks letterMarks(
    String name,
    Set<String> playableLetters, {
    Set<String> startingLetters = const {},
  }) {
    final skipped = <LetterSpan>[];
    var end = name.length;
    while (end > 0) {
      var start = end;
      // Step back over one character, plus any combining marks it carries.
      do {
        start -= _isTrailSurrogate(name.codeUnitAt(start - 1)) && start > 1
            ? 2
            : 1;
      } while (start > 0 && _isCombiningMark(name.codeUnitAt(start)));
      final letters = normalizeName(name.substring(start, end)).runes;
      String? rare;
      for (final rune in letters.toList().reversed) {
        final letter = String.fromCharCode(rune);
        if (playableLetters.contains(letter)) {
          return LetterMarks(
            next: (start: start, end: end, letter: letter),
            skipped: List.unmodifiable(skipped.reversed),
          );
        }
        if (startingLetters.contains(letter)) rare ??= letter;
      }
      if (rare != null) skipped.add((start: start, end: end, letter: rare));
      end = start;
    }
    return LetterMarks(skipped: List.unmodifiable(skipped.reversed));
  }

  /// Whether [answer] starts with [requiredLetter]. A `null` requirement
  /// (the opening move, or a dead end) accepts any answer.
  static bool startsWithRequired(String answer, String? requiredLetter) =>
      requiredLetter == null || firstLetter(answer) == requiredLetter;
}

bool _isTrailSurrogate(int codeUnit) =>
    codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;

bool _isCombiningMark(int codeUnit) => codeUnit >= 0x0300 && codeUnit <= 0x036F;
