import 'package:go_router/go_router.dart';

import '../engine/city_list.dart';
import '../engine/difficulty.dart';
import '../features/game/game_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';

/// The app's route paths (game_design §3).
abstract final class Routes {
  static const home = '/';
  static const game = '/game';
  static const settings = '/settings';
  static const stats = '/stats';

  /// The game route for a setup, e.g. `/game?list=ukraine&difficulty=medium`.
  /// Enums become strings only here, at the URL boundary.
  static String gameFor(CityListKind list, Difficulty difficulty) => Uri(
    path: game,
    queryParameters: {'list': list.name, 'difficulty': difficulty.name},
  ).toString();
}

/// Builds the app's router. A new one per app (and per test), so navigation
/// state never leaks between them.
///
/// Every screen is `push`ed on top of Home, so Back and the game's Home
/// button return to it. A game link with a missing or unknown setup goes
/// Home instead of crashing.
GoRouter createRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: Routes.game,
      redirect: (context, state) =>
          _gameSetup(state.uri.queryParameters) == null ? Routes.home : null,
      builder: (context, state) {
        final (list, difficulty) =
            _gameSetup(state.uri.queryParameters) ??
            (CityListKind.ukraine, Difficulty.medium);
        return GameScreen(list: list, difficulty: difficulty);
      },
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: Routes.stats,
      builder: (context, state) => const StatsScreen(),
    ),
  ],
);

(CityListKind, Difficulty)? _gameSetup(Map<String, String> query) {
  final list = CityListKind.values.asNameMap()[query['list']];
  final difficulty = Difficulty.values.asNameMap()[query['difficulty']];
  if (list == null || difficulty == null) return null;
  return (list, difficulty);
}
