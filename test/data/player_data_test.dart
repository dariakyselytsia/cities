import 'dart:convert';

import 'package:cities/data/player_data.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:flutter_test/flutter_test.dart';

/// A player with something in every field.
final _veteran = PlayerData(
  discoveredIds: {703448, 702550, 2643743},
  records: {
    GameSetup(): ModeRecord(wins: 3, losses: 2, bestScore: 410),
    GameSetup(list: CityListKind.world, difficulty: Difficulty.hard):
        ModeRecord(losses: 1, bestScore: 35),
  },
  gamesPlayed: 6,
  gamesWon: 3,
  longestChain: 17,
  lastSetup: GameSetup(list: CityListKind.world, difficulty: Difficulty.hard),
  settings: Settings(firstTurn: Side.player),
);

Map<String, Object?> _json(PlayerData data) =>
    jsonDecode(jsonEncode(data.toJson())) as Map<String, Object?>;

void main() {
  test('a new player: nothing discovered, no games, Ukraine / Medium, '
      'CityBot starts', () {
    const data = PlayerData();
    expect(data.discoveredIds, isEmpty);
    expect(data.records, isEmpty);
    expect([data.gamesPlayed, data.gamesWon, data.longestChain], [0, 0, 0]);
    expect(data.lastSetup, const GameSetup());
    expect(data.settings.firstTurn, Side.bot);
  });

  test('the JSON format (tech_design §6)', () {
    expect(_json(_veteran), {
      'version': 1,
      'discoveredIds': [702550, 703448, 2643743],
      'records': {
        'ukraine.medium': {'wins': 3, 'losses': 2, 'bestScore': 410},
        'world.hard': {'wins': 0, 'losses': 1, 'bestScore': 35},
      },
      'gamesPlayed': 6,
      'gamesWon': 3,
      'longestChain': 17,
      'lastSetup': {'list': 'world', 'difficulty': 'hard'},
      'settings': {'firstTurn': 'player'},
    });
  });

  test('round-trips through JSON', () {
    expect(PlayerData.fromJson(_json(_veteran)), _veteran);
    expect(PlayerData.fromJson(_json(const PlayerData())), const PlayerData());
  });

  group('withResult folds in a finished game', () {
    const ukraineMedium = GameSetup();
    const worldHard = GameSetup(
      list: CityListKind.world,
      difficulty: Difficulty.hard,
    );

    MatchResult result(
      MatchOutcome outcome, {
      int score = 0,
      List<int> named = const [],
      List<int> fresh = const [],
    }) => MatchResult(
      outcome: outcome,
      score: score,
      chain: named.length,
      newCityIds: fresh,
      namedCityIds: named,
    );

    test('a first win', () {
      final data = const PlayerData().withResult(
        ukraineMedium,
        result(
          MatchOutcome.botGaveUp,
          score: 150,
          named: [703448, 702550],
          fresh: [703448, 702550],
        ),
      );
      expect(
        data,
        PlayerData(
          discoveredIds: const {703448, 702550},
          records: {ukraineMedium: const ModeRecord(wins: 1, bestScore: 150)},
          gamesPlayed: 1,
          gamesWon: 1,
          longestChain: 2,
        ),
      );
    });

    test('a loss after it: totals add up, bests only go up, the setup and '
        'settings stay', () {
      final before = _veteran;
      final data = before.withResult(
        ukraineMedium,
        result(
          MatchOutcome.timeout,
          score: 60,
          named: [703448, 706483], // Kyiv was known; Kharkiv is new
          fresh: [706483],
        ),
      );
      expect(data.discoveredIds, {...before.discoveredIds, 706483});
      expect(
        data.records[ukraineMedium],
        const ModeRecord(wins: 3, losses: 3, bestScore: 410),
      );
      expect(data.records[worldHard], before.records[worldHard]);
      expect(data.gamesPlayed, 7);
      expect(data.gamesWon, 3);
      expect(data.longestChain, 17);
      expect(data.lastSetup, before.lastSetup);
      expect(data.settings, before.settings);
    });

    test('a better score and a longer chain are recorded', () {
      final data = _veteran.withResult(
        worldHard,
        result(
          MatchOutcome.surrendered,
          score: 500,
          named: List.generate(20, (i) => i + 1),
        ),
      );
      expect(
        data.records[worldHard],
        const ModeRecord(losses: 2, bestScore: 500),
      );
      expect(data.longestChain, 20);
      // Every named city counts as discovered, even if the game missed it.
      expect(data.discoveredIds, containsAll(List.generate(20, (i) => i + 1)));
    });
  });

  group('rejects with a FormatException', () {
    final valid = _json(_veteran);
    final cases = <String, Object?>{
      'not an object': [1, 2],
      'no version': {...valid}..remove('version'),
      'a newer version': {...valid, 'version': 2},
      'an older version': {...valid, 'version': 0},
      'a missing field': {...valid}..remove('settings'),
      'a city id that is not a number': {
        ...valid,
        'discoveredIds': [703448, '702550'],
      },
      'an unknown list': {
        ...valid,
        'lastSetup': {'list': 'mars', 'difficulty': 'hard'},
      },
      'an unknown difficulty in a record key': {
        ...valid,
        'records': {
          'ukraine.insane': {'wins': 1, 'losses': 0, 'bestScore': 5},
        },
      },
      'a malformed record key': {
        ...valid,
        'records': {
          'ukraine': {'wins': 1, 'losses': 0, 'bestScore': 5},
        },
      },
      'an unknown side': {
        ...valid,
        'settings': {'firstTurn': 'nobody'},
      },
    };
    for (final MapEntry(key: name, value: json) in cases.entries) {
      test(name, () {
        expect(
          () => PlayerData.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    }
  });
}
