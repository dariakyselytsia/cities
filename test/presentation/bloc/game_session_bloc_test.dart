import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/presentation/bloc/game_session_bloc.dart';
import 'package:cities/domain/domain.dart';

// Mock Use Cases
class MockStartGameSessionUseCase extends Mock
    implements StartGameSessionUseCase {}

class MockValidateCityAnswerUseCase extends Mock
    implements ValidateCityAnswerUseCase {}

class MockUseHintUseCase extends Mock implements UseHintUseCase {}

class MockReviveSessionUseCase extends Mock implements ReviveSessionUseCase {}

class MockEndGameSessionUseCase extends Mock implements EndGameSessionUseCase {}

void main() {
  group('GameSessionBloc', () {
    late MockStartGameSessionUseCase startGameSessionUseCase;
    late MockValidateCityAnswerUseCase validateCityAnswerUseCase;
    late MockUseHintUseCase useHintUseCase;
    late MockReviveSessionUseCase reviveSessionUseCase;
    late MockEndGameSessionUseCase endGameSessionUseCase;
    late GameSessionBloc bloc;

    setUpAll(() {
      registerFallbackValue(<int>[]);
    });

    setUp(() {
      startGameSessionUseCase = MockStartGameSessionUseCase();
      validateCityAnswerUseCase = MockValidateCityAnswerUseCase();
      useHintUseCase = MockUseHintUseCase();
      reviveSessionUseCase = MockReviveSessionUseCase();
      endGameSessionUseCase = MockEndGameSessionUseCase();
      bloc = GameSessionBloc(
        startGameSessionUseCase: startGameSessionUseCase,
        validateCityAnswerUseCase: validateCityAnswerUseCase,
        useHintUseCase: useHintUseCase,
        reviveSessionUseCase: reviveSessionUseCase,
        endGameSessionUseCase: endGameSessionUseCase,
      );
    });

    test('initial state is GameSessionInitial', () {
      expect(bloc.state, isA<GameSessionInitial>());
    });

    final testSession = GameSession(
      id: 'session1',
      mode: 'UA',
      language: 'en',
      usedCityIds: [],
      timerSeconds: 60,
      isActive: true,
    );
    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionInProgress] on successful StartSession',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => testSession);
        return bloc;
      },
      act: (bloc) => bloc.add(StartSession(userId: 'user1', mode: 'UA')),
      expect: () => [isA<GameSessionLoading>(), isA<GameSessionInProgress>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionFailure] on failed StartSession',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenThrow(Exception('fail'));
        return bloc;
      },
      act: (bloc) => bloc.add(StartSession(userId: 'user1', mode: 'UA')),
      expect: () => [isA<GameSessionLoading>(), isA<GameSessionFailure>()],
    );

    const testCity = City(
      id: 2,
      nameUA: 'Київ',
      nameEN: 'Kyiv',
      countryCode: 'UA',
      isCapital: true,
      firstLetterUA: 'К',
      firstLetterEN: 'K',
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'accepted ValidateAnswer adds the real city id and awards points',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => testSession);
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
            usedCityIds: any(named: 'usedCityIds'),
            historicUsedCityIds: any(named: 'historicUsedCityIds'),
          ),
        ).thenAnswer(
          (_) async => const ValidationOutcome.accepted(
            city: testCity,
            points: kBasePoints,
          ),
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: 'UA'));
        await Future.delayed(Duration.zero); // let StartSession process
        bloc.add(ValidateAnswer(cityName: 'Kyiv'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<GameSessionInProgress>()
            .having((s) => s.session.score, 'score', kBasePoints)
            .having((s) => s.session.usedCityIds, 'usedCityIds', [testCity.id]),
        // Full value equality, enabled by Equatable on states + value objects.
        const AnswerValidated(
          outcome: ValidationOutcome.accepted(
            city: testCity,
            points: kBasePoints,
          ),
        ),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'rejected ValidateAnswer emits only AnswerValidated (no score change)',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => testSession);
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
            usedCityIds: any(named: 'usedCityIds'),
            historicUsedCityIds: any(named: 'historicUsedCityIds'),
          ),
        ).thenAnswer(
          (_) async =>
              const ValidationOutcome.rejected(AnswerStatus.wrongLetter),
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: 'UA'));
        await Future.delayed(Duration.zero);
        bloc.add(ValidateAnswer(cityName: 'Odesa'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<AnswerValidated>().having((s) => s.isCorrect, 'isCorrect', false),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionFailure] when validation throws',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => testSession);
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
            usedCityIds: any(named: 'usedCityIds'),
            historicUsedCityIds: any(named: 'historicUsedCityIds'),
          ),
        ).thenThrow(Exception('fail'));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: 'UA'));
        await Future.delayed(Duration.zero);
        bloc.add(ValidateAnswer(cityName: 'Kyiv'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<GameSessionFailure>(),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [HintUsed] on successful UseHint with an active session',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => testSession);
        when(
          () => useHintUseCase(
            mode: any(named: 'mode'),
            usedCityIds: any(named: 'usedCityIds'),
            previousCity: any(named: 'previousCity'),
          ),
        ).thenAnswer((_) async => 'Odesa');
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: 'UA'));
        await Future.delayed(Duration.zero);
        bloc.add(UseHint());
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<HintUsed>().having((s) => s.suggestedCity, 'suggestedCity', 'Odesa'),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionFailure] when UseHint has no active session',
      build: () => bloc,
      act: (bloc) => bloc.add(UseHint()),
      expect: () => [isA<GameSessionFailure>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [SessionRevived, GameSessionInProgress] on successful ReviveSession',
      build: () {
        when(
          () => reviveSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => testSession);
        return bloc;
      },
      act: (bloc) => bloc.add(ReviveSession(sessionId: 'session1')),
      expect: () => [isA<SessionRevived>(), isA<GameSessionInProgress>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionFailure] on failed ReviveSession',
      build: () {
        when(
          () => reviveSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenThrow(Exception('fail'));
        return bloc;
      },
      act: (bloc) => bloc.add(ReviveSession(sessionId: 'session1')),
      expect: () => [isA<GameSessionFailure>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionEnded] on successful EndSession',
      build: () {
        when(
          () => endGameSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => Future.value());
        return bloc;
      },
      act: (bloc) => bloc.add(EndSession(sessionId: 'session1')),
      expect: () => [isA<GameSessionEnded>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionFailure] on failed EndSession',
      build: () {
        when(
          () => endGameSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenThrow(Exception('fail'));
        return bloc;
      },
      act: (bloc) => bloc.add(EndSession(sessionId: 'session1')),
      expect: () => [isA<GameSessionFailure>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionEnded] when TimerTick reaches zero',
      build: () => bloc,
      act: (bloc) => bloc.add(TimerTick(secondsLeft: 0)),
      expect: () => [isA<GameSessionEnded>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionInProgress, GameSessionInProgress] when TimerTick is above zero',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => testSession);
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: 'UA'));
        await Future.delayed(Duration.zero); // let StartSession process
        bloc.add(TimerTick(secondsLeft: 10));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<GameSessionInProgress>(),
      ],
    );
  });
}
