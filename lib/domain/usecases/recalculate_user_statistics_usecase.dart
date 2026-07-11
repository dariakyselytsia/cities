/// Use case for recalculating user statistics at the end of a session.
abstract class RecalculateUserStatisticsUseCase {
  /// Recalculates and persists user statistics.
  Future<void> call({required String userId, required String sessionId});
}
