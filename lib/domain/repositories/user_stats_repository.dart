import '../entities/user_stats.dart';

/// Abstract repository for user statistics and progress persistence.
///
/// Reading/writing only — folding a finished session into the stats is domain
/// logic that lives in `RecordSessionResultUseCase`, not here.
abstract class UserStatsRepository {
  /// Persists the user's statistics (all fields).
  Future<void> saveUserStats(UserStats stats);

  /// Retrieves the user's statistics, or default/empty stats when none saved.
  Future<UserStats> getUserStats();
}
