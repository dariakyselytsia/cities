import 'package:injectable/injectable.dart';

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
  Future<ValidationOutcome> call({
    required String cityName,
    required String previousCity,
    required String mode,
    required List<int> usedCityIds,
    Set<int>? historicUsedCityIds,
  }) async {
    final isUA = mode.toUpperCase() == 'UA';
    final answer = cityName.trim();
    if (answer.isEmpty) {
      return const ValidationOutcome.rejected(AnswerStatus.notFound);
    }

    final city = await cityRepository.getCityByName(answer, isUA: isUA);
    if (city == null) {
      return const ValidationOutcome.rejected(AnswerStatus.notFound);
    }

    if (usedCityIds.contains(city.id)) {
      return ValidationOutcome.rejected(AnswerStatus.alreadyUsed, city: city);
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
        return ValidationOutcome.rejected(AnswerStatus.wrongLetter, city: city);
      }
    }

    final isNew =
        historicUsedCityIds != null && !historicUsedCityIds.contains(city.id);
    final points = kBasePoints + (isNew ? kNewCityBonus : 0);
    return ValidationOutcome.accepted(
      city: city,
      points: points,
      isNewToPlayer: isNew,
    );
  }
}
