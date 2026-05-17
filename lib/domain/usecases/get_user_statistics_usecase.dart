/// Use case for retrieving user statistics.
abstract class GetUserStatisticsUseCase {
  /// Loads user statistics for the given user.
  Future<void> call({required String userId});
}
