/// Official Ukrainian → Latin transliteration: Cabinet of Ministers
/// Resolution No. 55 (27.01.2010). It is the standard used for passports and
/// road signs, and it gives the modern official English names ("Zaporizhzhia",
/// "Kryvyi Rih", "Kamianske").
///
/// GeoNames often carries older spellings ("Zaporizhzhya", "Kryvyy Rih"), so
/// the build uses this for Ukrainian cities' English display names and keeps
/// the GeoNames spellings as aliases.
library;

/// Letters that change at the **start of a word**: Є, Ї, Й, Ю, Я become
/// Ye/Yi/Y/Yu/Ya there, and ie/i/i/iu/ia elsewhere.
const Map<String, (String initial, String other)> _positional = {
  'є': ('ye', 'ie'),
  'ї': ('yi', 'i'),
  'й': ('y', 'i'),
  'ю': ('yu', 'iu'),
  'я': ('ya', 'ia'),
};

const Map<String, String> _letters = {
  'а': 'a', 'б': 'b', 'в': 'v', 'г': 'h', 'ґ': 'g', 'д': 'd', 'е': 'e',
  'ж': 'zh', 'з': 'z', 'и': 'y', 'і': 'i', 'к': 'k', 'л': 'l', 'м': 'm',
  'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
  'ф': 'f', 'х': 'kh', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch',
  // The soft sign and apostrophes are dropped by the standard.
  'ь': '', "'": '', '’': '', 'ʼ': '',
};

/// Transliterates a Ukrainian name, keeping each word's capitalization.
///
/// Word boundaries (for the positional letters) are spaces and hyphens, so
/// "Нова Ушиця" → "Nova Ushytsia" and "Івано-Франківськ" → "Ivano-Frankivsk".
/// The standard's one digraph exception is "зг" → "zgh" (so it isn't read as
/// "zh").
String transliterateUk(String name) {
  final out = StringBuffer();
  var atWordStart = true;
  for (var i = 0; i < name.length; i++) {
    final ch = name[i];
    final lower = ch.toLowerCase();
    final isUpper = ch != lower;

    String latin;
    final positional = _positional[lower];
    if (positional != null) {
      latin = atWordStart ? positional.$1 : positional.$2;
    } else if (lower == 'г' && i > 0 && name[i - 1].toLowerCase() == 'з') {
      latin = 'gh';
    } else {
      latin = _letters[lower] ?? ch;
    }

    if (isUpper && latin.isNotEmpty) {
      latin = latin[0].toUpperCase() + latin.substring(1);
    }
    out.write(latin);

    // Apostrophes and the soft sign are inside a word; only spaces and
    // hyphens start a new one.
    atWordStart = ch == ' ' || ch == '-';
  }
  return out.toString();
}
