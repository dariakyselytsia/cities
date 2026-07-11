import 'package:flutter_test/flutter_test.dart';

import 'package:cities/data/models/user_model.dart';
import 'package:cities/data/models/user_stats_model.dart';
import 'package:cities/domain/entities/user.dart';
import 'package:cities/domain/entities/user_stats.dart';
import 'package:cities/domain/entities/game_session_summary.dart';

void main() {
  const stats = UserStats(
    highScoreUA: 120,
    highScoreWorld: 300,
    usedCityIds: [1, 2, 3],
    cityUsageCount: {1: 5, 2: 2},
    highScores: {'UA': 120, 'WORLD': 300},
    usedCitiesPercent: {'UA': 0.42, 'WORLD': 0.1},
    favoriteCountry: 'UA',
    longestStreak: 7,
    sessionHistory: [
      GameSessionSummary(
        sessionId: 's1',
        mode: 'UA',
        score: 120,
        durationSeconds: 90,
        uniqueCities: 12,
      ),
    ],
  );

  const user = User(
    id: 'user-1',
    languagePreference: 'uk',
    highScores: {'UA': 120, 'WORLD': 300},
    stats: stats,
  );

  test('UserModel round-trips maps through embedded key/value lists', () {
    final roundTripped = UserModel.fromDomain(user).toDomain();

    expect(roundTripped.id, user.id);
    expect(roundTripped.languagePreference, 'uk');
    expect(roundTripped.highScores, {'UA': 120, 'WORLD': 300});
  });

  test('UserStats maps survive the model conversion intact', () {
    final result = UserModel.fromDomain(user).toDomain().stats;

    expect(result.highScoreUA, 120);
    expect(result.highScoreWorld, 300);
    expect(result.usedCityIds, [1, 2, 3]);
    // The three previously-@ignore'd maps now persist via embedded lists.
    expect(result.cityUsageCount, {1: 5, 2: 2});
    expect(result.highScores, {'UA': 120, 'WORLD': 300});
    expect(result.usedCitiesPercent, {'UA': 0.42, 'WORLD': 0.1});
    expect(result.favoriteCountry, 'UA');
    expect(result.longestStreak, 7);
    expect(result.sessionHistory, hasLength(1));
    expect(result.sessionHistory.first.sessionId, 's1');
    expect(result.sessionHistory.first.uniqueCities, 12);
  });

  test('empty maps round-trip to empty maps (no null leakage)', () {
    const empty = User(
      id: 'user-2',
      languagePreference: 'en',
      highScores: {},
      stats: UserStats(
        highScoreUA: 0,
        highScoreWorld: 0,
        usedCityIds: [],
        cityUsageCount: {},
        highScores: {},
        usedCitiesPercent: {},
        favoriteCountry: '',
        longestStreak: 0,
        sessionHistory: [],
      ),
    );

    final result = UserModel.fromDomain(empty).toDomain();

    expect(result.highScores, isEmpty);
    expect(result.stats.cityUsageCount, isEmpty);
    expect(result.stats.usedCitiesPercent, isEmpty);
    expect(result.stats.sessionHistory, isEmpty);
  });

  test('UserStatsModel converts directly, independent of the link', () {
    final result = UserStatsModel.fromDomain(stats).toDomain();

    expect(result.cityUsageCount, {1: 5, 2: 2});
    expect(result.usedCitiesPercent, {'UA': 0.42, 'WORLD': 0.1});
  });
}
