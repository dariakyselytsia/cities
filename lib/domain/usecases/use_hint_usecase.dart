import '../core/result.dart';
import '../game/app_language.dart';
import '../game/game_mode.dart';

/// Use case for using a hint in a game session.
abstract class UseHintUseCase {
  /// Returns a not-yet-used city that satisfies the letter rule for
  /// [previousCity] (any unused city on the opening move), or `null` when no
  /// valid suggestion exists. [usedCityIds] are the ids already named this
  /// session; [mode] selects the dataset and [language] the display name.
  Future<Result<String?>> call({
    required GameMode mode,
    required AppLanguage language,
    required List<int> usedCityIds,
    required String previousCity,
  });
}
