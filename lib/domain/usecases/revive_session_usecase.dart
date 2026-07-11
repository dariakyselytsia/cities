import '../core/result.dart';
import '../entities/game_session.dart';

/// Use case for reviving a timed-out game session.
abstract class ReviveSessionUseCase {
  /// Revives the session and returns the new state.
  Future<Result<GameSession>> call({required String sessionId});
}
