import 'city_list.dart';

/// How hard a game is (game_design §2.3, §2.5, §2.8).
///
/// Every value here is a **tuning value**, a first guess to be set by the
/// balance simulator and playtests (T20).
enum Difficulty {
  easy(
    maxTier: 1,
    turnTime: Duration(seconds: 45),
    winMultiplier: 1,
    letterSkipping: LetterSkipping.rareAndTraps,
  ),
  medium(
    maxTier: 2,
    turnTime: Duration(seconds: 30),
    winMultiplier: 2,
    letterSkipping: LetterSkipping.rare,
  ),
  hard(
    maxTier: 3,
    turnTime: Duration(seconds: 20),
    winMultiplier: 3,
    letterSkipping: LetterSkipping.rare,
  );

  const Difficulty({
    required this.maxTier,
    required this.turnTime,
    required this.winMultiplier,
    required this.letterSkipping,
  });

  /// The bot's vocabulary: every city of tier 1 up to this tier. Easy knows
  /// only the best-known cities, so it runs out first and is beatable.
  final int maxTier;

  /// How long the player has for each turn. The timer doesn't reset on a
  /// wrong answer.
  final Duration turnTime;

  /// The win bonus is `winBonus × winMultiplier` (see `scoring.dart`, T09).
  final int winMultiplier;

  /// Which letters the letter rule skips. Easy also skips the trap letters,
  /// so the player isn't stuck on Ukraine's «а» (T25).
  final LetterSkipping letterSkipping;
}
