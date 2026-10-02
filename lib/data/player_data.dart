import 'package:equatable/equatable.dart';

import '../engine/city_list.dart';
import '../engine/difficulty.dart';
import '../engine/match.dart';

/// The `version` of the [PlayerData] JSON this app writes. Bump it when the
/// format changes, and teach [PlayerData.fromJson] to read the old one, or
/// players lose their progress (an unknown version is reset).
const int playerDataVersion = 1;

/// A list and a difficulty: what the setup sheet picks for the next game
/// (game_design §2.1), and the key of the per-mode records.
final class GameSetup extends Equatable {
  const GameSetup({
    this.list = CityListKind.ukraine,
    this.difficulty = Difficulty.medium,
  });

  final CityListKind list;
  final Difficulty difficulty;

  GameSetup copyWith({CityListKind? list, Difficulty? difficulty}) => GameSetup(
    list: list ?? this.list,
    difficulty: difficulty ?? this.difficulty,
  );

  /// `{"list": "ukraine", "difficulty": "medium"}`.
  factory GameSetup.fromJson(Object? json) => switch (json) {
    {'list': final String list, 'difficulty': final String difficulty} =>
      GameSetup(
        list: _enum(CityListKind.values, list),
        difficulty: _enum(Difficulty.values, difficulty),
      ),
    _ => throw const FormatException('Not a game setup'),
  };

  Map<String, Object?> toJson() => {
    'list': list.name,
    'difficulty': difficulty.name,
  };

  /// `ukraine.medium`: the key of this mode in the records map.
  String get key => '${list.name}.${difficulty.name}';

  static GameSetup fromKey(String key) => switch (key.split('.')) {
    [final list, final difficulty] => GameSetup(
      list: _enum(CityListKind.values, list),
      difficulty: _enum(Difficulty.values, difficulty),
    ),
    _ => throw FormatException('Not a mode key', key),
  };

  @override
  List<Object?> get props => [list, difficulty];
}

/// The player's settings. The language isn't here: `easy_localization` owns
/// and saves it.
final class Settings extends Equatable {
  const Settings({this.firstTurn = Side.bot});

  /// Who names the first city (game_design §2.2). CityBot by default.
  final Side firstTurn;

  /// `{"firstTurn": "bot"}`.
  factory Settings.fromJson(Object? json) => switch (json) {
    {'firstTurn': final String firstTurn} => Settings(
      firstTurn: _enum(Side.values, firstTurn),
    ),
    _ => throw const FormatException('Not settings'),
  };

  Map<String, Object?> toJson() => {'firstTurn': firstTurn.name};

  @override
  List<Object?> get props => [firstTurn];
}

/// Wins, losses and the best score in one list × difficulty.
final class ModeRecord extends Equatable {
  const ModeRecord({this.wins = 0, this.losses = 0, this.bestScore = 0});

  final int wins;
  final int losses;
  final int bestScore;

  factory ModeRecord.fromJson(Object? json) => switch (json) {
    {
      'wins': final int wins,
      'losses': final int losses,
      'bestScore': final int bestScore,
    } =>
      ModeRecord(wins: wins, losses: losses, bestScore: bestScore),
    _ => throw const FormatException('Not a mode record'),
  };

  Map<String, Object?> toJson() => {
    'wins': wins,
    'losses': losses,
    'bestScore': bestScore,
  };

  @override
  List<Object?> get props => [wins, losses, bestScore];
}

/// Everything the app remembers about the player between launches
/// (tech_design §6), saved by `PlayerStore`. A new player is the default
/// value: nothing discovered, no games, Ukraine / Medium, CityBot starts.
final class PlayerData extends Equatable {
  const PlayerData({
    this.discoveredIds = const {},
    this.records = const {},
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.longestChain = 0,
    this.lastSetup = const GameSetup(),
    this.settings = const Settings(),
  });

  /// GeoNames ids of every city the player has named (hints don't count).
  /// Ids are the same in both lists, so one set serves both.
  final Set<int> discoveredIds;

  /// Per list × difficulty. A mode with no games has no entry.
  final Map<GameSetup, ModeRecord> records;

  final int gamesPlayed;
  final int gamesWon;
  final int longestChain;

  /// The setup sheet opens with this.
  final GameSetup lastSetup;

  final Settings settings;

  PlayerData copyWith({
    Set<int>? discoveredIds,
    Map<GameSetup, ModeRecord>? records,
    int? gamesPlayed,
    int? gamesWon,
    int? longestChain,
    GameSetup? lastSetup,
    Settings? settings,
  }) => PlayerData(
    discoveredIds: discoveredIds ?? this.discoveredIds,
    records: records ?? this.records,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    gamesWon: gamesWon ?? this.gamesWon,
    longestChain: longestChain ?? this.longestChain,
    lastSetup: lastSetup ?? this.lastSetup,
    settings: settings ?? this.settings,
  );

  /// Reads what [toJson] wrote. Throws a [FormatException] for anything else,
  /// including another [playerDataVersion]; `PlayerStore` then backs the file
  /// up and starts over.
  factory PlayerData.fromJson(Object? json) {
    if (json case {
      'version': final int version,
    } when version != playerDataVersion) {
      throw FormatException('Unknown player data version', version);
    }
    return switch (json) {
      {
        'version': playerDataVersion,
        'discoveredIds': final List<Object?> discoveredIds,
        'records': final Map<String, Object?> records,
        'gamesPlayed': final int gamesPlayed,
        'gamesWon': final int gamesWon,
        'longestChain': final int longestChain,
        'lastSetup': final Object? lastSetup,
        'settings': final Object? settings,
      } =>
        PlayerData(
          discoveredIds: {
            for (final id in discoveredIds)
              id is int ? id : throw FormatException('Not a city id', id),
          },
          records: {
            for (final MapEntry(:key, :value) in records.entries)
              GameSetup.fromKey(key): ModeRecord.fromJson(value),
          },
          gamesPlayed: gamesPlayed,
          gamesWon: gamesWon,
          longestChain: longestChain,
          lastSetup: GameSetup.fromJson(lastSetup),
          settings: Settings.fromJson(settings),
        ),
      _ => throw const FormatException('Not player data'),
    };
  }

  Map<String, Object?> toJson() => {
    'version': playerDataVersion,
    // Sorted, so the file only changes when the set does.
    'discoveredIds': discoveredIds.toList()..sort(),
    'records': {
      for (final MapEntry(:key, :value) in records.entries)
        key.key: value.toJson(),
    },
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'longestChain': longestChain,
    'lastSetup': lastSetup.toJson(),
    'settings': settings.toJson(),
  };

  @override
  List<Object?> get props => [
    discoveredIds,
    records,
    gamesPlayed,
    gamesWon,
    longestChain,
    lastSetup,
    settings,
  ];
}

/// The enum value called [name]: enums are saved by name, so renaming a
/// value is a format change.
T _enum<T extends Enum>(List<T> values, String name) =>
    values.asNameMap()[name] ?? (throw FormatException('Unknown value', name));
