import 'package:equatable/equatable.dart';

import '../../engine/city.dart';
import '../../engine/letter_rule.dart';
import '../../engine/match.dart';

/// A game, as the game screen sees it (tech_design §3).
sealed class GameState extends Equatable {
  const GameState();
}

/// The game hasn't started yet.
final class GameLoading extends GameState {
  const GameLoading();

  @override
  List<Object?> get props => const [];
}

/// A game in progress: one state for the whole game, so a rejection or a
/// timer tick is just a new copy of it.
final class GamePlaying extends GameState {
  const GamePlaying({
    required this.history,
    required this.letterMarks,
    required this.turn,
    required this.requiredLetter,
    this.extraLetters = const [],
    required this.secondsLeft,
    required this.score,
    required this.chain,
    required this.hintsLeft,
    this.lastRejection,
  });

  /// Every city played so far, by both sides, in order.
  final List<Turn> history;

  /// The letters the chat marks in the newest city: the next letter and
  /// the rarer ones skipped after it. `null` before the first city.
  final LetterMarks? letterMarks;

  /// Whose move it is. On [Side.bot], CityBot is "thinking".
  final Side turn;

  /// The letter the next city must start with, or `null` for any letter.
  final String? requiredLetter;

  /// Rarer letters the player may use instead (`Match.extraLetters`).
  final List<String> extraLetters;

  /// The player's countdown. It runs only on the player's turn, and a wrong
  /// answer doesn't reset it. On the bot's turn it shows the full turn time
  /// the player will get next.
  final int secondsLeft;

  final int score;

  /// How many cities the player named themselves (hints don't count).
  final int chain;

  final int hintsLeft;

  /// Why the player's last answer was rejected, until they play a city.
  final RejectionReason? lastRejection;

  @override
  List<Object?> get props => [
    history,
    letterMarks,
    turn,
    requiredLetter,
    extraLetters,
    secondsLeft,
    score,
    chain,
    hintsLeft,
    lastRejection,
  ];
}

/// The game ended: [result] is the summary, and [history] is every city
/// played, for the game-over view.
final class GameOver extends GameState {
  const GameOver({required this.result, required this.history});

  final MatchResult result;
  final List<Turn> history;

  /// The cities the player named themselves, in order (hints don't count).
  List<City> get namedCities => _cities(result.namedCityIds);

  /// The ones the player named for the first time ever.
  List<City> get newCities => _cities(result.newCityIds);

  /// The ones the player had named in earlier games.
  List<City> get knownCities {
    final newIds = result.newCityIds.toSet();
    return [
      for (final city in namedCities)
        if (!newIds.contains(city.id)) city,
    ];
  }

  List<City> _cities(List<int> ids) {
    final byId = {for (final turn in history) turn.city.id: turn.city};
    return [for (final id in ids) ?byId[id]];
  }

  @override
  List<Object?> get props => [result, history];
}
