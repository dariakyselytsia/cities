import '../core/result.dart';
import '../game/game_mode.dart';
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
  ///
  /// A rejected answer (wrong letter, not found, already used) is a valid game
  /// outcome and returns [Result.success]; only an infrastructure error (e.g. a
  /// failed data read) returns [Result.failure].
  Future<Result<ValidationOutcome>> call({
    required String cityName,
    required String previousCity,
    required GameMode mode,
    required List<int> usedCityIds,
    Set<int>? historicUsedCityIds,
  });
}
