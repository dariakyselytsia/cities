import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/revive_session_usecase_impl.dart';
import 'package:cities/domain/usecases/start_game_session_usecase_impl.dart'
    show kDefaultTimerSeconds;

class MockGameSessionRepository extends Mock
    implements GameSessionRepository {}

void main() {
  late MockGameSessionRepository sessionRepository;
  late ReviveSessionUseCaseImpl useCase;

  const existing = GameSession(
    id: 's1',
    mode: GameMode.ukraine,
    language: AppLanguage.ua,
    usedCityIds: [1, 2],
    timerSeconds: 0,
    isActive: false,
    score: 30,
  );

  setUpAll(() {
    registerFallbackValue(existing);
  });

  setUp(() {
    sessionRepository = MockGameSessionRepository();
    useCase = ReviveSessionUseCaseImpl(sessionRepository);
    when(() => sessionRepository.saveSession(any()))
        .thenAnswer((_) async {});
  });

  test('revives an existing session, resetting the timer and staying active',
      () async {
    when(() => sessionRepository.getSession('s1'))
        .thenAnswer((_) async => existing);

    final result = await useCase(sessionId: 's1');

    expect(result, isA<Success<GameSession>>());
    final revived = (result as Success<GameSession>).value;
    expect(revived.isActive, isTrue);
    expect(revived.timerSeconds, kDefaultTimerSeconds);
    // Preserves progress: used cities and score carry over.
    expect(revived.usedCityIds, [1, 2]);
    expect(revived.score, 30);
    verify(() => sessionRepository.saveSession(revived)).called(1);
  });

  test('an unknown session surfaces as Result.failure(SessionNotFoundFailure)',
      () async {
    when(() => sessionRepository.getSession(any()))
        .thenAnswer((_) async => null);

    final result = await useCase(sessionId: 'ghost');

    expect(result, isA<ResultFailure<GameSession>>());
    expect((result as ResultFailure<GameSession>).failure,
        isA<SessionNotFoundFailure>());
    verifyNever(() => sessionRepository.saveSession(any()));
  });

  test('a data read error surfaces as Result.failure(DataFailure)', () async {
    when(() => sessionRepository.getSession(any()))
        .thenThrow(Exception('db down'));

    final result = await useCase(sessionId: 's1');

    expect(result, isA<ResultFailure<GameSession>>());
    expect((result as ResultFailure<GameSession>).failure, isA<DataFailure>());
  });
}
