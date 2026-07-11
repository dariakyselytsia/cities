import 'package:isar_community/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
import '../models/user_stats_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final Isar isar;
  UserRepositoryImpl(this.isar);

  IsarCollection<UserModel> get userModels => isar.collection<UserModel>();
  IsarCollection<UserStatsModel> get statsModels =>
      isar.collection<UserStatsModel>();

  @override
  Future<void> saveUser(User user) async {
    await isar.writeTxn(() async {
      // Upsert by business key (userId), reusing the existing Isar id.
      final existing =
          await userModels.where().userIdEqualTo(user.id).findFirst();
      final model = UserModel.fromDomain(user);
      if (existing != null) model.id = existing.id;

      // Persist the linked stats row first, then the user, then the link
      // itself — an IsarLink is only saved once both endpoints have ids.
      final stats = model.stats.value;
      if (stats != null) {
        await statsModels.put(stats);
      }
      await userModels.put(model);
      await model.stats.save();
    });
  }

  @override
  Future<User?> getUser(String id) async {
    // Indexed lookup on UserModel.userId (see @Index).
    final model = await userModels.where().userIdEqualTo(id).findFirst();
    if (model == null) return null;
    // Links are lazy — load the stats before mapping to the domain entity.
    await model.stats.load();
    return model.toDomain();
  }
}
