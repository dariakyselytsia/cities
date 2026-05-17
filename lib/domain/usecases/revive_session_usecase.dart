/// Use case for reviving a timed-out game session.
abstract class ReviveSessionUseCase {
  /// Revives the session and returns the new state.
  Future<void> call({required String sessionId});
}
