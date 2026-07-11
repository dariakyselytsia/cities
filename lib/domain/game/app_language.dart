/// UI/content language for a session.
enum AppLanguage {
  ua,
  en;

  /// ISO-ish code persisted in Isar and used by localization (`'uk'` / `'en'`).
  String get code => this == AppLanguage.ua ? 'uk' : 'en';

  /// Parses a stored/legacy code back into an [AppLanguage]. `'uk'`/`'ua'` map
  /// to Ukrainian; everything else to English.
  static AppLanguage fromCode(String code) {
    final c = code.trim().toLowerCase();
    return (c == 'uk' || c == 'ua') ? AppLanguage.ua : AppLanguage.en;
  }
}
