import 'package:isar_community/isar.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_stats.dart';
import 'stat_entries.dart';
import 'user_stats_model.dart';

part 'user_model.g.dart';

/// Isar model for User/Player profile.
@Collection()
class UserModel {
  Id id = Isar.autoIncrement;
  @Index()
  late String userId;
  late String languagePreference;

  // Domain `Map<String,int>` persisted as an embedded key/value list.
  late List<StringIntEntry> highScores;

  // User↔UserStats relationship via IsarLink. The repository persists the
  // linked stats row and saves/loads the link (see UserRepositoryImpl).
  final IsarLink<UserStatsModel> stats = IsarLink<UserStatsModel>();

  UserModel();

  UserModel.fromDomain(User user) {
    userId = user.id;
    languagePreference = user.languagePreference;
    highScores = user.highScores.entries
        .map((e) => StringIntEntry.of(e.key, e.value))
        .toList();
    stats.value = UserStatsModel.fromDomain(user.stats);
  }

  User toDomain() => User(
    id: userId,
    languagePreference: languagePreference,
    highScores: {for (final e in highScores) e.key: e.value},
    stats: stats.value?.toDomain() ?? _emptyStats,
  );
}

/// Fallback used when a persisted [UserModel] has no linked stats yet.
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
