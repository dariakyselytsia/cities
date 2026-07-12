import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/di.dart';
import '../domain/domain.dart';
import '../presentation/bloc/game_session_bloc.dart';
import '../presentation/pages/game_session_screen.dart';
import '../presentation/pages/home_screen.dart';
import '../presentation/pages/settings_screen.dart';
import '../presentation/pages/leaderboard_screen.dart';
import '../presentation/pages/statistics_screen.dart';

/// Named route paths for the app's four screens (see game_design.md §3).
abstract final class Routes {
  static const home = '/';
  static const settings = '/settings';
  static const game = '/game';
  static const leaderboard = '/leaderboard';
  static const statistics = '/statistics';
}

/// Builds a fresh [GameSessionBloc] from DI-resolved use cases. A new instance
/// per game route means a clean session (and its timer) each time.
GameSessionBloc _buildGameSessionBloc() => GameSessionBloc(
  startGameSessionUseCase: getIt<StartGameSessionUseCase>(),
  validateCityAnswerUseCase: getIt<ValidateCityAnswerUseCase>(),
  getBotCityUseCase: getIt<GetBotCityUseCase>(),
  useHintUseCase: getIt<UseHintUseCase>(),
  reviveSessionUseCase: getIt<ReviveSessionUseCase>(),
  endGameSessionUseCase: getIt<EndGameSessionUseCase>(),
  getUserStatsUseCase: getIt<GetUserStatsUseCase>(),
  recordSessionResultUseCase: getIt<RecordSessionResultUseCase>(),
);

/// Central app router. The game route scopes its BLoC so it is created on
/// entry and disposed on exit.
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: Routes.leaderboard,
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: Routes.statistics,
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: Routes.game,
      builder: (context, state) => BlocProvider<GameSessionBloc>(
        create: (_) => _buildGameSessionBloc(),
        child: const GameSessionScreen(),
      ),
    ),
  ],
);
