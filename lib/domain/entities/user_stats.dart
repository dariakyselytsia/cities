import 'game_session_summary.dart';

/// Domain entity representing user statistics and progress.
class UserStats {
  /// All-time high score for Ukraine mode
  final int highScoreUA;
  /// All-time high score for World mode
  final int highScoreWorld;
  /// List of all city IDs used by the user
  final List<int> usedCityIds;

  /// Map of cityId to usage count (for Most Used Cities)
  final Map<int, int> cityUsageCount;
  /// Map of mode to high score (for per-mode high scores)
  final Map<String, int> highScores;
  /// Map of mode/country to percent of cities discovered
  final Map<String, double> usedCitiesPercent;
  /// The country code where the user has named the most unique cities
  final String favoriteCountry;
  /// The highest number of consecutive correct answers in a session
  final int longestStreak;
  /// Recent session history (score, mode, time, unique cities)
  final List<GameSessionSummary> sessionHistory;

  const UserStats({
    required this.highScoreUA,
    required this.highScoreWorld,
    required this.usedCityIds,
    required this.cityUsageCount,
    required this.highScores,
    required this.usedCitiesPercent,
    required this.favoriteCountry,
    required this.longestStreak,
    required this.sessionHistory,
  });
}
