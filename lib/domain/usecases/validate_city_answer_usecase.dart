/// Use case for validating a city answer during a game session.
abstract class ValidateCityAnswerUseCase {
  /// Validates the user's answer and returns the result.
  Future<bool> call({required String cityName, required String previousCity, required String mode});
}
