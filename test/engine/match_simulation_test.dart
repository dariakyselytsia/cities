import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/letter_rule.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/engine/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

/// Full games on the real data: the real, seeded CityBot against a simulated
/// player who knows the cities up to some tier.
void main() {
  final catalog = CityCatalog.fromJson(
    jsonDecode(File('assets/data/cities.json').readAsStringSync()),
  );

  /// Plays one game to the end and checks the rules on every move.
  MatchResult play({
    required CityIndex index,
    required Difficulty difficulty,
    required int playerMaxTier,
    required int seed,
    Side firstTurn = Side.bot,
  }) {
    final random = Random(seed);
    final match = Match(
      index: index,
      difficulty: difficulty,
      random: random,
      firstTurn: firstTurn,
    );
    final seen = <int>{};

    while (!match.isOver) {
      final letter = match.requiredLetter;
      if (match.turn == Side.bot) {
        if (match.botMove() case BotPlays(:final city)) {
          // The bot follows the letter rule and stays in its tiers.
          expect(
            LetterRule.startsWithRequired(city.name(index.language) ?? '', letter),
            isTrue,
          );
          expect(index.tierOf(city), lessThanOrEqualTo(difficulty.maxTier));
          expect(seen.add(city.id), isTrue, reason: 'no repeats');
        }
        continue;
      }

      // The player names a random city they know, or runs out of time.
      final known = [
        for (final city
            in letter == null ? index.cities : index.startingWith(letter))
          if (!match.usedIds.contains(city.id) &&
              (index.tierOf(city) ?? tierCount) <= playerMaxTier)
            city,
      ];
      if (known.isEmpty) {
        match.timeout();
        break;
      }
      final pick = known[random.nextInt(known.length)];
      final result = match.submit(pick.name(index.language) ?? '');
      expect(result, isA<Accepted>());
      expect(seen.add(pick.id), isTrue, reason: 'no repeats');
    }

    final result = match.result;
    if (result == null) fail('the game did not end');
    // The score adds up: every city was new to this player.
    expect(
      result.score,
      result.chain * pointsForNewCity +
          (result.isWin ? winPoints(difficulty) : 0),
    );
    expect(result.namedCityIds, hasLength(result.chain));
    return result;
  }

  for (final language in NameLanguage.values) {
    final index = catalog.index(CityListKind.world, language);

    test('${language.name}: a player who knows every city beats Easy', () {
      for (final seed in [1, 2, 3, 4, 5]) {
        final result = play(
          index: index,
          difficulty: Difficulty.easy,
          playerMaxTier: tierCount,
          seed: seed,
        );
        expect(result.outcome, MatchOutcome.botGaveUp, reason: 'seed $seed');
        expect(result.chain, greaterThan(0));
      }
    });

    test('${language.name}: a player who knows only tier 1 loses to Hard', () {
      for (final seed in [1, 2, 3, 4, 5]) {
        final result = play(
          index: index,
          difficulty: Difficulty.hard,
          playerMaxTier: 1,
          seed: seed,
        );
        expect(result.outcome, MatchOutcome.timeout, reason: 'seed $seed');
      }
    });
  }

  test('games the player opens play to the end the same way', () {
    final index = catalog.index(CityListKind.ukraine, NameLanguage.uk);
    for (final seed in [1, 2, 3]) {
      final win = play(
        index: index,
        difficulty: Difficulty.easy,
        playerMaxTier: tierCount,
        seed: seed,
        firstTurn: Side.player,
      );
      expect(win.outcome, MatchOutcome.botGaveUp, reason: 'seed $seed');
      final loss = play(
        index: index,
        difficulty: Difficulty.hard,
        playerMaxTier: 1,
        seed: seed,
        firstTurn: Side.player,
      );
      expect(loss.outcome, MatchOutcome.timeout, reason: 'seed $seed');
    }
  });

  test('the same seed replays the same game', () {
    final index = catalog.index(CityListKind.ukraine, NameLanguage.uk);
    MatchResult run() => play(
          index: index,
          difficulty: Difficulty.medium,
          playerMaxTier: 2,
          seed: 99,
        );
    expect(run(), run());
  });
}
