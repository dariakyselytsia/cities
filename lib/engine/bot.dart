import 'dart:math';

import 'package:equatable/equatable.dart';

import 'city.dart';
import 'city_catalog.dart';
import 'difficulty.dart';

/// What CityBot does on its turn.
sealed class BotMove extends Equatable {
  const BotMove();
}

/// The bot names [city].
final class BotPlays extends BotMove {
  const BotPlays(this.city);

  final City city;

  @override
  List<Object?> get props => [city];
}

/// The bot knows no unused city for the letter: the player wins.
final class BotGivesUp extends BotMove {
  const BotGivesUp();

  @override
  List<Object?> get props => const [];
}

/// How much more likely the bot is to pick a city of each tier: index 0 is
/// tier 1. A tier-1 city is 4× as likely as a tier-3 one, so the bot mostly
/// plays cities the player will recognize but still surprises sometimes.
/// Tuning values (T20).
const List<int> botTierWeights = [4, 2, 1, 1];

/// How long CityBot "thinks" before it answers (game_design §2.5). An
/// instant reply feels mechanical; much longer just slows the game down.
/// Tuning values (T20).
const Duration botThinkingMin = Duration(milliseconds: 600);
const Duration botThinkingMax = Duration(milliseconds: 1200);

/// A random thinking time from [botThinkingMin] up to [botThinkingMax], so
/// the bot's rhythm isn't robotic.
Duration botThinkingTime(Random random) =>
    botThinkingMin + (botThinkingMax - botThinkingMin) * random.nextDouble();

/// CityBot: the opponent. It knows only the cities of its [difficulty]'s
/// tiers, plus the best-known few of every letter, and it's beatable because
/// that vocabulary runs out (game_design §2.5).
///
/// Pure and deterministic for a given [random]: tests seed it; the game
/// passes `Random()`.
class CityBot {
  /// [minCitiesPerLetter] exists for tests; the game uses the
  /// [difficulty]'s.
  CityBot({
    required this.index,
    required this.difficulty,
    required Random random,
    int? minCitiesPerLetter,
  }) : _random = random,
       minCitiesPerLetter = minCitiesPerLetter ?? difficulty.minCitiesPerLetter;

  /// The list × language being played.
  final CityIndex index;
  final Difficulty difficulty;

  /// See `Difficulty.minCitiesPerLetter`.
  final int minCitiesPerLetter;
  final Random _random;

  /// Picks the bot's next city.
  ///
  /// It is a random city from the bot's vocabulary that starts with
  /// [requiredLetter] and isn't in [usedIds], weighted toward better-known
  /// tiers ([botTierWeights]). A `null` letter (the opening move, or after a
  /// dead end) allows any city.
  ///
  /// The [extraLetters] (`Match.extraLetters`) are a fallback: the bot plays
  /// one only when it knows no city for [requiredLetter], so it doesn't give
  /// up while it knows Енергодар for «е». It doesn't prefer them, so the
  /// rare cities stay a find for the player (T25). With no city left for
  /// any of these letters, the bot gives up.
  BotMove move({
    required String? requiredLetter,
    List<String> extraLetters = const [],
    required Set<int> usedIds,
  }) {
    List<City> candidates(Iterable<City> cities) => [
      for (final city in cities)
        if (!usedIds.contains(city.id) && knows(city)) city,
    ];
    final city =
        _weightedPick(
          candidates(
            requiredLetter == null
                ? index.cities
                : index.startingWith(requiredLetter),
          ),
        ) ??
        _weightedPick(
          candidates([
            for (final letter in extraLetters) ...index.startingWith(letter),
          ]),
        );
    return city == null ? const BotGivesUp() : BotPlays(city);
  }

  /// Whether [city] is in the bot's vocabulary: within its tiers, or among
  /// the [minCitiesPerLetter] best known of its letter.
  bool knows(City city) {
    final tier = index.tierOf(city);
    if (tier == null) return false;
    return tier <= difficulty.maxTier ||
        (index.letterRankOf(city) ?? minCitiesPerLetter) < minCitiesPerLetter;
  }

  City? _weightedPick(List<City> candidates) {
    if (candidates.isEmpty) return null;
    final weights = [for (final city in candidates) _weight(city)];
    var ticket = _random.nextInt(weights.fold(0, (a, b) => a + b));
    for (final (i, weight) in weights.indexed) {
      if (ticket < weight) return candidates[i];
      ticket -= weight;
    }
    return candidates.last;
  }

  int _weight(City city) {
    final tier = index.tierOf(city) ?? botTierWeights.length;
    return botTierWeights[(tier - 1).clamp(0, botTierWeights.length - 1)];
  }
}
