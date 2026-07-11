import 'package:equatable/equatable.dart';

import '../game/app_language.dart';
import '../game/game_mode.dart';

/// Domain entity representing an active or historic game session.
class GameSession extends Equatable {
  /// Unique session ID
  final String id;

  /// Game mode (Ukraine / World).
  final GameMode mode;

  /// Language used in this session.
  final AppLanguage language;

  /// List of used city IDs in this session
  final List<int> usedCityIds;

  /// Remaining time (seconds)
  final int timerSeconds;

  /// Whether the session is active or completed
  final bool isActive;

  /// Accumulated score for this session.
  final int score;

  const GameSession({
    required this.id,
    required this.mode,
    required this.language,
    required this.usedCityIds,
    required this.timerSeconds,
    required this.isActive,
    this.score = 0,
  });

  @override
  List<Object?> get props =>
      [id, mode, language, usedCityIds, timerSeconds, isActive, score];
}
