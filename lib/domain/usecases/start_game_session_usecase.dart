/// Use case for starting a new game session.
abstract class StartGameSessionUseCase {
  /// Starts a new game session for the given user and mode.
  Future<void> call({required String userId, required String mode});
}
