import 'package:injectable/injectable.dart';

import '../repositories/city_repository.dart';
import 'validate_city_answer_usecase.dart';

/// Validates a submitted city against the letter rule.
///
/// A move is valid when the city exists for the active mode and — unless it is
/// the opening move — its first letter matches the last letter of the previous
/// city.
///
/// NOTE: this is the P0 baseline. The full ь/и (soft-sign) backtracking and
/// per-session uniqueness/scoring described in `game_design.md` are the P1
/// "core game algorithm" and are not implemented here yet.
@LazySingleton(as: ValidateCityAnswerUseCase)
class ValidateCityAnswerUseCaseImpl implements ValidateCityAnswerUseCase {
  final CityRepository cityRepository;

  ValidateCityAnswerUseCaseImpl(this.cityRepository);

  @override
  Future<bool> call({
    required String cityName,
    required String previousCity,
    required String mode,
  }) async {
    final isUA = mode.toUpperCase() == 'UA';
    final answer = cityName.trim();
    if (answer.isEmpty) return false;

    final city = await cityRepository.getCityByName(answer, isUA: isUA);
    if (city == null) return false;

    final previous = previousCity.trim();
    if (previous.isEmpty) return true; // opening move — any real city is valid

    final requiredLetter = previous.substring(previous.length - 1).toLowerCase();
    final actualFirst = (isUA ? city.firstLetterUA : city.firstLetterEN);
    return actualFirst.toLowerCase() == requiredLetter;
  }
}
