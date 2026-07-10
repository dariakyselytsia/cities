import 'package:isar_community/isar.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_stats.dart';
import 'user_stats_model.dart';

part 'user_model.g.dart';

/// Isar model for User/Player profile.
@Collection()
class UserModel {
  Id id = Isar.autoIncrement;
  late String userId;
  late String languagePreference;

  // Isar cannot persist Map types directly. @ignore for now (serialize in P1).
  @ignore
  Map<String, int> highScores = <String, int>{};

  // A @Collection cannot be stored inline in another @Collection. Not persisted
  // yet — model the User↔UserStats relationship via IsarLink in P1.
  @ignore
  UserStatsModel? stats;

  UserModel();

  UserModel.fromDomain(User user) {
    userId = user.id;
    languagePreference = user.languagePreference;
    highScores = user.highScores;
    stats = UserStatsModel.fromDomain(user.stats);
  }

  User toDomain() => User(
    id: userId,
    languagePreference: languagePreference,
    highScores: highScores,
    stats: stats?.toDomain() ?? _emptyStats,
  );
}

/// Fallback used when a persisted [UserModel] has no linked stats yet (P1 link).
const UserStats _emptyStats = UserStats(
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
