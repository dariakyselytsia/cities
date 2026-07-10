import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/user_stats_model.dart';

import '../../domain/entities/user_stats.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/user_stats_repository.dart';

/// Implementation of UserStatsRepository using Isar for local storage.
@LazySingleton(as: UserStatsRepository)
class UserStatsRepositoryImpl implements UserStatsRepository {
  final Isar isar;
  UserStatsRepositoryImpl(this.isar);

  IsarCollection<UserStatsModel> get userStatsModels =>
      isar.collection<UserStatsModel>();

  @override
  Future<void> saveUserStats(UserStats stats) async {
    final model = UserStatsModel.fromDomain(stats);
    await isar.writeTxn(() async {
      await userStatsModels.put(model);
    });
  }

  @override
  Future<UserStats> getUserStats() async {
    final stats = await userStatsModels.get(0);
    if (stats != null) {
      return stats.toDomain();
    }
    // Return default if not found
    return const UserStats(
      highScoreUA: 0,
      highScoreWorld: 0,
      usedCityIds: [],
      cityUsageCount: {},
      highScores: {},
      usedCitiesPercent: {},
      favoriteCountry: '',
      longestStreak: 0,
      sessionHistory: [],
    );
  }

  @override
  Future<UserStats> recalculateStatistics({
    required GameSession session,
    required UserStats previousStats,
    required List<City> allCities,
  }) async {
    // TODO: Implement statistics recalculation logic
    return previousStats;
  }
}
