/// Abstract repository for city and user stats data operations.
import '../entities/city.dart';
import '../entities/user_stats.dart';

abstract class CityRepository {
  /// Loads cities from a JSON asset based on the selected game mode.
  Future<List<City>> loadCities({required bool isUkraineMode});

  /// Checks if a city exists by name (UA or EN) and returns its details if found.
  Future<City?> getCityByName(String name, {required bool isUA});

  /// Saves the user's high scores and used city IDs.
  Future<void> saveUserStats(UserStats stats);

  /// Retrieves the user's high scores and used city IDs.
  Future<UserStats> getUserStats();
}
