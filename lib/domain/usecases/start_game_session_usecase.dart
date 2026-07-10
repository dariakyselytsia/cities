import '../entities/game_session.dart';
import '../game/game_mode.dart';

/// Use case for starting a new game session.
abstract class StartGameSessionUseCase {
  /// Starts a new game session for the given user and mode.
  Future<GameSession> call({required String userId, required GameMode mode});
}
