import '../core/result.dart';
import '../entities/game_session.dart';
import '../game/app_language.dart';
import '../game/game_mode.dart';

/// Use case for starting a new game session.
abstract class StartGameSessionUseCase {
  /// Starts a new game session for the given user, [mode] (which city dataset)
  /// and [language] (display/matching language — independent of the mode, so the
  /// World list can be played in Ukrainian).
  Future<Result<GameSession>> call({
    required String userId,
    required GameMode mode,
    required AppLanguage language,
  });
}
