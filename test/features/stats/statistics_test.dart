import 'package:cities/data/player_data.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/stats/statistics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

// The fixture: Kyiv, Lviv, Kharkiv (Ukraine, so also World), Paris, Mumbai.
const _kyiv = 703448;
const _lviv = 702550;
const _paris = 2988507;
const _unknownId = 1; // not in the catalog (e.g. from an older dataset)

Statistics _of(PlayerData data, [NameLanguage language = NameLanguage.en]) =>
    Statistics.of(
      data,
      ukraine: fixtureCatalog.index(CityListKind.ukraine, language),
      world: fixtureCatalog.index(CityListKind.world, language),
    );

void main() {
  test(
    'a new player: empty, with six empty records and nothing discovered',
    () {
      final stats = _of(const PlayerData());
      expect(stats.isEmpty, isTrue);
      expect(stats.winRate, 0);
      expect(stats.records, hasLength(6));
      expect(stats.records.values, everyElement(const ModeRecord()));
      expect(stats.discovery, {
        CityListKind.ukraine: const Discovery(found: 0, total: 3),
        CityListKind.world: const Discovery(found: 0, total: 5),
      });
    },
  );

  test('totals, win rate, and the played modes', () {
    const hard = GameSetup(
      list: CityListKind.world,
      difficulty: Difficulty.hard,
    );
    final stats = _of(
      PlayerData(
        gamesPlayed: 4,
        gamesWon: 3,
        longestChain: 9,
        records: {hard: const ModeRecord(wins: 3, losses: 1, bestScore: 300)},
      ),
    );
    expect(stats.isEmpty, isFalse);
    expect(stats.winRate, 0.75);
    expect([stats.gamesPlayed, stats.gamesWon, stats.longestChain], [4, 3, 9]);
    expect(
      stats.records[hard],
      const ModeRecord(wins: 3, losses: 1, bestScore: 300),
    );
    expect(stats.records[const GameSetup()], const ModeRecord());
  });

  test('discovery counts each list\'s own cities; the total counts all', () {
    final stats = _of(
      const PlayerData(discoveredIds: {_kyiv, _lviv, _paris, _unknownId}),
    );
    expect(stats.citiesDiscovered, 4);
    expect(
      stats.discovery[CityListKind.ukraine],
      const Discovery(found: 2, total: 3),
    );
    expect(
      stats.discovery[CityListKind.world],
      const Discovery(found: 3, total: 5),
    );
    expect(stats.discovery[CityListKind.world]?.fraction, 0.6);
  });

  test('an empty list has no progress, not a division by zero', () {
    expect(const Discovery(found: 0, total: 0).fraction, 0);
  });
}
