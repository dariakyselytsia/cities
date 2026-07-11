/// Use case for setting the user's language preference.
abstract class SetLanguagePreferenceUseCase {
  /// Sets and persists the language preference.
  Future<void> call({required String userId, required String language});
}
