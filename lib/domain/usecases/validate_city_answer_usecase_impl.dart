import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../game/game_mode.dart';
import '../game/letter_rule.dart';
import '../game/validation_outcome.dart';
import '../repositories/city_repository.dart';
import 'validate_city_answer_usecase.dart';

/// Validates a submitted city against the full game rules:
/// existence for the mode, per-session uniqueness, and the last-valid-letter
/// rule (with dataset-driven ь/и backtracking via [LetterRule]). Awards base
/// points, plus the absolute-new-city bonus when lifetime history is supplied.
@LazySingleton(as: ValidateCityAnswerUseCase)
class ValidateCityAnswerUseCaseImpl implements ValidateCityAnswerUseCase {
  final CityRepository cityRepository;

  ValidateCityAnswerUseCaseImpl(this.cityRepository);

  @override
  Future<Result<ValidationOutcome>> call({
    required String cityName,
    required String previousCity,
    required GameMode mode,
    required List<int> usedCityIds,
    Set<int>? historicUsedCityIds,
  }) async {
    final isUA = mode.isUkraine;
    final answer = cityName.trim();
    if (answer.isEmpty) {
      return const Result.success(
        ValidationOutcome.rejected(AnswerStatus.notFound),
      );
    }

    try {
      final city = await cityRepository.getCityByName(answer, isUA: isUA);
      if (city == null) {
        return const Result.success(
          ValidationOutcome.rejected(AnswerStatus.notFound),
        );
      }

      if (usedCityIds.contains(city.id)) {
        return Result.success(
          ValidationOutcome.rejected(AnswerStatus.alreadyUsed, city: city),
        );
      }

      if (previousCity.trim().isNotEmpty) {
        final available =
            await cityRepository.availableFirstLetters(isUkraineMode: isUA);
        final firstLetter = isUA ? city.firstLetterUA : city.firstLetterEN;
        final valid = LetterRule.isValidNext(
          previousCity: previousCity,
          candidateFirstLetter: firstLetter,
          availableFirstLetters: available,
        );
        if (!valid) {
          return Result.success(
            ValidationOutcome.rejected(AnswerStatus.wrongLetter, city: city),
          );
        }
      }

      final isNew =
          historicUsedCityIds != null && !historicUsedCityIds.contains(city.id);
      final points = kBasePoints + (isNew ? kNewCityBonus : 0);
      return Result.success(
        ValidationOutcome.accepted(
          city: city,
          points: points,
          isNewToPlayer: isNew,
        ),
      );
    } catch (_) {
      return const Result.failure(DataFailure());
    }
  }
}
