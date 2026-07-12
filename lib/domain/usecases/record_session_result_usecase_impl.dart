import 'dart:math' as math;

import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../entities/game_session_summary.dart';
import '../entities/user_stats.dart';
import '../game/game_mode.dart';
import '../repositories/user_stats_repository.dart';
import 'record_session_result_usecase.dart';

/// Most recent sessions retained in [UserStats.sessionHistory] (older ones are
/// dropped so the row does not grow unbounded).
const int kMaxSessionHistory = 20;

/// Loads the previous [UserStats], folds this session into them with [_merge],
/// and persists the result — all inside a `try` that maps any error to a
/// [DataFailure]. The fold itself is a pure function so it is unit-testable
/// without a database.
@LazySingleton(as: RecordSessionResultUseCase)
class RecordSessionResultUseCaseImpl implements RecordSessionResultUseCase {
  final UserStatsRepository userStatsRepository;

  RecordSessionResultUseCaseImpl(this.userStatsRepository);

  @override
  Future<Result<UserStats>> call({
    required String sessionId,
    required GameMode mode,
    required int score,
    required List<int> playerCityIds,
    required int durationSeconds,
  }) async {
    try {
      final previous = await userStatsRepository.getUserStats();
      final updated = _merge(
        previous: previous,
        sessionId: sessionId,
        mode: mode,
        score: score,
        playerCityIds: playerCityIds,
        durationSeconds: durationSeconds,
      );
      await userStatsRepository.saveUserStats(updated);
      return Result.success(updated);
    } catch (_) {
      return const Result.failure(DataFailure());
    }
  }

  /// Pure fold of one finished session into [previous]:
  /// - player cities extend the lifetime used-set and per-city usage counts;
  /// - the per-mode high score and the matching legacy `highScoreUA/World` keep
  ///   the running maximum;
  /// - the longest streak is the max chained-city count of any session;
  /// - a capped session summary is appended.
  UserStats _merge({
    required UserStats previous,
    required String sessionId,
    required GameMode mode,
    required int score,
    required List<int> playerCityIds,
    required int durationSeconds,
  }) {
    final usedCityIds = <int>{...previous.usedCityIds, ...playerCityIds}.toList();

    final cityUsageCount = Map<int, int>.from(previous.cityUsageCount);
    for (final id in playerCityIds) {
      cityUsageCount[id] = (cityUsageCount[id] ?? 0) + 1;
    }

    final isUA = mode.isUkraine;
    final highScoreUA =
        isUA ? math.max(previous.highScoreUA, score) : previous.highScoreUA;
    final highScoreWorld =
        isUA ? previous.highScoreWorld : math.max(previous.highScoreWorld, score);

    final highScores = Map<String, int>.from(previous.highScores);
    highScores[mode.storageValue] =
        math.max(previous.highScores[mode.storageValue] ?? 0, score);

    final longestStreak = math.max(previous.longestStreak, playerCityIds.length);

    final summary = GameSessionSummary(
      sessionId: sessionId,
      mode: mode.storageValue,
      score: score,
      durationSeconds: durationSeconds,
      uniqueCities: playerCityIds.toSet().length,
    );
    final history = [...previous.sessionHistory, summary];
    final trimmedHistory = history.length > kMaxSessionHistory
        ? history.sublist(history.length - kMaxSessionHistory)
        : history;

    return UserStats(
      highScoreUA: highScoreUA,
      highScoreWorld: highScoreWorld,
      usedCityIds: usedCityIds,
      cityUsageCount: cityUsageCount,
      highScores: highScores,
      usedCitiesPercent: previous.usedCitiesPercent,
      favoriteCountry: previous.favoriteCountry,
      longestStreak: longestStreak,
      sessionHistory: trimmedHistory,
    );
  }
}
