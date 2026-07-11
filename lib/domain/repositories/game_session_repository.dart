import '../entities/game_session.dart';

/// Abstract repository for game session persistence.
abstract class GameSessionRepository {
  /// Saves a game session.
  Future<void> saveSession(GameSession session);

  /// Loads a game session by ID.
  Future<GameSession?> getSession(String id);

  /// Loads all sessions for a user (optional).
  Future<List<GameSession>> getSessionsForUser(String userId);
}
