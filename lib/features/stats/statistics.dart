import 'package:equatable/equatable.dart';

import '../../data/player_data.dart';
import '../../engine/city_catalog.dart';
import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';

/// How much of one city list the player has discovered.
final class Discovery extends Equatable {
  const Discovery({required this.found, required this.total});

  /// Discovered cities in the list.
  final int found;

  /// Cities in the list that can be played in the app's language: in
  /// Ukrainian, World has ~7k cities (those with a Ukrainian name), not 31k,
  /// and the bar shouldn't promise cities that can't be named.
  final int total;

  /// From 0 to 1.
  double get fraction => total == 0 ? 0 : found / total;

  @override
  List<Object?> get props => [found, total];
}

/// What the Statistics screen shows (game_design §3.6), derived from the
/// saved [PlayerData] and the city lists in the app's language.
final class Statistics extends Equatable {
  const Statistics({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.longestChain,
    required this.citiesDiscovered,
    required this.records,
    required this.discovery,
  });

  factory Statistics.of(
    PlayerData data, {
    required CityIndex ukraine,
    required CityIndex world,
  }) {
    Discovery discovery(CityIndex index) => Discovery(
      found: data.discoveredIds.where(index.contains).length,
      total: index.cities.length,
    );
    return Statistics(
      gamesPlayed: data.gamesPlayed,
      gamesWon: data.gamesWon,
      longestChain: data.longestChain,
      citiesDiscovered: data.discoveredIds.length,
      records: {
        for (final list in CityListKind.values)
          for (final difficulty in Difficulty.values)
            GameSetup(list: list, difficulty: difficulty):
                data.records[GameSetup(list: list, difficulty: difficulty)] ??
                const ModeRecord(),
      },
      discovery: {
        CityListKind.ukraine: discovery(ukraine),
        CityListKind.world: discovery(world),
      },
    );
  }

  final int gamesPlayed;
  final int gamesWon;
  final int longestChain;

  /// In both lists together, in any language.
  final int citiesDiscovered;

  /// All six list × difficulty modes; a mode never played has an empty
  /// record.
  final Map<GameSetup, ModeRecord> records;

  final Map<CityListKind, Discovery> discovery;

  /// Games won, from 0 to 1; 0 before the first game.
  double get winRate => gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;

  /// No games yet: the screen shows a welcome instead of zeros.
  bool get isEmpty => gamesPlayed == 0;

  @override
  List<Object?> get props => [
    gamesPlayed,
    gamesWon,
    longestChain,
    citiesDiscovered,
    records,
    discovery,
  ];
}
