import 'package:equatable/equatable.dart';

/// The language a game is played in, which picks the set of names a city
/// answers to.
///
/// Matching uses **only** the app language: in a Ukrainian game "Kyiv" is not
/// an answer, "Київ" is (game_design.md).
enum NameLanguage { uk, en }

/// One city from `assets/data/cities.json` (tech_design §4).
///
/// Immutable value class: two cities are equal when all their fields are.
/// The [id] is the GeoNames id, which is the same in the Ukraine and World
/// lists.
class City extends Equatable {
  const City({
    required this.id,
    required this.nameEn,
    required this.countryCode,
    required this.population,
    this.nameUk,
    this.isCapital = false,
    this.aliasesUk = const [],
    this.aliasesEn = const [],
    this.isUkraineOnly = false,
  });

  /// Parses one entry of the `cities` array.
  ///
  /// Throws a [FormatException] when a required field is missing or has the
  /// wrong type. The loader (T10) catches it and turns it into a typed load
  /// failure, so it never crosses into the UI.
  factory City.fromJson(Map<String, Object?> json) {
    if (json case {
      'id': final int id,
      'en': final String nameEn,
      'cc': final String countryCode,
      'pop': final int population,
    } when nameEn.isNotEmpty) {
      return City(
        id: id,
        nameEn: nameEn,
        countryCode: countryCode,
        population: population,
        nameUk: _optionalName(json, 'uk'),
        isCapital: _flag(json, 'cap'),
        aliasesUk: _names(json, 'akaUk'),
        aliasesEn: _names(json, 'akaEn'),
        isUkraineOnly: _flag(json, 'uaOnly'),
      );
    }
    throw FormatException('Invalid city: $json');
  }

  /// GeoNames id.
  final int id;

  /// Ukrainian display name. `null` when the city has no real Ukrainian name:
  /// then it isn't playable in Ukrainian (it is never machine-transliterated).
  final String? nameUk;

  /// English display name. Always present.
  final String nameEn;

  /// ISO 3166-1 alpha-2 country code, e.g. `UA`.
  final String countryCode;

  /// Whether GeoNames marks it as a capital (`PPLC`). This includes capitals
  /// of dependent territories.
  final bool isCapital;

  /// Population, used for fame ranking and difficulty tiers.
  final int population;

  /// Other accepted Ukrainian names, e.g. pre-renaming ones ("Кіровоград").
  final List<String> aliasesUk;

  /// Other accepted English names, e.g. older spellings ("Kiev").
  final List<String> aliasesEn;

  /// A Ukrainian town below the World list's 15,000 population cut-off: it's
  /// only in the Ukraine list.
  final bool isUkraineOnly;

  /// The display name in [language], or `null` when the city has none.
  String? name(NameLanguage language) => switch (language) {
    NameLanguage.uk => nameUk,
    NameLanguage.en => nameEn,
  };

  /// The aliases in [language].
  List<String> aliases(NameLanguage language) => switch (language) {
    NameLanguage.uk => aliasesUk,
    NameLanguage.en => aliasesEn,
  };

  @override
  List<Object?> get props => [
    id,
    nameUk,
    nameEn,
    countryCode,
    isCapital,
    population,
    aliasesUk,
    aliasesEn,
    isUkraineOnly,
  ];

  @override
  bool get stringify => true;
}

String? _optionalName(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      null => null,
      final String name when name.isNotEmpty => name,
      _ => throw FormatException('Invalid "$key": ${json[key]}'),
    };

bool _flag(Map<String, Object?> json, String key) => switch (json[key]) {
  null => false,
  final bool flag => flag,
  _ => throw FormatException('Invalid "$key": ${json[key]}'),
};

List<String> _names(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return const [];
  if (value is! List<Object?>) {
    throw FormatException('Invalid "$key": $value');
  }
  return List.unmodifiable([
    for (final name in value)
      if (name is String && name.isNotEmpty)
        name
      else
        throw FormatException('Invalid "$key" entry: $name'),
  ]);
}
