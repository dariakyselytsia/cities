import 'package:isar/isar.dart';
import '../../domain/entities/user_stats.dart';

part 'user_stats_model.g.dart';

/// Isar model for storing user statistics and progress.
@Collection()
class UserStatsModel {
  Id id = 0; // Singleton pattern: only one stats record per user

  late int highScoreUA;
  late int highScoreWorld;
  late List<int> usedCityIds;

  UserStatsModel();

  UserStatsModel.fromDomain(UserStats stats) {
    highScoreUA = stats.highScoreUA;
    highScoreWorld = stats.highScoreWorld;
    usedCityIds = stats.usedCityIds;
  }

  UserStats toDomain() => UserStats(
    highScoreUA: highScoreUA,
    highScoreWorld: highScoreWorld,
    usedCityIds: usedCityIds,
  );
}
