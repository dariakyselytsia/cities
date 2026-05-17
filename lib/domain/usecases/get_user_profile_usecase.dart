/// Use case for retrieving the user profile.
abstract class GetUserProfileUseCase {
  /// Loads the user profile.
  Future<void> call({required String userId});
}
