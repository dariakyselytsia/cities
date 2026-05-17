/// Use case for updating the user profile.
abstract class UpdateUserProfileUseCase {
  /// Updates and persists the user profile.
  Future<void> call({required String userId});
}
