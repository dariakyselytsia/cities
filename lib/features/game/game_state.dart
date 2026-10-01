import 'package:equatable/equatable.dart';

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
    required this.turn,
    required this.requiredLetter,
    required this.secondsLeft,
    required this.score,
    required this.hintsLeft,
    this.lastRejection,
  });

  /// Every city played so far, by both sides, in order.
  final List<Turn> history;

  /// Whose move it is. On [Side.bot], CityBot is "thinking".
  final Side turn;

  /// The letter the next city must start with, or `null` for any letter.
  final String? requiredLetter;

  /// The player's countdown. It runs only on the player's turn, and a wrong
  /// answer doesn't reset it. On the bot's turn it shows the full turn time
  /// the player will get next.
  final int secondsLeft;

  final int score;
  final int hintsLeft;

  /// Why the player's last answer was rejected, until they play a city.
  final RejectionReason? lastRejection;

  @override
  List<Object?> get props => [
        history,
        turn,
        requiredLetter,
        secondsLeft,
        score,
        hintsLeft,
        lastRejection,
      ];
}

/// The game ended: [result] is the summary, and [history] is every city
/// played, for the game-over view (T13).
final class GameOver extends GameState {
  const GameOver({required this.result, required this.history});

  final MatchResult result;
  final List<Turn> history;

  @override
  List<Object?> get props => [result, history];
}
