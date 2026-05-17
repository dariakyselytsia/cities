import 'package:isar/isar.dart';
import '../../domain/entities/user.dart';
import 'user_stats_model.dart';

part 'user_model.g.dart';

/// Isar model for User/Player profile.
@Collection()
class UserModel {
  Id id = Isar.autoIncrement;
  late String userId;
  late String languagePreference;
  late Map<String, int> highScores;
  late UserStatsModel stats;

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
        stats: stats.toDomain(),
      );
}
