import '../core/result.dart';

/// Use case for ending a game session.
abstract class EndGameSessionUseCase {
  /// Ends the session and returns the final score and stats.
  Future<Result<void>> call({required String sessionId});
}
