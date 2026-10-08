import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';

/// How a simulated player picks among the cities it knows (T20).
enum PlayerStrategy {
  /// Any known city that fits, at random: a casual player.
  random,

  /// The known city that leaves CityBot the fewest cities for its next
  /// letter: a player who tries to corner the bot (on «а», say).
  steering,
}

/// A player who knows the [known] best-known cities of an index and never
/// runs out of time: it answers whenever it knows a city that fits, uses its
/// hints when it doesn't, and loses when they're gone too.
///
/// [bot] is the CityBot it plays against: the steering player needs to know
/// what the bot knows.
class SimPlayer {
  SimPlayer({
    required this.index,
    required this.bot,
    required int known,
    required this.strategy,
  }) : _knownByLetter = _byLetter(index, index.cities.take(known)),
       _botByLetter = _byLetter(index, index.cities.where(bot.knows));

  final CityIndex index;

  /// The bot to play against. Its `Random` is replaced per game.
  final CityBot bot;
  Difficulty get difficulty => bot.difficulty;

  final PlayerStrategy strategy;

  /// The player's cities, by first letter, best known first.
  final Map<String, List<City>> _knownByLetter;

  /// The bot's vocabulary, by first letter.
  final Map<String, List<City>> _botByLetter;

  static Map<String, List<City>> _byLetter(
    CityIndex index,
    Iterable<City> cities,
  ) {
    final ids = {for (final city in cities) city.id};
    return {
      for (final letter in index.firstLetters)
        letter: [
          for (final city in index.startingWith(letter))
            if (ids.contains(city.id)) city,
        ],
    };
  }

  /// The city to name, or `null` when the player knows none that fits.
  City? answer(Match match, Random random) {
    final used = match.usedIds;
    final required = match.requiredLetter;
    final letters = required == null
        ? _knownByLetter.keys
        : [required, ...match.extraLetters];
    final candidates = [
      for (final letter in letters)
        for (final city in _knownByLetter[letter] ?? const <City>[])
          if (!used.contains(city.id)) city,
    ];
    if (candidates.isEmpty) return null;
    return switch (strategy) {
      PlayerStrategy.random => candidates[random.nextInt(candidates.length)],
      PlayerStrategy.steering => _corner(candidates, used, random),
    };
  }

  /// The candidate after which the bot knows the fewest unused cities.
  City _corner(List<City> candidates, Set<int> used, Random random) {
    int botOptions(City city) {
      final next = index.requiredLetterAfter(city);
      if (next == null) return 1 << 20; // any letter: the bot can't be stuck
      return (_botByLetter[next] ?? const <City>[])
          .where((c) => c.id != city.id && !used.contains(c.id))
          .length;
    }

    final scored = [for (final city in candidates) (botOptions(city), city)];
    final best = scored.map((s) => s.$1).reduce(min);
    final options = [
      for (final (score, city) in scored)
        if (score == best) city,
    ];
    return options[random.nextInt(options.length)];
  }
}

/// How one simulated game went.
class GameRecord {
  const GameRecord({
    required this.outcome,
    required this.chain,
    required this.turns,
    required this.endLetter,
  });

  /// `null` when the game hit the turn limit without an end.
  final MatchOutcome? outcome;

  /// Cities the player named.
  final int chain;

  /// Cities played by both sides.
  final int turns;

  /// The letter that ended it: the one CityBot couldn't answer, or the one
  /// the player was stuck on.
  final String? endLetter;

  bool get isWin => outcome?.isWin ?? false;
}

/// Plays one game of [player] against CityBot, with [seed] driving both,
/// CityBot opening (the default). [createBot] builds the bot from the game's
/// `Random` (the real `CityBot` by default). It stops at [maxTurns].
GameRecord simulateGame({
  required SimPlayer player,
  required int seed,
  CityBot Function(Random random)? createBot,
  int maxTurns = 2000,
}) {
  final random = Random(seed);
  final index = player.index;
  final match = Match(
    index: index,
    difficulty: player.difficulty,
    random: random,
    bot: createBot?.call(random),
  );
  String? endLetter;
  while (!match.isOver && match.history.length < maxTurns) {
    endLetter = match.requiredLetter;
    switch (match.turn) {
      case Side.bot:
        match.botMove();
      case Side.player:
        final city = player.answer(match, random);
        if (city != null) {
          final result = match.submit(city.name(index.language) ?? '');
          if (result is Rejected) {
            throw StateError('${city.nameEn} was rejected: ${result.reason}');
          }
        } else if (match.hint() == null) {
          match.timeout();
        }
    }
  }
  return GameRecord(
    outcome: match.result?.outcome,
    chain: match.chain,
    turns: match.history.length,
    endLetter: match.isOver ? endLetter : null,
  );
}
