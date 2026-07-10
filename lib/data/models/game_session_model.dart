import 'package:isar_community/isar.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/game/app_language.dart';
import '../../domain/game/game_mode.dart';

part 'game_session_model.g.dart';

/// Isar model for GameSession.
@Collection()
class GameSessionModel {
  Id id = Isar.autoIncrement;
  @Index()
  late String sessionId;
  late String mode;
  late String language;
  late List<int> usedCityIds;
  late int timerSeconds;
  late bool isActive;
  int score = 0;

  GameSessionModel();

  GameSessionModel.fromDomain(GameSession session) {
    sessionId = session.id;
    mode = session.mode.storageValue;
    language = session.language.code;
    usedCityIds = session.usedCityIds;
    timerSeconds = session.timerSeconds;
    isActive = session.isActive;
    score = session.score;
  }

  GameSession toDomain() => GameSession(
        id: sessionId,
        mode: GameMode.fromStorage(mode),
        language: AppLanguage.fromCode(language),
        usedCityIds: usedCityIds,
        timerSeconds: timerSeconds,
        isActive: isActive,
        score: score,
      );
}
