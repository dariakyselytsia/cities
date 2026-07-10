import 'package:isar_community/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final Isar isar;
  UserRepositoryImpl(this.isar);

  IsarCollection<UserModel> get userModels => isar.collection<UserModel>();

  @override
  Future<void> saveUser(User user) async {
    await isar.writeTxn(() async {
      // Upsert by business key (userId), reusing the existing Isar id.
      final existing =
          await userModels.where().userIdEqualTo(user.id).findFirst();
      final model = UserModel.fromDomain(user);
      if (existing != null) model.id = existing.id;
      await userModels.put(model);
    });
  }

  @override
  Future<User?> getUser(String id) async {
    // Indexed lookup on UserModel.userId (see @Index).
    final model = await userModels.where().userIdEqualTo(id).findFirst();
    return model?.toDomain();
  }
}
