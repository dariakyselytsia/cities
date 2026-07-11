import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/end_game_session_usecase_impl.dart';

class MockGameSessionRepository extends Mock
    implements GameSessionRepository {}

void main() {
  late MockGameSessionRepository sessionRepository;
  late EndGameSessionUseCaseImpl useCase;

  const active = GameSession(
    id: 's1',
    mode: GameMode.ukraine,
    language: AppLanguage.ua,
    usedCityIds: [1],
    timerSeconds: 12,
    isActive: true,
    score: 40,
  );

  setUpAll(() {
    registerFallbackValue(active);
  });

  setUp(() {
    sessionRepository = MockGameSessionRepository();
    useCase = EndGameSessionUseCaseImpl(sessionRepository);
    when(() => sessionRepository.saveSession(any()))
        .thenAnswer((_) async {});
  });

  test('marks the session inactive with a zeroed timer and persists it',
      () async {
    when(() => sessionRepository.getSession('s1'))
        .thenAnswer((_) async => active);

    final result = await useCase(sessionId: 's1');

    expect(result, isA<Success<void>>());
    final captured = verify(() => sessionRepository.saveSession(captureAny()))
        .captured
        .single as GameSession;
    expect(captured.isActive, isFalse);
    expect(captured.timerSeconds, 0);
    // Final score/history are preserved.
    expect(captured.score, 40);
    expect(captured.usedCityIds, [1]);
  });

  test('ending an unknown session is a no-op success', () async {
    when(() => sessionRepository.getSession(any()))
        .thenAnswer((_) async => null);

    final result = await useCase(sessionId: 'ghost');

    expect(result, isA<Success<void>>());
    verifyNever(() => sessionRepository.saveSession(any()));
  });

  test('a data error surfaces as Result.failure(DataFailure)', () async {
    when(() => sessionRepository.getSession(any()))
        .thenThrow(Exception('db down'));

    final result = await useCase(sessionId: 's1');

    expect(result, isA<ResultFailure<void>>());
    expect((result as ResultFailure<void>).failure, isA<DataFailure>());
  });
}
