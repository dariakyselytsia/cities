import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../entities/game_session.dart';
import '../repositories/game_session_repository.dart';
import 'revive_session_usecase.dart';
import 'start_game_session_usecase_impl.dart' show kDefaultTimerSeconds;

/// Reactivates a timed-out session and resets its timer, preserving the cities
/// already used this round.
@LazySingleton(as: ReviveSessionUseCase)
class ReviveSessionUseCaseImpl implements ReviveSessionUseCase {
  final GameSessionRepository gameSessionRepository;

  ReviveSessionUseCaseImpl(this.gameSessionRepository);

  @override
  Future<Result<GameSession>> call({required String sessionId}) async {
    try {
      final session = await gameSessionRepository.getSession(sessionId);
      if (session == null) {
        return const Result.failure(SessionNotFoundFailure());
      }

      final revived = GameSession(
        id: session.id,
        mode: session.mode,
        language: session.language,
        usedCityIds: session.usedCityIds,
        timerSeconds: kDefaultTimerSeconds,
        isActive: true,
        // Preserve the accumulated score across a revive.
        score: session.score,
      );
      await gameSessionRepository.saveSession(revived);
      return Result.success(revived);
    } catch (_) {
      return const Result.failure(DataFailure());
    }
  }
}
