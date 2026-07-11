import '../entities/city.dart';

/// Abstract repository for city data operations.
abstract class CityRepository {
  /// Loads cities from a JSON asset based on the selected game mode (dataset:
  /// Ukraine-only vs World). Independent of display language.
  Future<List<City>> loadCities({required bool isUkraineMode});

  /// Checks if a city exists by its name in the active display language
  /// ([isUkrainianLanguage] → `nameUA`, else `nameEN`) and returns it if found.
  /// Language is separate from [isUkraineMode] (the dataset).
  Future<City?> getCityByName(String name, {required bool isUkrainianLanguage});

  /// The set of lower-cased first letters that at least one city starts with,
  /// in the given dataset ([isUkraineMode]) and display language
  /// ([isUkrainianLanguage] → `firstLetterUA`, else `firstLetterEN`). Drives the
  /// letter-rule backtracking (unplayable trailing letters are simply absent).
  Future<Set<String>> availableFirstLetters({
    required bool isUkraineMode,
    required bool isUkrainianLanguage,
  });
}
