/// Pure GeoNames → `cities.json` logic, kept free of I/O so it can be unit
/// tested. `tool/build_cities.dart` does the file reading and writing.
library;

import 'ua_translit.dart';

/// GeoNames feature codes that are not real, current cities:
/// - `PPLX`: a section of a city (e.g. Obolon, Podil);
/// - `PPLH`: historical;
/// - `PPLQ`: abandoned;
/// - `PPLW`: destroyed.
///
/// Players would rightly reject these as "not a city".
const Set<String> excludedFeatureCodes = {'PPLX', 'PPLH', 'PPLQ', 'PPLW'};

/// One row of a GeoNames `citiesNNNN.txt` dump (only the columns we use).
class GeoCity {
  const GeoCity({
    required this.id,
    required this.name,
    required this.featureCode,
    required this.countryCode,
    required this.population,
  });

  /// GeoNames id. It is globally unique, so it's stable across both lists and
  /// across rebuilds.
  final int id;

  /// GeoNames' main name: romanized, may carry diacritics ("São Paulo").
  final String name;
  final String featureCode;
  final String countryCode;
  final int population;

  /// `PPLC` is a country's capital.
  bool get isCapital => featureCode == 'PPLC';

  bool get isPlayable => !excludedFeatureCodes.contains(featureCode);

  /// Parses one tab-separated line (19 columns). Returns `null` for a
  /// malformed line instead of throwing: one bad row shouldn't kill a build.
  static GeoCity? tryParse(String line) {
    final c = line.split('\t');
    if (c.length < 19) return null;
    final id = int.tryParse(c[0]);
    final population = int.tryParse(c[14]);
    if (id == null || population == null) return null;
    return GeoCity(
      id: id,
      name: c[1].trim(),
      featureCode: c[7],
      countryCode: c[8],
      population: population,
    );
  }
}

/// One row of GeoNames `alternateNamesV2.txt` (only the columns we use).
class AltName {
  const AltName({
    required this.geonameId,
    required this.language,
    required this.name,
    this.isPreferred = false,
    this.isShort = false,
    this.isColloquial = false,
    this.isHistoric = false,
  });

  final int geonameId;

  /// ISO 639 code (`uk`, `en`, …) or a pseudo-code (`link`, `post`, …).
  final String language;
  final String name;
  final bool isPreferred;
  final bool isShort;
  final bool isColloquial;
  final bool isHistoric;

  /// Parses one tab-separated line. Returns `null` for a malformed line.
  static AltName? tryParse(String line) {
    final c = line.split('\t');
    if (c.length < 8) return null;
    final geonameId = int.tryParse(c[1]);
    if (geonameId == null) return null;
    return AltName(
      geonameId: geonameId,
      language: c[2],
      name: c[3].trim(),
      isPreferred: c[4] == '1',
      isShort: c[5] == '1',
      isColloquial: c[6] == '1',
      isHistoric: c[7] == '1',
    );
  }
}

/// The display names and aliases chosen for one city.
class CityNames {
  const CityNames({
    required this.uk,
    required this.en,
    required this.akaUk,
    required this.akaEn,
  });

  /// Real Ukrainian name, or `null` when GeoNames has none. Such a city is not
  /// playable in Ukrainian. We don't machine-transliterate: the old dataset
  /// did, and produced names nobody would type ("лес Ескалдес").
  final String? uk;
  final String en;
  final List<String> akaUk;
  final List<String> akaEn;
}

/// A Ukrainian name must be Cyrillic. Some `uk` rows in GeoNames are Latin
/// ("Bila Tserkva"). Spaces, hyphens, dots and apostrophes are allowed.
final RegExp _cyrillicName = RegExp(r"^[Ѐ-ӿ][Ѐ-ӿ\s'’ʼ.\-]*$");

/// An English name must be free of Cyrillic, digits and list punctuation
/// (GeoNames sometimes stores annotated variants like "Paris (Texas)").
final RegExp _englishName = RegExp(r'^[^Ѐ-ӿ\d(),/;]+$');

/// Chooses the display names and aliases for [city] from its [alts].
///
/// Display name, per language:
/// - a current (non-historic) *preferred* name, favoring the short form
///   ("New York" over "New York City");
/// - otherwise, for `uk`: a current short name, then the first current name;
/// - otherwise, for `en`: GeoNames' main [GeoCity.name].
///
/// Aliases are every other acceptable name in that language, **including
/// historic ones** (Kiev, Kirovohrad, Bombay). Players still use them, and
/// being forgiving is a game-design goal. Colloquial nicknames ("Big Apple")
/// are excluded. Only `uk`/`en` rows count; Russian names are *not* accepted
/// as Ukrainian aliases.
CityNames pickNames(GeoCity city, List<AltName> alts) {
  final ukNames = [
    for (final a in alts)
      if (a.language == 'uk' && !a.isColloquial && _cyrillicName.hasMatch(a.name))
        a,
  ];
  final enNames = [
    for (final a in alts)
      if (a.language == 'en' && !a.isColloquial && _englishName.hasMatch(a.name))
        a,
  ];

  final uk = _capitalized(_pickDisplay(ukNames, fallBackToAnyCurrent: true));
  final en = _pickDisplay(enNames, fallBackToAnyCurrent: false) ?? city.name;

  return CityNames(
    uk: uk,
    en: en,
    akaUk: uk == null ? const [] : _aliases([for (final a in ukNames) a.name], uk),
    akaEn: _aliases([for (final a in enNames) a.name, city.name], en),
  );
}

String? _pickDisplay(List<AltName> names, {required bool fallBackToAnyCurrent}) {
  final current = [for (final a in names) if (!a.isHistoric) a];
  final preferred = [for (final a in current) if (a.isPreferred) a];
  if (preferred.isNotEmpty) {
    for (final a in preferred) {
      if (a.isShort) return a.name;
    }
    return preferred.first.name;
  }
  if (!fallBackToAnyCurrent) return null;
  for (final a in current) {
    if (a.isShort) return a.name;
  }
  return current.isEmpty ? null : current.first.name;
}

/// A few GeoNames `uk` rows start lower-case ("іст-Клівленд"). Ukrainian city
/// names are always capitalized, so the display name is fixed here.
String? _capitalized(String? name) => name == null || name.isEmpty
    ? name
    : name[0].toUpperCase() + name.substring(1);

/// Distinct [names] other than [display], sorted for stable diffs.
///
/// Names that differ only in case, hyphens vs spaces, or apostrophes are
/// duplicates, because the game's answer normalization (T05) treats them as
/// equal anyway. Keeping them would only bloat the asset.
List<String> _aliases(List<String> names, String display) {
  final seen = <String>{foldForDedupe(display)};
  final out = <String>[
    for (final n in names)
      if (seen.add(foldForDedupe(n))) n,
  ];
  out.sort();
  return out;
}

/// A light fold used only to dedupe aliases at build time: lower-case,
/// apostrophes removed, and hyphens/whitespace collapsed to one space.
String foldForDedupe(String s) => s
    .toLowerCase()
    .replaceAll(RegExp("['’ʼ`]"), '')
    .replaceAll(RegExp(r'[\s\-‐–]+'), ' ')
    .trim();

/// A manual fix from `tool/overrides.json`, applied on top of GeoNames.
///
/// Fixes are keyed by GeoNames id, so they survive every rebuild. They cover
/// the names GeoNames lacks or gets wrong (e.g. 36 capitals have no `uk`
/// name).
class CityOverride {
  const CityOverride({
    this.uk,
    this.en,
    this.akaUk = const [],
    this.akaEn = const [],
    this.exclude = false,
  });

  /// Replaces the Ukrainian display name.
  final String? uk;

  /// Replaces the English display name.
  final String? en;

  /// Extra Ukrainian aliases (merged with GeoNames' aliases).
  final List<String> akaUk;

  /// Extra English aliases (merged with GeoNames' aliases).
  final List<String> akaEn;

  /// Drops the city from the output entirely (e.g. a duplicate or non-city).
  final bool exclude;

  /// Parses one override entry. It throws [FormatException] on bad input:
  /// a typo in the overrides file should stop the build, not slip through.
  factory CityOverride.fromJson(Map<String, Object?> json) {
    const known = {'_name', 'uk', 'en', 'akaUk', 'akaEn', 'exclude'};
    final unknown = json.keys.where((k) => !known.contains(k));
    if (unknown.isNotEmpty) {
      throw FormatException('Unknown override field(s): ${unknown.join(', ')}');
    }
    final uk = _optionalString(json, 'uk');
    if (uk != null && !_cyrillicName.hasMatch(uk)) {
      throw FormatException('"uk" must be Cyrillic: "$uk"');
    }
    final akaUk = _stringList(json, 'akaUk');
    for (final alias in akaUk) {
      if (!_cyrillicName.hasMatch(alias)) {
        throw FormatException('"akaUk" entries must be Cyrillic: "$alias"');
      }
    }
    final exclude = json['exclude'];
    if (exclude != null && exclude is! bool) {
      throw const FormatException('"exclude" must be true/false');
    }
    return CityOverride(
      uk: uk,
      en: _optionalString(json, 'en'),
      akaUk: akaUk,
      akaEn: _stringList(json, 'akaEn'),
      exclude: exclude == true,
    );
  }

  static String? _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('"$key" must be a non-empty string');
    }
    return value.trim();
  }

  static List<String> _stringList(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return const [];
    if (value is! List || value.any((e) => e is! String)) {
      throw FormatException('"$key" must be a list of strings');
    }
    return [for (final e in value) (e as String).trim()];
  }
}

/// Parses the whole `tool/overrides.json` document: `{"cities": {"<id>": {…}}}`.
Map<int, CityOverride> parseOverrides(Object? document) {
  if (document is! Map || document['cities'] is! Map) {
    throw const FormatException('overrides.json must have a "cities" object');
  }
  final cities = document['cities'] as Map;
  final result = <int, CityOverride>{};
  for (final MapEntry(:key, :value) in cities.entries) {
    final id = int.tryParse('$key');
    if (id == null) throw FormatException('Override key is not an id: "$key"');
    if (value is! Map<String, Object?>) {
      throw FormatException('Override $id must be an object');
    }
    try {
      result[id] = CityOverride.fromJson(value);
    } on FormatException catch (e) {
      throw FormatException('Override $id: ${e.message}');
    }
  }
  return result;
}

/// Applies [override] to GeoNames-derived [names].
///
/// - An overridden **Ukrainian** name *replaces* the GeoNames one: a `uk`
///   override usually exists because the GeoNames name was wrong
///   ("Старе Делі" for Delhi). If the old name is still a valid alias (a
///   pre-renaming name), the override lists it in `akaUk` explicitly.
/// - An overridden **English** name keeps the old one as an alias: `en`
///   overrides are mostly spelling updates ("Sharjah city" → "Sharjah"), and
///   players may still type the old form.
///
/// Extra aliases are merged and deduped like any others.
CityNames applyOverride(CityNames names, CityOverride override) {
  final uk = override.uk ?? names.uk;
  final en = override.en ?? names.en;
  return CityNames(
    uk: uk,
    en: en,
    akaUk: uk == null ? const [] : _aliases([...names.akaUk, ...override.akaUk], uk),
    akaEn: _aliases([...names.akaEn, names.en, ...override.akaEn], en),
  );
}

/// Gives a Ukrainian city its **official** English name, transliterated from
/// its Ukrainian name ([transliterateUk]), and keeps GeoNames' English
/// spellings as aliases.
///
/// Without this, many Ukrainian cities would display outdated romanizations
/// ("Zaporizhzhya", "Kryvyy Rih"). Worse, a player typing the official
/// spelling would be told it's not a city.
///
/// The Ukrainian aliases (mostly pre-renaming names, e.g. Червоноград) are
/// transliterated into English aliases too, so "Chervonohrad" works in
/// English just as "Червоноград" does in Ukrainian.
CityNames withOfficialUkrainianEnglish(CityNames names) {
  final uk = names.uk;
  if (uk == null) return names;
  final en = transliterateUk(uk);
  return CityNames(
    uk: uk,
    en: en,
    akaUk: names.akaUk,
    akaEn: _aliases(
      [...names.akaEn, names.en, ...names.akaUk.map(transliterateUk)],
      en,
    ),
  );
}

/// One city as written to `assets/data/cities.json` (format: tech_design §4).
///
/// Empty and default fields are omitted to keep the asset small.
Map<String, Object> cityRecord(
  GeoCity city,
  CityNames names, {
  required bool uaOnly,
}) {
  return {
    'id': city.id,
    'uk': ?names.uk,
    'en': names.en,
    'cc': city.countryCode,
    if (city.isCapital) 'cap': true,
    'pop': city.population,
    if (names.akaUk.isNotEmpty) 'akaUk': names.akaUk,
    if (names.akaEn.isNotEmpty) 'akaEn': names.akaEn,
    if (uaOnly) 'uaOnly': true,
  };
}
