import 'city.dart';

/// The two city lists a game can be played with (game_design §2.1).
enum CityListKind {
  /// Ukrainian cities, including the towns below 15,000 people.
  ukraine,

  /// Every city with 15,000+ people, Ukraine's included.
  world;

  /// Whether [city] belongs to this list (tech_design §4).
  bool contains(City city) => switch (this) {
    CityListKind.ukraine => city.countryCode == 'UA',
    CityListKind.world => !city.isUkraineOnly,
  };
}

/// The number of fame tiers. Tier 1 is the best known; the last tier is
/// "everything else" (game_design §2.5).
const int tierCount = 4;

/// Where each list's tiers end, as **cumulative population ranks** among
/// the cities playable in the index's language: with `[150, 500, 1500]`,
/// the 150 most populous cities are tier 1, ranks 151–500 tier 2, ranks
/// 501–1,500 tier 3, and the rest tier 4.
///
/// Tuning values, set with `tool/simulate.dart` (T20). The targets: Easy
/// winnable, Medium a challenge, Hard rare. Simulated players know the top
/// N cities: Ukraine 30 / 100 / 300 (casual, keen, expert), World 100 / 400
/// / 1,500. With the per-letter minimums (`Difficulty.minCitiesPerLetter`)
/// and 200 games per row, wins in Ukrainian (English):
/// - Ukraine stays at the T06 guesses. Easy: casual 54% (57%), keen 98%
///   (99%); Medium: keen 56% (26%); Hard: keen 0% (2%), expert 94% (69%).
/// - World shrank from `[300, 1500, 5000]`, where a keen player won Medium
///   ~1% of the time and an expert lost every Hard game in English. Now:
///   Easy: casual 38% (18%), keen 99% (89%); Medium: keen 54% (17%); Hard:
///   keen 1% (0%), expert 94% (92%).
/// English plays harder at the same knowledge.
class TierLimits {
  const TierLimits({required this.ukraine, required this.world});

  /// The tuned values (T20).
  static const TierLimits standard = TierLimits(
    ukraine: [50, 150, 300],
    world: [150, 500, 1500],
  );

  /// Rank limits of tiers 1 to [tierCount] − 1 in the Ukraine list.
  final List<int> ukraine;

  /// Rank limits of tiers 1 to [tierCount] − 1 in the World list.
  final List<int> world;

  List<int> of(CityListKind list) => switch (list) {
    CityListKind.ukraine => ukraine,
    CityListKind.world => world,
  };
}

/// How many cities must start with a letter for the letter rule to require
/// it (game_design §2.3). Rarer letters are skipped like `ь`.
///
/// Why: in World-in-Ukrainian 145 names end in «й» (Шанхай, Дубай) but only
/// 16 start with it, so requiring «й» would jam most games. A fixed number
/// can't serve both lists: at 20, the 848-city Ukraine list would lose «а».
/// These starting values skip «й ї щ» in World and «ї ц е ф є щ» in Ukraine.
/// Tuning values (T20).
class LetterMinimums {
  const LetterMinimums({required this.ukraine, required this.world});

  static const LetterMinimums standard = LetterMinimums(ukraine: 5, world: 20);

  final int ukraine;
  final int world;

  int of(CityListKind list) => switch (list) {
    CityListKind.ukraine => ukraine,
    CityListKind.world => world,
  };
}

/// When a letter is a **trap**, skipped like a rare one: more than this many
/// times as many names require it as cities start with it (game_design
/// §2.3, T25).
///
/// Why: enough cities can start with a letter and it can still jam games.
/// In the Ukraine list 235 names require «а», but only 16 cities start with
/// it. On the real data any ratio from 5 to 8 picks the same letters: «а» in
/// the Ukraine list (in both languages) and nothing in World. The next worst
/// letters are near 4.8 (Ukraine «i» in English, World «я»), so 6 leaves a
/// margin.
///
/// It applies on every difficulty (T20). T25 kept «а» required on Medium
/// and Hard to make them harder, but the simulator showed it didn't: a keen
/// player won about as often (53% vs 56% on Medium), games were ~35%
/// shorter, almost all of them ended on «а», and steering onto «а» paid off.
/// Tuning value.
const double trapLetterRatio = 6;
