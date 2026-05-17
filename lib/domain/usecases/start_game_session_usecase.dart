/// Use case for starting a new game session.
import '../entities/game_session.dart';

abstract class StartGameSessionUseCase {
  /// Starts a new game session for the given user and mode.
  Future<GameSession> call({required String userId, required String mode});
}
