/// Use case for using a hint in a game session.
abstract class UseHintUseCase {
  /// Consumes a hint and returns the suggested city.
  Future<String?> call({required String sessionId});
}
