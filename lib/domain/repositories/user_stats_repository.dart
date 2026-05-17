import '../entities/user_stats.dart';
import '../entities/game_session.dart';
import '../entities/city.dart';

/// Abstract repository for user statistics and progress persistence.
abstract class UserStatsRepository {
  /// Saves the user's statistics (all fields).
  Future<void> saveUserStats(UserStats stats);

  /// Retrieves the user's statistics (all fields).
  Future<UserStats> getUserStats();

  /// Recalculates all user statistics at the end of a game session.
  /// Should be called with the finished session, previous stats, and all cities for percent calculations.
  Future<UserStats> recalculateStatistics({
    required GameSession session,
    required UserStats previousStats,
    required List<City> allCities,
  });
}
