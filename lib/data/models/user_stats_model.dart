import 'package:isar_community/isar.dart';
import '../../domain/entities/user_stats.dart';
import 'game_session_summary_model.dart';
import 'stat_entries.dart';

part 'user_stats_model.g.dart';

/// Isar model for storing user statistics and progress.
@Collection()
class UserStatsModel {
  Id id = 0; // Singleton pattern: only one stats record per user

  late int highScoreUA;
  late int highScoreWorld;
  late List<int> usedCityIds;

  // Domain `Map`s persisted as embedded key/value lists (Isar cannot store
  // maps directly). Converted back to maps in [toDomain].
  late List<IntIntEntry> cityUsageCount;
  late List<StringIntEntry> highScores;
  late List<StringDoubleEntry> usedCitiesPercent;

  late String favoriteCountry;
  late int longestStreak;
  late List<GameSessionSummaryModel> sessionHistory;

  UserStatsModel();

  UserStatsModel.fromDomain(UserStats stats) {
    highScoreUA = stats.highScoreUA;
    highScoreWorld = stats.highScoreWorld;
    usedCityIds = stats.usedCityIds;
    cityUsageCount = stats.cityUsageCount.entries
        .map((e) => IntIntEntry.of(e.key, e.value))
        .toList();
    highScores = stats.highScores.entries
        .map((e) => StringIntEntry.of(e.key, e.value))
        .toList();
    usedCitiesPercent = stats.usedCitiesPercent.entries
        .map((e) => StringDoubleEntry.of(e.key, e.value))
        .toList();
    favoriteCountry = stats.favoriteCountry;
    longestStreak = stats.longestStreak;
    sessionHistory = stats.sessionHistory
        .map((s) => GameSessionSummaryModel.fromDomain(s))
        .toList();
  }

  UserStats toDomain() => UserStats(
    highScoreUA: highScoreUA,
    highScoreWorld: highScoreWorld,
    usedCityIds: usedCityIds,
    cityUsageCount: {for (final e in cityUsageCount) e.key: e.value},
    highScores: {for (final e in highScores) e.key: e.value},
    usedCitiesPercent: {for (final e in usedCitiesPercent) e.key: e.value},
    favoriteCountry: favoriteCountry,
    longestStreak: longestStreak,
    sessionHistory: sessionHistory.map((s) => s.toDomain()).toList(),
  );
}
