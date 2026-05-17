import 'package:isar/isar.dart';
import '../../domain/entities/user_stats.dart';
import 'game_session_summary_model.dart';

part 'user_stats_model.g.dart';

/// Isar model for storing user statistics and progress.
@Collection()
class UserStatsModel {
  Id id = 0; // Singleton pattern: only one stats record per user

  late int highScoreUA;
  late int highScoreWorld;
  late List<int> usedCityIds;

  late Map<int, int> cityUsageCount;
  late Map<String, int> highScores;
  late Map<String, double> usedCitiesPercent;
  late String favoriteCountry;
  late int longestStreak;
  late List<GameSessionSummaryModel> sessionHistory;

  UserStatsModel();

  UserStatsModel.fromDomain(UserStats stats) {
    highScoreUA = stats.highScoreUA;
    highScoreWorld = stats.highScoreWorld;
    usedCityIds = stats.usedCityIds;
    cityUsageCount = stats.cityUsageCount;
    highScores = stats.highScores;
    usedCitiesPercent = stats.usedCitiesPercent;
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
    cityUsageCount: cityUsageCount,
    highScores: highScores,
    usedCitiesPercent: usedCitiesPercent,
    favoriteCountry: favoriteCountry,
    longestStreak: longestStreak,
    sessionHistory: sessionHistory.map((s) => s.toDomain()).toList(),
  );
}
