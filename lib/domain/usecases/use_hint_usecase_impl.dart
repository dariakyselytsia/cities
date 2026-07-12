import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../game/app_language.dart';
import '../game/game_mode.dart';
import '../game/letter_rule.dart';
import '../repositories/city_repository.dart';
import 'use_hint_usecase.dart';

/// Suggests a not-yet-used city that satisfies the letter rule.
///
/// On the opening move (empty [previousCity]) any unused city is offered;
/// otherwise the suggestion must start with the required next letter (using the
/// same dataset-driven backtracking as validation via [LetterRule]).
///
/// NOTE: the free-hint / rewarded-ad quota from `game_design.md` is not enforced
/// here yet — that belongs with the (unwired) ads integration.
@LazySingleton(as: UseHintUseCase)
class UseHintUseCaseImpl implements UseHintUseCase {
  final CityRepository cityRepository;

  UseHintUseCaseImpl(this.cityRepository);

  @override
  Future<Result<String?>> call({
    required GameMode mode,
    required AppLanguage language,
    required List<int> usedCityIds,
    required String previousCity,
  }) async {
    // Dataset by [mode]; names/first letters by [language].
    final isUA = language.isUkrainian;
    try {
      final cities = await cityRepository.loadCities(
        isUkraineMode: mode.isUkraine,
      );
      final used = usedCityIds.toSet();

      String? requiredLetter;
      if (previousCity.trim().isNotEmpty) {
        final available = await cityRepository.availableFirstLetters(
          isUkraineMode: mode.isUkraine,
          isUkrainianLanguage: isUA,
        );
        requiredLetter = LetterRule.requiredNextLetter(previousCity, available);
        // Previous city is a dead end — no valid hint exists.
        if (requiredLetter == null) return const Result.success(null);
      }

      for (final city in cities) {
        if (used.contains(city.id)) continue;
        final firstLetter =
            (isUA ? city.firstLetterUA : city.firstLetterEN).toLowerCase();
        if (requiredLetter == null || firstLetter == requiredLetter) {
          return Result.success(isUA ? city.nameUA : city.nameEN);
        }
      }
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(AssetFailure());
    }
  }
}
