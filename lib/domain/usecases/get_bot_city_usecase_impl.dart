import 'dart:math';

import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../entities/city.dart';
import '../game/app_language.dart';
import '../game/bot_move.dart';
import '../game/game_mode.dart';
import '../game/letter_rule.dart';
import '../repositories/city_repository.dart';
import 'get_bot_city_usecase.dart';

/// Picks CityBot's next city: a *random* not-yet-used city whose first letter
/// satisfies the letter rule for [previousCity] (any unused city on the opening
/// move). Uses the same dataset-driven backtracking ([LetterRule]) as answer
/// validation, so the bot and player play by identical rules — [mode] chooses
/// the dataset, [language] the names/first letters.
///
/// Randomizing the choice keeps games varied (a different opening each time).
/// The [Random] is injectable so tests can seed it deterministically. Returns
/// `null` when the pool is exhausted or the previous city is a dead end; the
/// BLoC treats that as the round ending.
@LazySingleton(as: GetBotCityUseCase)
class GetBotCityUseCaseImpl implements GetBotCityUseCase {
  final CityRepository cityRepository;
  final Random _random;

  GetBotCityUseCaseImpl(this.cityRepository, [Random? random])
    : _random = random ?? Random();

  @override
  Future<Result<BotMove?>> call({
    required GameMode mode,
    required AppLanguage language,
    required List<int> usedCityIds,
    required String previousCity,
  }) async {
    final isUA = language.isUkrainian;
    try {
      final cities = await cityRepository.loadCities(
        isUkraineMode: mode.isUkraine,
      );
      final used = usedCityIds.toSet();
      final available = await cityRepository.availableFirstLetters(
        isUkraineMode: mode.isUkraine,
        isUkrainianLanguage: isUA,
      );

      String? requiredLetter;
      if (previousCity.trim().isNotEmpty) {
        requiredLetter = LetterRule.requiredNextLetter(previousCity, available);
        // Previous city is a dead end — the bot has nothing to play.
        if (requiredLetter == null) return const Result.success(null);
      }

      final matches = <City>[
        for (final city in cities)
          if (!used.contains(city.id) &&
              (requiredLetter == null ||
                  (isUA ? city.firstLetterUA : city.firstLetterEN)
                          .toLowerCase() ==
                      requiredLetter))
            city,
      ];
      // No valid unused city for the required letter.
      if (matches.isEmpty) return const Result.success(null);

      final city = matches[_random.nextInt(matches.length)];
      final name = isUA ? city.nameUA : city.nameEN;
      final nextLetter =
          LetterRule.requiredNextLetter(name, available)?.toUpperCase();
      return Result.success(BotMove(city: city, nextLetter: nextLetter));
    } catch (_) {
      return const Result.failure(AssetFailure());
    }
  }
}
