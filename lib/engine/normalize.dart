/// Answer normalization (tech_design §5).
///
/// The same function is applied to what the player types and to every city
/// name and alias in the catalog. Two strings are the same answer when their
/// normalized forms are equal. It deliberately does **no** typo guessing: it
/// only erases differences that a keyboard or a spelling convention makes,
/// never differences of letters.
library;

/// Apostrophes and quote marks. They are **removed**, not turned into spaces,
/// because Ukrainian writes the same word with or without them depending on
/// the keyboard: "Кам'янець" = "Кам’янець" = "Камянець".
///
/// It includes the Latin transliteration marks `ʻ ʾ ʿ` (Oʻzbekiston,
/// Biʾr as-Sabʿ) and the `”` GeoNames sometimes uses for an apostrophe.
final Set<int> _apostrophes = '\'’‘‛ʼʻʾʿʹ`´"“”„'.runes.toSet();

/// Combining diacritical marks (U+0300–U+036F), left over when a keyboard
/// sends a letter and its accent as two code points ("e" + U+0301). Stripped
/// after [_composeCyrillic], so they never eat a Ukrainian `й` or `ї`.
bool _isCombiningMark(int rune) => rune >= 0x0300 && rune <= 0x036F;

/// Everything that is not a letter or a digit separates words: spaces,
/// hyphens and dashes ("Івано-Франківськ" = "Івано Франківськ"), dots
/// ("St. Louis" = "St Louis"), brackets, slashes and commas.
final RegExp _letterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// [_letterOrDigit] answers, cached per code point: the catalog normalizes
/// ~40,000 names at startup, and a regex per character is too slow.
final Map<int, bool> _letterOrDigitCache = {};

bool _isLetterOrDigit(int rune) {
  // Fast paths for what nearly every name is made of: a–z, 0–9, and
  // lowercase Cyrillic (а–я, ѐ–џ).
  if ((rune >= 0x61 && rune <= 0x7A) ||
      (rune >= 0x30 && rune <= 0x39) ||
      (rune >= 0x0430 && rune <= 0x045F)) {
    return true;
  }
  if (rune < 0x80) return false;
  return _letterOrDigitCache[rune] ??=
      _letterOrDigit.hasMatch(String.fromCharCode(rune));
}

/// Folded letters, grouped by what they become.
///
/// - Latin letters lose their diacritics (ã→a, é→e, ł→l, ß→ss), so an
///   English player can type "Sao Paulo" or "Krakow". The set covers every
///   accented letter in the city data (see `normalize_dataset_test.dart`).
/// - Ukrainian `ґ`→`г`: many keyboards and older texts don't have `ґ`
///   ("Ґалаґан" = "Галаган").
/// - `ё`→`е`, a letter often written without its dots. `ы`, `э` and `ъ` stay
///   distinct: they are different letters, not spellings of Ukrainian ones.
const Map<String, String> _foldGroups = {
  'a': 'àáâãäåāăąǎǟǡǻȁȃȧḁạảấầẩẫậắằẳẵặ',
  'ae': 'æǽ',
  'b': 'ḃḅḇ',
  'c': 'çćĉċčḉ',
  'd': 'ďđðḋḍḏḑḓ',
  'e': 'èéêëēĕėęěȅȇȩḕḗḙḛḝẹẻẽếềểễệəǝ',
  'f': 'ḟƒ',
  'g': 'ĝğġģǧǵḡ',
  'h': 'ĥħȟḣḥḧḩḫẖ',
  'i': 'ìíîïĩīĭįıǐȉȋḭḯỉị',
  'ij': 'ĳ',
  'j': 'ĵǰ',
  'k': 'ķǩḱḳḵ',
  'l': 'ĺļľŀłḷḹḻḽ',
  'm': 'ḿṁṃ',
  'n': 'ñńņňŋǹṅṇṉṋ',
  'o': 'òóôõöøōŏőơǒǫǭǿȍȏȫȭȯȱṍṏṑṓọỏốồổỗộớờởỡợ',
  'oe': 'œ',
  'p': 'ṕṗ',
  'r': 'ŕŗřȑȓṙṛṝṟ',
  's': 'śŝşšșṡṣṥṧṩ',
  'ss': 'ß',
  't': 'ţťŧțṫṭṯṱẗ',
  'th': 'þ',
  'u': 'ùúûüũūŭůűųưǔǖǘǚǜȕȗṳṵṷṹṻụủứừửữự',
  'v': 'ṽṿ',
  'w': 'ŵẁẃẅẇẉẘ',
  'x': 'ẋẍ',
  'y': 'ýÿŷȳẏẙỳỵỷỹ',
  'z': 'źżžẑẓẕ',
  'г': 'ґ',
  'е': 'ё',
};

/// [_foldGroups] inverted: folded letter's code point → what it becomes.
final Map<int, String> _fold = {
  for (final MapEntry(key: base, value: letters) in _foldGroups.entries)
    for (final letter in letters.runes) letter: base,
};

/// Normalizes a city name or a player's answer for comparison.
///
/// In order:
/// 1. lowercase;
/// 2. remove apostrophes and quote marks;
/// 3. fold letters: Latin diacritics, `ґ`→`г`, `ё`→`е`;
/// 4. turn every run of non-letters (spaces, hyphens, dots, …) into one
///    space, and trim.
///
/// ```dart
/// normalizeName("Кам'янець-Подільський") // "камянець подільський"
/// normalizeName('  São   Paulo ')        // "sao paulo"
/// ```
///
/// The result is idempotent: normalizing it again returns it unchanged.
///
/// It runs as one pass over the characters, with no regex per call: the
/// catalog normalizes every name and alias at startup.
String normalizeName(String input) {
  final out = StringBuffer();
  var pendingSpace = false;

  void write(String letters) {
    if (pendingSpace) out.write(' ');
    pendingSpace = false;
    out.write(letters);
  }

  for (final rune in _composeCyrillic(input.toLowerCase()).runes) {
    if (_apostrophes.contains(rune) || _isCombiningMark(rune)) continue;
    final folded = _fold[rune];
    if (folded != null) {
      write(folded);
    } else if (_isLetterOrDigit(rune)) {
      write(String.fromCharCode(rune));
    } else {
      // A separator: remembered, and written only between two words.
      pendingSpace = out.isNotEmpty;
    }
  }
  return out.toString();
}

/// The first letter of an already [normalizeName]d name ("гданськ" → `г`),
/// or `null` when it starts with a digit or is empty
/// ("6th of October City"): such a name can never follow the letter rule.
String? firstLetterOfNormalized(String normalized) {
  if (normalized.isEmpty) return null;
  final first = String.fromCharCode(normalized.runes.first);
  return _letter.hasMatch(first) ? first : null;
}

/// The first letter of [name] after normalization ("Ґданськ" → `г`,
/// "'s-Hertogenbosch" → `s`); see [firstLetterOfNormalized].
String? firstLetter(String name) => firstLetterOfNormalized(normalizeName(name));

final RegExp _letter = RegExp(r'\p{L}', unicode: true);

/// Joins the two Ukrainian letters that some keyboards send decomposed
/// (`и` + breve, `і` + diaeresis). Without this, stripping the combining
/// marks would turn `й` into `и` and `ї` into `і`: different letters.
String _composeCyrillic(String s) {
  if (!s.contains('\u0306') && !s.contains('\u0308')) return s;
  return s
      .replaceAll('и\u0306', 'й')
      .replaceAll('і\u0308', 'ї')
      .replaceAll('е\u0308', 'ё');
}
