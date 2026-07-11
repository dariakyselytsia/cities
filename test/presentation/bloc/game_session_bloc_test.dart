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
      registerFallbackValue(GameMode.ukraine);
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
      mode: GameMode.ukraine,
      language: AppLanguage.en,
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
        ).thenAnswer((_) async => Success(testSession));
        return bloc;
      },
      act: (bloc) => bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine)),
      expect: () => [isA<GameSessionLoading>(), isA<GameSessionInProgress>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionFailure(DataFailure)] on failed StartSession',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => const ResultFailure(DataFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine)),
      expect: () => [
        isA<GameSessionLoading>(),
        const GameSessionFailure(DataFailure()),
      ],
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
        ).thenAnswer((_) async => Success(testSession));
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
            usedCityIds: any(named: 'usedCityIds'),
            historicUsedCityIds: any(named: 'historicUsedCityIds'),
          ),
        ).thenAnswer(
          (_) async => const Success(
            ValidationOutcome.accepted(city: testCity, points: kBasePoints),
          ),
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine));
        await Future.delayed(Duration.zero); // let StartSession process
        bloc.add(ValidateAnswer(cityName: 'Kyiv'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        // One in-progress emission carries the updated session AND the verdict —
        // no separate transient state. Full value equality via Equatable.
        const GameSessionInProgress(
          session: GameSession(
            id: 'session1',
            mode: GameMode.ukraine,
            language: AppLanguage.en,
            usedCityIds: [2],
            timerSeconds: 60,
            isActive: true,
            score: kBasePoints,
          ),
          timerSeconds: 60,
          // Ukraine mode → canonical UA name is added to the chat history.
          history: ['Київ'],
          lastOutcome: ValidationOutcome.accepted(
            city: testCity,
            points: kBasePoints,
          ),
        ),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'rejected ValidateAnswer re-emits the board with the verdict, no score change',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => Success(testSession));
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
              const Success(ValidationOutcome.rejected(AnswerStatus.wrongLetter)),
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine));
        await Future.delayed(Duration.zero);
        bloc.add(ValidateAnswer(cityName: 'Odesa'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        // Session unchanged (same score/used cities); verdict carried inline.
        GameSessionInProgress(
          session: testSession,
          timerSeconds: 60,
          lastOutcome: const ValidationOutcome.rejected(
            AnswerStatus.wrongLetter,
          ),
        ),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits GameSessionFailure(UnknownFailure) when validation throws unexpectedly',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => Success(testSession));
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
        bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine));
        await Future.delayed(Duration.zero);
        bloc.add(ValidateAnswer(cityName: 'Kyiv'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        const GameSessionFailure(UnknownFailure()),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'UseHint re-emits the board carrying the hint suggestion',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => Success(testSession));
        when(
          () => useHintUseCase(
            mode: any(named: 'mode'),
            usedCityIds: any(named: 'usedCityIds'),
            previousCity: any(named: 'previousCity'),
          ),
        ).thenAnswer((_) async => const Success<String?>('Odesa'));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine));
        await Future.delayed(Duration.zero);
        bloc.add(UseHint());
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        GameSessionInProgress(session: testSession, timerSeconds: 60, hint: 'Odesa'),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits GameSessionFailure(NoActiveSessionFailure) when UseHint has no active session',
      build: () => bloc,
      act: (bloc) => bloc.add(UseHint()),
      expect: () => [const GameSessionFailure(NoActiveSessionFailure())],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [SessionRevived, GameSessionInProgress] on successful ReviveSession',
      build: () {
        when(
          () => reviveSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => Success(testSession));
        return bloc;
      },
      act: (bloc) => bloc.add(ReviveSession(sessionId: 'session1')),
      expect: () => [isA<SessionRevived>(), isA<GameSessionInProgress>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits GameSessionFailure(SessionNotFoundFailure) on failed ReviveSession',
      build: () {
        when(
          () => reviveSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => const ResultFailure(SessionNotFoundFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ReviveSession(sessionId: 'session1')),
      expect: () => [const GameSessionFailure(SessionNotFoundFailure())],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionEnded] on successful EndSession',
      build: () {
        when(
          () => endGameSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => const Success<void>(null));
        return bloc;
      },
      act: (bloc) => bloc.add(EndSession(sessionId: 'session1')),
      expect: () => [isA<GameSessionEnded>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits GameSessionFailure(DataFailure) on failed EndSession',
      build: () {
        when(
          () => endGameSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => const ResultFailure(DataFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(EndSession(sessionId: 'session1')),
      expect: () => [const GameSessionFailure(DataFailure())],
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
        ).thenAnswer((_) async => Success(testSession));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(StartSession(userId: 'user1', mode: GameMode.ukraine));
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
