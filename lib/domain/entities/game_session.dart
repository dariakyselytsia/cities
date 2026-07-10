/// Domain entity representing an active or historic game session.
class GameSession {
  /// Unique session ID
  final String id;

  /// Game mode (e.g., 'UA', 'WORLD', 'CAPITALS')
  final String mode;

  /// Language used in this session
  final String language;

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
}
