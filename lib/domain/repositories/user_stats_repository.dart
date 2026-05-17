import '../entities/user_stats.dart';

/// Abstract repository for user statistics and progress persistence.
abstract class UserStatsRepository {
  /// Saves the user's high scores and used city IDs.
  Future<void> saveUserStats(UserStats stats);

  /// Retrieves the user's high scores and used city IDs.
  Future<UserStats> getUserStats();
}
