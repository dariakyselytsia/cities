/// How hard a game is (game_design §2.5, §2.8).
///
/// Every value here is a **tuning value**. The vocabulary was set with the
/// balance simulator (`tool/simulate.dart`, T20); the turn times wait for a
/// real playtest (T28).
enum Difficulty {
  easy(
    maxTier: 1,
    turnTime: Duration(seconds: 45),
    winMultiplier: 1,
    minCitiesPerLetter: 2,
  ),
  medium(
    maxTier: 2,
    turnTime: Duration(seconds: 30),
    winMultiplier: 2,
    minCitiesPerLetter: 6,
  ),
  hard(
    maxTier: 3,
    turnTime: Duration(seconds: 20),
    winMultiplier: 3,
    minCitiesPerLetter: 10,
  );

  const Difficulty({
    required this.maxTier,
    required this.turnTime,
    required this.winMultiplier,
    required this.minCitiesPerLetter,
  });

  /// The bot's vocabulary: every city of tier 1 up to this tier. Easy knows
  /// only the best-known cities, so it runs out first and is beatable.
  final int maxTier;

  /// How long the player has for each turn. The timer doesn't reset on a
  /// wrong answer.
  ///
  /// Still the first guesses: the simulator measures what a player knows,
  /// not how fast they recall it, so these are timed in the playtest
  /// (T28).
  final Duration turnTime;

  /// The win bonus is `winBonus × winMultiplier` (see `scoring.dart`, T09).
  final int winMultiplier;

  /// CityBot also knows the best-known cities of **every letter**, at least
  /// this many (or all of them, if fewer start with it), whatever their
  /// tier.
  ///
  /// Why (T20): tiers follow population, so they leave holes. The Easy
  /// World bot knew no «ж» city and the Medium one no «ю», and a player won
  /// just by steering onto such a letter. In the Ukraine list, Easy games
  /// ended after the player named ~4 cities; with this floor they last
  /// ~14 for a keen player, and Medium ~20.
  final int minCitiesPerLetter;
}
