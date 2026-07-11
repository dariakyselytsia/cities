import '../entities/user.dart';

/// Abstract repository for user profile persistence.
abstract class UserRepository {
  /// Saves the user profile.
  Future<void> saveUser(User user);

  /// Loads the user profile by ID.
  Future<User?> getUser(String id);
}
