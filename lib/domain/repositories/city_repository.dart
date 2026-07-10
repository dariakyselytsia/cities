/// Abstract repository for city data operations.
import '../entities/city.dart';

abstract class CityRepository {
  /// Loads cities from a JSON asset based on the selected game mode.
  Future<List<City>> loadCities({required bool isUkraineMode});

  /// Checks if a city exists by name (UA or EN) and returns its details if found.
  Future<City?> getCityByName(String name, {required bool isUA});

  /// The set of lower-cased first letters that at least one city starts with in
  /// the given mode. Drives the letter-rule backtracking (unplayable trailing
  /// letters are simply absent from this set).
  Future<Set<String>> availableFirstLetters({required bool isUkraineMode});
}
