import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../entities/game_session.dart';
import '../game/app_language.dart';
import '../game/game_mode.dart';
import '../repositories/city_repository.dart';
import '../repositories/game_session_repository.dart';
import 'start_game_session_usecase.dart';

/// Default answer time budget for a fresh session, in seconds.
const int kDefaultTimerSeconds = 30;

/// Creates a new [GameSession], warms the local city cache for the chosen mode,
/// and persists the session so later use cases can look it up by id.
@LazySingleton(as: StartGameSessionUseCase)
class StartGameSessionUseCaseImpl implements StartGameSessionUseCase {
  final CityRepository cityRepository;
  final GameSessionRepository gameSessionRepository;

  StartGameSessionUseCaseImpl(this.cityRepository, this.gameSessionRepository);

  @override
  Future<Result<GameSession>> call({
    required String userId,
    required GameMode mode,
  }) async {
    // Warm the local Isar cache so gameplay lookups are hot.
    try {
      await cityRepository.loadCities(isUkraineMode: mode.isUkraine);
    } catch (_) {
      return const Result.failure(AssetFailure());
    }

    final session = GameSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mode: mode,
      language: mode.isUkraine ? AppLanguage.ua : AppLanguage.en,
      usedCityIds: const [],
      timerSeconds: kDefaultTimerSeconds,
      isActive: true,
    );
    try {
      await gameSessionRepository.saveSession(session);
    } catch (_) {
      return const Result.failure(DataFailure());
    }
    return Result.success(session);
  }
}
