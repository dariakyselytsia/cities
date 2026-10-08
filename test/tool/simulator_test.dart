import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/simulator.dart';

City _city(int id, String name, int population) =>
    City(id: id, nameEn: name, countryCode: 'XX', population: population);

/// Tiers (limits 2 / 3 / 4): Kab, Kac | Bo | Bu | Co.
final _index = CityCatalog(
  [
    _city(1, 'Kab', 900),
    _city(2, 'Kac', 800),
    _city(3, 'Bo', 700),
    _city(4, 'Bu', 600),
    _city(5, 'Co', 1),
  ],
  tierLimits: const TierLimits(ukraine: [1, 2, 3], world: [2, 3, 4]),
  letterMinimums: const LetterMinimums(ukraine: 1, world: 1),
).index(CityListKind.world, NameLanguage.en);

/// A Hard bot that knows only its tiers: not Co.
CityBot _bot(Random random) => CityBot(
  index: _index,
  difficulty: Difficulty.hard,
  random: random,
  minCitiesPerLetter: 0,
);

SimPlayer _player(int known, PlayerStrategy strategy) => SimPlayer(
  index: _index,
  bot: _bot(Random(0)),
  known: known,
  strategy: strategy,
);

void main() {
  test('a steering player names a city that leaves the bot nothing', () {
    for (var seed = 0; seed < 20; seed++) {
      final match = Match(
        index: _index,
        difficulty: Difficulty.hard,
        random: Random(seed),
        firstTurn: Side.player,
        bot: _bot(Random(seed)),
      );
      // Kac and Co lead to «c», and the bot knows no «c» city. Kab and Bo
      // lead to «b» (Bo, Bu), Bu to «b» (Bo).
      final pick = _player(5, PlayerStrategy.steering).answer(
        match,
        Random(seed),
      );
      expect(pick?.nameEn, anyOf('Kac', 'Co'), reason: 'seed $seed');
    }
  });

  test('a player who knows no city uses its hints, then times out', () {
    final record = simulateGame(
      player: _player(0, PlayerStrategy.random),
      seed: 1,
      createBot: _bot,
    );
    expect(record.outcome, MatchOutcome.timeout);
    expect(record.chain, 0, reason: 'hinted cities are not the chain');
  });

  test('the same seed replays the same game', () {
    GameRecord run() => simulateGame(
      player: _player(5, PlayerStrategy.random),
      seed: 7,
      createBot: _bot,
    );
    final a = run();
    final b = run();
    expect(
      [b.outcome, b.chain, b.turns, b.endLetter],
      [a.outcome, a.chain, a.turns, a.endLetter],
    );
  });
}
