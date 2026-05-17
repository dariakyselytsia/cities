import 'package:isar/isar.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Implementation of UserRepository using Isar for local storage.
class UserRepositoryImpl implements UserRepository {
  final Isar isar;
  UserRepositoryImpl(this.isar);

  IsarCollection<UserModel> get userModels => isar.collection<UserModel>();

  @override
  Future<void> saveUser(User user) async {
    final model = UserModel.fromDomain(user);
    await isar.writeTxn(() async {
      await userModels.put(model);
    });
  }

  @override
  Future<User?> getUser(String id) async {
    final allUsers = await userModels.where().findAll();
    UserModel? user;
    try {
      user = allUsers.firstWhere((u) => u.userId == id);
    } catch (_) {
      user = null;
    }
    return user?.toDomain();
  }
}
