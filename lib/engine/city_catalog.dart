import 'city.dart';
import 'city_list.dart';
import 'letter_rule.dart';
import 'normalize.dart';

/// Country codes of **dependent territories**: GeoNames marks their capitals
/// `PPLC` too (Flying Fish Cove, 1,355 people; West Island, 120), but only
/// capitals of sovereign states are famous enough to be forced into tier 1.
///
/// A population threshold can't replace this list: Vatican City (829
/// people) and Valletta are sovereign capitals, Papeete and Nuuk are not.
/// Hong Kong and Macau are here too; Hong Kong still makes tier 1 by
/// population.
const Set<String> nonSovereignCountryCodes = {
  'AI', 'AS', 'AW', 'AX', 'BL', 'BM', 'BQ', 'CC', 'CK', 'CW', 'CX', 'FK',
  'FO', 'GF', 'GG', 'GI', 'GL', 'GP', 'GS', 'GU', 'HK', 'IM', 'IO', 'JE',
  'KY', 'MF', 'MO', 'MP', 'MQ', 'MS', 'NC', 'NF', 'NU', 'PF', 'PM', 'PN',
  'PR', 'RE', 'SH', 'SJ', 'SX', 'TC', 'TF', 'TK', 'VG', 'VI', 'WF', 'YT',
};

/// Whether [city] is the capital of a sovereign state, which always makes it
/// tier 1 (game_design §2.5).
bool isSovereignCapital(City city) =>
    city.isCapital && !nonSovereignCountryCodes.contains(city.countryCode);

/// Every city, indexed for play: one [CityIndex] per list × language.
///
/// Pure and built once at startup (in a background isolate, T10). It does no
/// asset I/O: the loader decodes the JSON and hands it to
/// [CityCatalog.fromJson].
class CityCatalog {
  /// Builds the indexes. [tierLimits] and [letterMinimums] exist for tests;
  /// the game uses the standard tuning values.
  factory CityCatalog(
    Iterable<City> cities, {
    TierLimits tierLimits = TierLimits.standard,
    LetterMinimums letterMinimums = LetterMinimums.standard,
  }) {
    final all = List<City>.unmodifiable(cities);
    final ids = <int>{};
    for (final city in all) {
      if (!ids.add(city.id)) {
        throw FormatException('Duplicate city id ${city.id}');
      }
    }

    // Normalized once per language, shared by both lists' indexes.
    final ukNames = _normalizedNames(all, NameLanguage.uk);
    final enNames = _normalizedNames(all, NameLanguage.en);
    CityIndex build(CityListKind list, NameLanguage language) {
      final names = switch (language) {
        NameLanguage.uk => ukNames,
        NameLanguage.en => enNames,
      };
      final listCities = all.where(list.contains);
      return CityIndex._(
        list,
        language,
        listCities,
        _tiers(
          listCities.where((city) => names.containsKey(city.id)),
          tierLimits.of(list),
        ),
        names,
        letterMinimums.of(list),
      );
    }

    return CityCatalog._(
      all,
      ukraineUk: build(CityListKind.ukraine, NameLanguage.uk),
      ukraineEn: build(CityListKind.ukraine, NameLanguage.en),
      worldUk: build(CityListKind.world, NameLanguage.uk),
      worldEn: build(CityListKind.world, NameLanguage.en),
    );
  }

  CityCatalog._(
    this.cities, {
    required CityIndex ukraineUk,
    required CityIndex ukraineEn,
    required CityIndex worldUk,
    required CityIndex worldEn,
  }) : _ukraineUk = ukraineUk,
       _ukraineEn = ukraineEn,
       _worldUk = worldUk,
       _worldEn = worldEn;

  /// Parses the decoded `assets/data/cities.json` (tech_design §4).
  ///
  /// Throws a [FormatException] for an unknown format version or a
  /// malformed city. The loader turns it into a typed load failure.
  factory CityCatalog.fromJson(Object? json) {
    if (json case {'v': formatVersion, 'cities': final List<Object?> entries}) {
      return CityCatalog([
        for (final entry in entries)
          if (entry is Map<String, Object?>)
            City.fromJson(entry)
          else
            throw FormatException('Invalid city entry: $entry'),
      ]);
    }
    throw const FormatException(
      'Not a version $formatVersion cities.json document',
    );
  }

  /// The `v` of the `cities.json` format this catalog reads.
  static const int formatVersion = 1;

  /// Every city in the data, in file order.
  final List<City> cities;

  final CityIndex _ukraineUk;
  final CityIndex _ukraineEn;
  final CityIndex _worldUk;
  final CityIndex _worldEn;

  /// The index a game with [list] in [language] plays on.
  CityIndex index(CityListKind list, NameLanguage language) =>
      switch ((list, language)) {
        (CityListKind.ukraine, NameLanguage.uk) => _ukraineUk,
        (CityListKind.ukraine, NameLanguage.en) => _ukraineEn,
        (CityListKind.world, NameLanguage.uk) => _worldUk,
        (CityListKind.world, NameLanguage.en) => _worldEn,
      };

  /// Each city's lookup keys in [language] (display name and aliases,
  /// normalized) and the first letter of its display name. Cities without a
  /// name in [language] are left out.
  static Map<int, _NormalizedNames> _normalizedNames(
    List<City> cities,
    NameLanguage language,
  ) => {
    for (final city in cities)
      if (city.name(language) case final display?)
        city.id: _NormalizedNames.of(display, city.aliases(language)),
  };

  /// Assigns tiers within one index (list × language): by population rank
  /// against [limits], then sovereign capitals are lifted to tier 1.
  ///
  /// Ranks count only the cities playable in that language (T20). Most of
  /// the World list past its top 1,000 has no Ukrainian name, so ranking the
  /// whole list left the Ukrainian Hard bot 2,138 cities against 5,038 in
  /// English. Ranked per index, each language's bot knows the same number of
  /// its best-known cities. The Ukraine list is the same in both languages.
  static Map<int, int> _tiers(Iterable<City> cities, List<int> limits) {
    for (var i = 0; i < limits.length; i++) {
      if (limits[i] <= 0 || (i > 0 && limits[i] <= limits[i - 1])) {
        throw ArgumentError.value(limits, 'limits', 'must be ascending and > 0');
      }
    }
    if (limits.length != tierCount - 1) {
      throw ArgumentError.value(limits, 'limits', 'needs ${tierCount - 1} limits');
    }

    final byPopulation = [...cities]..sort(_byPopulation);
    return {
      for (final (rank, city) in byPopulation.indexed)
        city.id: isSovereignCapital(city)
            ? 1
            : 1 + limits.where((limit) => rank >= limit).length,
    };
  }
}

/// The cities of one list, playable in one language: every lookup a game
/// needs.
class CityIndex {
  CityIndex._(
    this.list,
    this.language,
    Iterable<City> listCities,
    Map<int, int> tiers,
    Map<int, _NormalizedNames> names,
    int letterMinimum,
  ) : _tiers = tiers {
    final playable = [
      for (final city in listCities)
        if (names.containsKey(city.id)) city,
    ]..sort((a, b) => _byFame(a, b, tiers));
    cities = List.unmodifiable(playable);
    _ids = {for (final city in playable) city.id};

    final byName = <String, List<City>>{};
    final byLetter = <String, List<City>>{};
    for (final city in playable) {
      final cityNames = names[city.id];
      if (cityNames == null) continue;
      for (final key in cityNames.keys) {
        (byName[key] ??= []).add(city);
      }
      if (cityNames.firstLetter case final letter?) {
        (byLetter[letter] ??= []).add(city);
      }
    }

    // Among same-named cities the most populous is found first; letter
    // lists keep the fame order of `playable`.
    _byName = {
      for (final MapEntry(:key, :value) in byName.entries)
        key: List.unmodifiable(value..sort(_byPopulation)),
    };
    _byLetter = {
      for (final MapEntry(:key, :value) in byLetter.entries)
        key: List.unmodifiable(value),
    };
    _letterRanks = {
      for (final starters in _byLetter.values)
        for (final (rank, city) in starters.indexed) city.id: rank,
    };
    firstLetters = Set.unmodifiable(_byLetter.keys);
    final common = {
      for (final MapEntry(key: letter, value: starters) in _byLetter.entries)
        if (starters.length >= letterMinimum) letter,
    };
    playableLetters = Set.unmodifiable(
      _withoutTraps(common, [
        for (final city in playable)
          if (names[city.id] case final cityNames?) cityNames.display,
      ]),
    );
    trapLetters = Set.unmodifiable(common.difference(playableLetters));
  }

  /// [letters] minus the trap letters ([trapLetterRatio]), given every
  /// city's normalized display name.
  ///
  /// Traps are removed one at a time, worst first, and the demand is counted
  /// again after each: skipping «а» moves Полтава's demand to «в», which may
  /// make «в» the next trap. It stops when no letter is over the ratio.
  Set<String> _withoutTraps(Set<String> letters, List<String> displayNames) {
    final kept = {...letters};
    while (true) {
      final demand = <String, int>{};
      for (final name in displayNames) {
        if (LetterRule.requiredNextLetter(name, kept) case final letter?) {
          demand[letter] = (demand[letter] ?? 0) + 1;
        }
      }
      String? worst;
      var worstRatio = trapLetterRatio;
      for (final letter in kept) {
        final ratio = (demand[letter] ?? 0) / startingWith(letter).length;
        if (ratio > worstRatio) (worst, worstRatio) = (letter, ratio);
      }
      if (worst == null) return kept;
      kept.remove(worst);
    }
  }

  final CityListKind list;
  final NameLanguage language;
  final Map<int, int> _tiers;
  late final Map<String, List<City>> _byName;
  late final Map<String, List<City>> _byLetter;
  late final Map<int, int> _letterRanks;

  /// Every city in [list] that has a name in [language], best known first.
  late final List<City> cities;
  late final Set<int> _ids;

  /// Whether the city with GeoNames id [cityId] is in this index: in
  /// [list], with a name in [language].
  bool contains(int cityId) => _ids.contains(cityId);

  /// The (normalized) letters at least one city's display name starts with.
  late final Set<String> firstLetters;

  /// The letters the letter rule can require: those at least
  /// [LetterMinimums] cities start with, minus the [trapLetters]. Every
  /// other letter is skipped (game_design §2.3). A city starting with one
  /// (Йокогама in World, Енергодар in Ukraine) is played as an opening move,
  /// or as a rare letter (`Match.extraLetters`).
  late final Set<String> playableLetters;

  /// Letters enough cities start with that are skipped anyway, as traps
  /// ([trapLetterRatio]): «а» in the Ukraine list.
  late final Set<String> trapLetters;

  /// The letter the city after [previous] must start with (see
  /// [LetterRule]), or `null` when any letter will do.
  String? requiredLetterAfter(City previous) => LetterRule.requiredNextLetter(
    previous.name(language) ?? '',
    playableLetters,
  );

  /// Which letters of [city]'s display name the chat marks: the next letter
  /// and the rarer ones skipped after it (see [LetterRule.letterMarks]).
  LetterMarks letterMarks(City city) => LetterRule.letterMarks(
    city.name(language) ?? '',
    playableLetters,
    startingLetters: firstLetters,
  );

  /// The cities [answer] names, by display name or alias, most populous
  /// first. Empty when it names none.
  ///
  /// Several cities can share a name (Victoria, Kingston); the caller picks
  /// the first one that hasn't been used yet.
  List<City> lookup(String answer) =>
      _byName[normalizeName(answer)] ?? const [];

  /// The cities whose display name starts with [letter], best known first.
  List<City> startingWith(String letter) =>
      _byLetter[normalizeName(letter)] ?? const [];

  /// Where [city] stands among the cities starting with its letter: 0 for
  /// the best known (see [startingWith]), or `null` if the city isn't in
  /// this index or starts with a digit.
  int? letterRankOf(City city) => _letterRanks[city.id];

  /// The tier of [city] in this index (1 = best known), or `null` if the
  /// city isn't in it.
  int? tierOf(City city) =>
      city.name(language) == null ? null : _tiers[city.id];
}

/// One city's names in one language, normalized once at build time.
class _NormalizedNames {
  _NormalizedNames(this.display, this.keys, this.firstLetter);

  factory _NormalizedNames.of(String display, List<String> aliases) {
    final normalizedDisplay = normalizeName(display);
    final keys = {
      normalizedDisplay,
      for (final alias in aliases) normalizeName(alias),
    }..remove('');
    return _NormalizedNames(
      normalizedDisplay,
      keys,
      firstLetterOfNormalized(normalizedDisplay),
    );
  }

  /// The normalized display name: what the letter rule reads.
  final String display;

  /// Every normalized name the city answers to.
  final Set<String> keys;

  /// The first letter of the display name, or `null` for a digit.
  final String? firstLetter;
}

/// Most populous first; ties broken by id so the order is deterministic.
int _byPopulation(City a, City b) {
  final byPopulation = b.population.compareTo(a.population);
  return byPopulation != 0 ? byPopulation : a.id.compareTo(b.id);
}

/// Fame order: lower tier first, then most populous.
int _byFame(City a, City b, Map<int, int> tiers) {
  final byTier = (tiers[a.id] ?? tierCount).compareTo(tiers[b.id] ?? tierCount);
  return byTier != 0 ? byTier : _byPopulation(a, b);
}
