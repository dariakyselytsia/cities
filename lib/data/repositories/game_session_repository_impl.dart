import 'package:isar/isar.dart';
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
    final model = GameSessionModel.fromDomain(session);
    await isar.writeTxn(() async {
      await sessionModels.put(model);
    });
  }

  @override
  Future<GameSession?> getSession(String id) async {
    final allSessions = await sessionModels.where().findAll();
    GameSessionModel? session;
    try {
      session = allSessions.firstWhere((s) => s.sessionId == id);
    } catch (_) {
      session = null;
    }
    return session?.toDomain();
  }

  @override
  Future<List<GameSession>> getSessionsForUser(String userId) async {
    // This assumes you add a userId field to GameSessionModel if needed
    // For now, returns all sessions (to be refined as needed)
    final sessions = await sessionModels.where().findAll();
    return sessions.map((s) => s.toDomain()).toList();
  }
}
