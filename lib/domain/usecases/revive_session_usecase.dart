/// Use case for reviving a timed-out game session.
import '../entities/game_session.dart';

abstract class ReviveSessionUseCase {
  /// Revives the session and returns the new state.
  Future<GameSession> call({required String sessionId});
}
