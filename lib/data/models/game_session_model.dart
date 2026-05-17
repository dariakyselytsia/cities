import 'package:isar/isar.dart';
import '../../domain/entities/game_session.dart';

part 'game_session_model.g.dart';

/// Isar model for GameSession.
@Collection()
class GameSessionModel {
  Id id = Isar.autoIncrement;
  late String sessionId;
  late String mode;
  late String language;
  late List<int> usedCityIds;
  late int timerSeconds;
  late bool isActive;

  GameSessionModel();

  GameSessionModel.fromDomain(GameSession session) {
    sessionId = session.id;
    mode = session.mode;
    language = session.language;
    usedCityIds = session.usedCityIds;
    timerSeconds = session.timerSeconds;
    isActive = session.isActive;
  }

  GameSession toDomain() => GameSession(
        id: sessionId,
        mode: mode,
        language: language,
        usedCityIds: usedCityIds,
        timerSeconds: timerSeconds,
        isActive: isActive,
      );
}
