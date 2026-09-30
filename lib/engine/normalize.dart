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
final RegExp _apostrophes = RegExp('[\'’‘‛ʼʻʾʿʹ`´"“”„]');

/// Combining diacritical marks, left over when a keyboard sends a letter and
/// its accent as two code points ("e" + U+0301). Stripped after
/// [_composeCyrillic], so they never eat a Ukrainian `й` or `ї`.
final RegExp _combiningMarks = RegExp('[̀-ͯ]');

/// Everything that is not a letter or a digit separates words: spaces,
/// hyphens and dashes ("Івано-Франківськ" = "Івано Франківськ"), dots
/// ("St. Louis" = "St Louis"), brackets, slashes and commas.
final RegExp _separators = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

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

/// [_foldGroups] inverted: one entry per folded letter. All of them are
/// single UTF-16 code units, so `split('')` is safe.
final Map<String, String> _fold = {
  for (final MapEntry(key: base, value: letters) in _foldGroups.entries)
    for (final letter in letters.split('')) letter: base,
};

final RegExp _foldable = RegExp('[${_fold.keys.join()}]');

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
String normalizeName(String input) => _composeCyrillic(input.toLowerCase())
    .replaceAll(_apostrophes, '')
    .replaceAll(_combiningMarks, '')
    .replaceAllMapped(_foldable, (m) => _fold[m[0]] ?? m[0] ?? '')
    .replaceAll(_separators, ' ')
    .trim();

/// Joins the two Ukrainian letters that some keyboards send decomposed
/// (`и` + breve, `і` + diaeresis). Without this, stripping the combining
/// marks would turn `й` into `и` and `ї` into `і`: different letters.
String _composeCyrillic(String s) => s
    .replaceAll('й', 'й')
    .replaceAll('ї', 'ї')
    .replaceAll('ё', 'ё');
