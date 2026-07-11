import '../core/result.dart';
import '../game/app_language.dart';
import '../game/bot_move.dart';
import '../game/game_mode.dart';

/// Use case for CityBot's turn (game_design.md §2 — Player vs. CityBot).
///
/// Picks a valid, not-yet-used city that answers [previousCity] (the player's
/// last city; any unused city on the opening move), drawing from the same active
/// list ([mode]) as the player, named in [language], and obeying the same letter
/// + uniqueness rules. Returns a [BotMove], or `null` when no valid city exists
/// (an exhausted pool / dead end).
abstract class GetBotCityUseCase {
  Future<Result<BotMove?>> call({
    required GameMode mode,
    required AppLanguage language,
    required List<int> usedCityIds,
    required String previousCity,
  });
}
