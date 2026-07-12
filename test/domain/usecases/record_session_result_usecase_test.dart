import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/record_session_result_usecase_impl.dart';

class MockUserStatsRepository extends Mock implements UserStatsRepository {}

const _emptyStats = UserStats(
  highScoreUA: 0,
  highScoreWorld: 0,
  usedCityIds: [],
  cityUsageCount: {},
  highScores: {},
  usedCitiesPercent: {},
  favoriteCountry: '',
  longestStreak: 0,
  sessionHistory: [],
);

void main() {
  group('RecordSessionResultUseCaseImpl', () {
    late MockUserStatsRepository repository;
    late RecordSessionResultUseCaseImpl useCase;

    setUpAll(() => registerFallbackValue(_emptyStats));

    setUp(() {
      repository = MockUserStatsRepository();
      useCase = RecordSessionResultUseCaseImpl(repository);
      when(() => repository.saveUserStats(any())).thenAnswer((_) async {});
    });

    /// Captures the single [UserStats] passed to saveUserStats.
    UserStats savedStats() =>
        verify(() => repository.saveUserStats(captureAny())).captured.single
            as UserStats;

    test('folds a first Ukraine session into empty stats', () async {
      when(() => repository.getUserStats()).thenAnswer((_) async => _emptyStats);

      final result = await useCase(
        sessionId: 's1',
        mode: GameMode.ukraine,
        score: 30,
        playerCityIds: [2, 4],
        durationSeconds: 42,
      );

      final saved = savedStats();
      expect(saved.highScoreUA, 30);
      expect(saved.highScoreWorld, 0);
      expect(saved.usedCityIds, [2, 4]);
      expect(saved.cityUsageCount, {2: 1, 4: 1});
      expect(saved.highScores, {'UA': 30});
      expect(saved.longestStreak, 2);
      expect(saved.sessionHistory, hasLength(1));
      expect(saved.sessionHistory.first.mode, 'UA');
      expect(saved.sessionHistory.first.uniqueCities, 2);
      // The use case returns the same updated stats it persisted.
      expect(result, isA<Success<UserStats>>());
      expect((result as Success<UserStats>).value.highScoreUA, 30);
    });

    test('keeps the previous high score and longest streak when not beaten',
        () async {
      const previous = UserStats(
        highScoreUA: 50,
        highScoreWorld: 0,
        usedCityIds: [2],
        cityUsageCount: {2: 1},
        highScores: {'UA': 50},
        usedCitiesPercent: {},
        favoriteCountry: '',
        longestStreak: 5,
        sessionHistory: [],
      );
      when(() => repository.getUserStats()).thenAnswer((_) async => previous);

      await useCase(
        sessionId: 's2',
        mode: GameMode.ukraine,
        score: 30, // below the 50 best
        playerCityIds: [2, 7], // 2 already known; streak of 2 < best 5
        durationSeconds: 10,
      );

      final saved = savedStats();
      expect(saved.highScoreUA, 50, reason: 'best score is preserved');
      expect(saved.longestStreak, 5, reason: 'longest streak is preserved');
      // Used-set merges without duplicating the already-known city.
      expect(saved.usedCityIds, unorderedEquals([2, 7]));
      expect(saved.cityUsageCount, {2: 2, 7: 1});
    });

    test('World session updates the World high score, not Ukraine', () async {
      when(() => repository.getUserStats()).thenAnswer((_) async => _emptyStats);

      await useCase(
        sessionId: 's3',
        mode: GameMode.world,
        score: 80,
        playerCityIds: [9],
        durationSeconds: 20,
      );

      final saved = savedStats();
      expect(saved.highScoreWorld, 80);
      expect(saved.highScoreUA, 0);
      expect(saved.highScores, {'WORLD': 80});
    });

    test('returns DataFailure when persistence throws', () async {
      when(() => repository.getUserStats()).thenThrow(Exception('db down'));

      final result = await useCase(
        sessionId: 's4',
        mode: GameMode.ukraine,
        score: 10,
        playerCityIds: [1],
        durationSeconds: 5,
      );

      expect(result, isA<ResultFailure<UserStats>>());
      expect((result as ResultFailure<UserStats>).failure, isA<DataFailure>());
    });
  });
}
