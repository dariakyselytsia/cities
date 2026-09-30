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

/// Where each list's tiers end, as **cumulative population ranks**: with
/// `[300, 1500, 5000]`, the 300 most populous cities are tier 1, ranks
/// 301–1,500 tier 2, ranks 1,501–5,000 tier 3, and the rest tier 4.
///
/// These are tuning values, first guesses to be set by playtesting (T20).
class TierLimits {
  const TierLimits({required this.ukraine, required this.world});

  /// The starting guesses from game_design §2.5.
  static const TierLimits standard = TierLimits(
    ukraine: [50, 150, 300],
    world: [300, 1500, 5000],
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
