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

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionInProgress] on successful StartSession',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => Future.value());
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

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [AnswerValidated] on successful ValidateAnswer',
      build: () {
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(
        ValidateAnswer(cityName: 'Kyiv', previousCity: 'Lviv', mode: 'UA'),
      ),
      expect: () => [isA<AnswerValidated>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionFailure] on failed ValidateAnswer',
      build: () {
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
          ),
        ).thenThrow(Exception('fail'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        ValidateAnswer(cityName: 'Kyiv', previousCity: 'Lviv', mode: 'UA'),
      ),
      expect: () => [isA<GameSessionFailure>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [HintUsed] on successful UseHint',
      build: () {
        when(
          () => useHintUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => 'Odesa');
        return bloc;
      },
      act: (bloc) => bloc.add(UseHint(sessionId: 'session1')),
      expect: () => [isA<HintUsed>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionFailure] on failed UseHint',
      build: () {
        when(
          () => useHintUseCase(sessionId: any(named: 'sessionId')),
        ).thenThrow(Exception('fail'));
        return bloc;
      },
      act: (bloc) => bloc.add(UseHint(sessionId: 'session1')),
      expect: () => [isA<GameSessionFailure>()],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [SessionRevived] on successful ReviveSession',
      build: () {
        when(
          () => reviveSessionUseCase(sessionId: any(named: 'sessionId')),
        ).thenAnswer((_) async => Future.value());
        return bloc;
      },
      act: (bloc) => bloc.add(ReviveSession(sessionId: 'session1')),
      expect: () => [isA<SessionRevived>()],
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
      'emits [GameSessionInProgress] when TimerTick is above zero',
      build: () => bloc,
      act: (bloc) => bloc.add(TimerTick(secondsLeft: 10)),
      expect: () => [isA<GameSessionInProgress>()],
    );
  });
}
