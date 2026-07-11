import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../entities/game_session.dart';
import '../repositories/game_session_repository.dart';
import 'end_game_session_usecase.dart';

/// Marks a session inactive and persists the final state. A no-op if the
/// session cannot be found.
@LazySingleton(as: EndGameSessionUseCase)
class EndGameSessionUseCaseImpl implements EndGameSessionUseCase {
  final GameSessionRepository gameSessionRepository;

  EndGameSessionUseCaseImpl(this.gameSessionRepository);

  @override
  Future<Result<void>> call({required String sessionId}) async {
    try {
      final session = await gameSessionRepository.getSession(sessionId);
      if (session == null) return const Result.success(null);

      final ended = GameSession(
        id: session.id,
        mode: session.mode,
        language: session.language,
        usedCityIds: session.usedCityIds,
        timerSeconds: 0,
        isActive: false,
      );
      await gameSessionRepository.saveSession(ended);
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(DataFailure());
    }
  }
}
