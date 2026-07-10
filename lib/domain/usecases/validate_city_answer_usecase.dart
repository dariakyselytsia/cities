import '../game/validation_outcome.dart';

/// Use case for validating a city answer during a game session.
abstract class ValidateCityAnswerUseCase {
  /// Validates [cityName] against the letter rule, per-session uniqueness, and
  /// existence for [mode], returning a [ValidationOutcome] with the verdict,
  /// matched city, and points earned.
  ///
  /// - [previousCity] is the last accepted city name (empty on the opening move).
  /// - [usedCityIds] are the city ids already named this session (uniqueness).
  /// - [historicUsedCityIds], when non-null, enables the absolute-new-city bonus
  ///   (a city absent from it is "new to the player"). Pass `null` when lifetime
  ///   history is not yet available — base points only.
  Future<ValidationOutcome> call({
    required String cityName,
    required String previousCity,
    required String mode,
    required List<int> usedCityIds,
    Set<int>? historicUsedCityIds,
  });
}
