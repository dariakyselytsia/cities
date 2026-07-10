import 'package:injectable/injectable.dart';

import '../entities/game_session.dart';
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
  Future<GameSession> call({
    required String userId,
    required String mode,
  }) async {
    final isUkraine = mode.toUpperCase() == 'UA';
    // Warm the local Isar cache so gameplay lookups are hot.
    await cityRepository.loadCities(isUkraineMode: isUkraine);

    final session = GameSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mode: mode,
      language: isUkraine ? 'uk' : 'en',
      usedCityIds: const [],
      timerSeconds: kDefaultTimerSeconds,
      isActive: true,
    );
    await gameSessionRepository.saveSession(session);
    return session;
  }
}
