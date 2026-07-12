import 'package:isar_community/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/user_stats_model.dart';

import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/user_stats_repository.dart';

/// Implementation of UserStatsRepository using Isar for local storage. The
/// single lifetime-stats row is stored under the fixed Isar id `0`.
@LazySingleton(as: UserStatsRepository)
class UserStatsRepositoryImpl implements UserStatsRepository {
  /// The fixed Isar id of the singleton stats row (there is one player).
  static const int _statsId = 0;

  final Isar isar;
  UserStatsRepositoryImpl(this.isar);

  IsarCollection<UserStatsModel> get userStatsModels =>
      isar.collection<UserStatsModel>();

  @override
  Future<void> saveUserStats(UserStats stats) async {
    final model = UserStatsModel.fromDomain(stats)..id = _statsId;
    await isar.writeTxn(() async {
      await userStatsModels.put(model);
    });
  }

  @override
  Future<UserStats> getUserStats() async {
    final stats = await userStatsModels.get(_statsId);
    if (stats != null) {
      return stats.toDomain();
    }
    // No stats saved yet — return an empty baseline.
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
}
