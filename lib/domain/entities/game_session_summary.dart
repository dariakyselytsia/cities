/// Value object for lightweight session history statistics.
class GameSessionSummary {
  /// Unique session ID
  final String sessionId;
  /// Game mode (e.g., 'UA', 'WORLD', 'CAPITALS')
  final String mode;
  /// Session score
  final int score;
  /// Session duration in seconds
  final int durationSeconds;
  /// Number of unique cities used
  final int uniqueCities;

  const GameSessionSummary({
    required this.sessionId,
    required this.mode,
    required this.score,
    required this.durationSeconds,
    required this.uniqueCities,
  });
}
