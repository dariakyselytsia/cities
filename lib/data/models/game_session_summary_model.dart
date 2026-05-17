import 'package:isar/isar.dart';
import '../../domain/entities/game_session_summary.dart';

part 'game_session_summary_model.g.dart';

/// Isar model for GameSessionSummary (for session history in UserStatsModel)
@embedded
class GameSessionSummaryModel {
  late String sessionId;
  late String mode;
  late int score;
  late int durationSeconds;
  late int uniqueCities;

  GameSessionSummaryModel();

  GameSessionSummaryModel.fromDomain(GameSessionSummary summary) {
    sessionId = summary.sessionId;
    mode = summary.mode;
    score = summary.score;
    durationSeconds = summary.durationSeconds;
    uniqueCities = summary.uniqueCities;
  }

  GameSessionSummary toDomain() => GameSessionSummary(
        sessionId: sessionId,
        mode: mode,
        score: score,
        durationSeconds: durationSeconds,
        uniqueCities: uniqueCities,
      );
}
