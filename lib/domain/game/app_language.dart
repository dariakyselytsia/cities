/// UI/content language for a session.
enum AppLanguage {
  ua,
  en;

  /// Whether this is Ukrainian — selects the `nameUA`/`firstLetterUA` fields for
  /// display and letter-matching. Independent of [GameMode] (which only selects
  /// the city dataset), so e.g. the World list can be played in Ukrainian.
  bool get isUkrainian => this == AppLanguage.ua;

  /// ISO-ish code persisted in Isar and used by localization (`'uk'` / `'en'`).
  String get code => this == AppLanguage.ua ? 'uk' : 'en';

  /// Parses a stored/legacy code back into an [AppLanguage]. `'uk'`/`'ua'` map
  /// to Ukrainian; everything else to English.
  static AppLanguage fromCode(String code) {
    final c = code.trim().toLowerCase();
    return (c == 'uk' || c == 'ua') ? AppLanguage.ua : AppLanguage.en;
  }
}
