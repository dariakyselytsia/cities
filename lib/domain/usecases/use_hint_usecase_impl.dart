import 'package:injectable/injectable.dart';

import '../repositories/city_repository.dart';
import '../repositories/game_session_repository.dart';
import 'use_hint_usecase.dart';

/// Suggests a not-yet-used city for the active session.
///
/// P0 baseline: returns the first city for the session's mode that is not in
/// `usedCityIds`. It does not yet honour the required next letter (P1 core
/// algorithm) or the free-hint / rewarded-ad quota from `game_design.md`.
@LazySingleton(as: UseHintUseCase)
class UseHintUseCaseImpl implements UseHintUseCase {
  final GameSessionRepository gameSessionRepository;
  final CityRepository cityRepository;

  UseHintUseCaseImpl(this.gameSessionRepository, this.cityRepository);

  @override
  Future<String?> call({required String sessionId}) async {
    final session = await gameSessionRepository.getSession(sessionId);
    if (session == null) return null;

    final isUkraine = session.mode.toUpperCase() == 'UA';
    final cities = await cityRepository.loadCities(isUkraineMode: isUkraine);
    final used = session.usedCityIds.toSet();

    for (final city in cities) {
      if (!used.contains(city.id)) {
        return isUkraine ? city.nameUA : city.nameEN;
      }
    }
    return null;
  }
}
