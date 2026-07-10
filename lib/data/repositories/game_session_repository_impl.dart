import 'package:isar_community/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/game_session_model.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/game_session_repository.dart';

@LazySingleton(as: GameSessionRepository)
class GameSessionRepositoryImpl implements GameSessionRepository {
  final Isar isar;
  GameSessionRepositoryImpl(this.isar);

  IsarCollection<GameSessionModel> get sessionModels =>
      isar.collection<GameSessionModel>();

  @override
  Future<void> saveSession(GameSession session) async {
    await isar.writeTxn(() async {
      // Upsert by business key: reuse the Isar id of an existing record with the
      // same sessionId so repeated saves update in place instead of duplicating.
      final existing =
          await sessionModels.where().sessionIdEqualTo(session.id).findFirst();
      final model = GameSessionModel.fromDomain(session);
      if (existing != null) model.id = existing.id;
      await sessionModels.put(model);
    });
  }

  @override
  Future<GameSession?> getSession(String id) async {
    // Indexed lookup on GameSessionModel.sessionId (see @Index).
    final model = await sessionModels.where().sessionIdEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<List<GameSession>> getSessionsForUser(String userId) async {
    // NOTE: GameSessionModel has no userId yet, so this still returns all
    // sessions. Add an indexed userId field to filter (P1 stats work).
    final sessions = await sessionModels.where().findAll();
    return sessions.map((s) => s.toDomain()).toList();
  }
}
