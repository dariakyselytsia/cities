import '../core/result.dart';
import '../entities/user_stats.dart';
import '../game/game_mode.dart';

/// Use case that folds a finished session into the player's lifetime
/// [UserStats] and persists them, returning the updated stats.
///
/// - [playerCityIds] are the ids of the cities the *player* named this session
///   (not CityBot's) — they extend the lifetime used-set, bump per-city usage,
///   and their count is the session's streak.
/// - [score] competes for the per-mode high score.
///
/// Returns [Result.failure] only on a persistence error; the caller may ignore
/// it (game-over must still show) — stats are best-effort.
abstract class RecordSessionResultUseCase {
  Future<Result<UserStats>> call({
    required String sessionId,
    required GameMode mode,
    required int score,
    required List<int> playerCityIds,
    required int durationSeconds,
  });
}
