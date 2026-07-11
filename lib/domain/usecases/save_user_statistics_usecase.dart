/// Use case for saving user statistics.
abstract class SaveUserStatisticsUseCase {
  /// Persists the given user statistics.
  Future<void> call({required String userId});
}
