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

class MockGetBotCityUseCase extends Mock implements GetBotCityUseCase {}

class MockUseHintUseCase extends Mock implements UseHintUseCase {}

class MockReviveSessionUseCase extends Mock implements ReviveSessionUseCase {}

class MockEndGameSessionUseCase extends Mock implements EndGameSessionUseCase {}

class MockGetUserStatsUseCase extends Mock implements GetUserStatsUseCase {}

class MockRecordSessionResultUseCase extends Mock
    implements RecordSessionResultUseCase {}

/// Empty lifetime stats — the default the stats use cases return in these tests
/// (no persisted history), so scoring/streak assertions stay deterministic.
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
  group('GameSessionBloc', () {
    late MockStartGameSessionUseCase startGameSessionUseCase;
    late MockValidateCityAnswerUseCase validateCityAnswerUseCase;
    late MockGetBotCityUseCase getBotCityUseCase;
    late MockUseHintUseCase useHintUseCase;
    late MockReviveSessionUseCase reviveSessionUseCase;
    late MockEndGameSessionUseCase endGameSessionUseCase;
    late MockGetUserStatsUseCase getUserStatsUseCase;
    late MockRecordSessionResultUseCase recordSessionResultUseCase;
    late GameSessionBloc bloc;

    // Bot returns are popped in order per call; defaults to "no city" (null)
    // once exhausted. Each test fills this in its `build`.
    late List<Result<BotMove?>> botReturns;

    setUpAll(() {
      registerFallbackValue(<int>[]);
      registerFallbackValue(GameMode.ukraine);
      registerFallbackValue(AppLanguage.ua);
    });

    setUp(() {
      startGameSessionUseCase = MockStartGameSessionUseCase();
      validateCityAnswerUseCase = MockValidateCityAnswerUseCase();
      getBotCityUseCase = MockGetBotCityUseCase();
      useHintUseCase = MockUseHintUseCase();
      reviveSessionUseCase = MockReviveSessionUseCase();
      endGameSessionUseCase = MockEndGameSessionUseCase();
      getUserStatsUseCase = MockGetUserStatsUseCase();
      recordSessionResultUseCase = MockRecordSessionResultUseCase();
      // Default: no persisted stats, and recording succeeds — individual tests
      // don't care about lifetime stats, only that the game loop is unaffected.
      when(
        () => getUserStatsUseCase(),
      ).thenAnswer((_) async => const Success(_emptyStats));
      when(
        () => recordSessionResultUseCase(
          sessionId: any(named: 'sessionId'),
          mode: any(named: 'mode'),
          score: any(named: 'score'),
          playerCityIds: any(named: 'playerCityIds'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async => const Success(_emptyStats));
      botReturns = [];
      when(
        () => getBotCityUseCase(
          mode: any(named: 'mode'),
          language: any(named: 'language'),
          usedCityIds: any(named: 'usedCityIds'),
          previousCity: any(named: 'previousCity'),
        ),
      ).thenAnswer(
        (_) async => botReturns.isNotEmpty
            ? botReturns.removeAt(0)
            : const Success<BotMove?>(null),
      );
      bloc = GameSessionBloc(
        startGameSessionUseCase: startGameSessionUseCase,
        validateCityAnswerUseCase: validateCityAnswerUseCase,
        getBotCityUseCase: getBotCityUseCase,
        useHintUseCase: useHintUseCase,
        reviveSessionUseCase: reviveSessionUseCase,
        endGameSessionUseCase: endGameSessionUseCase,
        getUserStatsUseCase: getUserStatsUseCase,
        recordSessionResultUseCase: recordSessionResultUseCase,
      );
    });

    test('initial state is GameSessionInitial', () {
      expect(bloc.state, isA<GameSessionInitial>());
    });

    final testSession = GameSession(
      id: 'session1',
      mode: GameMode.ukraine,
      language: AppLanguage.ua,
      usedCityIds: const [],
      timerSeconds: 60,
      isActive: true,
    );

    const botOpenCity = City(
      id: 1,
      nameUA: 'Одеса',
      nameEN: 'Odesa',
      countryCode: 'UA',
      isCapital: false,
      firstLetterUA: 'О',
      firstLetterEN: 'O',
    );
    const playerCity = City(
      id: 2,
      nameUA: 'Київ',
      nameEN: 'Kyiv',
      countryCode: 'UA',
      isCapital: true,
      firstLetterUA: 'К',
      firstLetterEN: 'K',
    );
    const botReplyCity = City(
      id: 3,
      nameUA: 'Вінниця',
      nameEN: 'Vinnytsia',
      countryCode: 'UA',
      isCapital: false,
      firstLetterUA: 'В',
      firstLetterEN: 'V',
    );

    const botOpenMove = BotMove(city: botOpenCity, nextLetter: 'А');
    const botReplyMove = BotMove(city: botReplyCity, nextLetter: 'Я');

    void stubStartSuccess() => when(
      () => startGameSessionUseCase(
        userId: any(named: 'userId'),
        mode: any(named: 'mode'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) async => Success(testSession));

    void stubValidate(Result<ValidationOutcome> result) => when(
      () => validateCityAnswerUseCase(
        cityName: any(named: 'cityName'),
        previousCity: any(named: 'previousCity'),
        mode: any(named: 'mode'),
        language: any(named: 'language'),
        usedCityIds: any(named: 'usedCityIds'),
        historicUsedCityIds: any(named: 'historicUsedCityIds'),
      ),
    ).thenAnswer((_) async => result);

    blocTest<GameSessionBloc, GameSessionState>(
      'CityBot opens the game: first board shows the bot\'s city',
      build: () {
        stubStartSuccess();
        botReturns = [const Success<BotMove?>(botOpenMove)];
        return bloc;
      },
      act: (bloc) => bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        ),
      expect: () => [
        isA<GameSessionLoading>(),
        const GameSessionInProgress(
          session: GameSession(
            id: 'session1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
            usedCityIds: [1],
            timerSeconds: 60,
            isActive: true,
          ),
          timerSeconds: 60,
          history: [ChatMessage(text: 'Одеса', isBot: true)],
          requiredLetter: 'А',
        ),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits [GameSessionLoading, GameSessionFailure(DataFailure)] on failed StartSession',
      build: () {
        when(
          () => startGameSessionUseCase(
            userId: any(named: 'userId'),
            mode: any(named: 'mode'),
            language: any(named: 'language'),
          ),
        ).thenAnswer((_) async => const ResultFailure(DataFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        ),
      expect: () => [
        isA<GameSessionLoading>(),
        const GameSessionFailure(DataFailure()),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'ends the round when CityBot cannot open (exhausted pool)',
      build: () {
        stubStartSuccess();
        botReturns = [const Success<BotMove?>(null)];
        return bloc;
      },
      act: (bloc) => bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        ),
      expect: () => [
        isA<GameSessionLoading>(),
        const GameSessionEnded(score: 0),
      ],
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'accepted answer scores the city, then CityBot replies (shared chain)',
      build: () {
        stubStartSuccess();
        stubValidate(
          const Success(
            ValidationOutcome.accepted(city: playerCity, points: kBasePoints),
          ),
        );
        botReturns = [
          const Success<BotMove?>(botOpenMove),
          const Success<BotMove?>(botReplyMove),
        ];
        return bloc;
      },
      act: (bloc) async {
        bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(ValidateAnswer(cityName: 'Kyiv'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(), // bot opening
        isA<GameSessionInProgress>(), // player's accepted answer
        isA<GameSessionInProgress>(), // bot's reply
      ],
      verify: (bloc) {
        final state = bloc.state as GameSessionInProgress;
        expect(state.session.score, kBasePoints);
        expect(state.session.usedCityIds, [1, 2, 3]);
        expect(state.history, const [
          ChatMessage(text: 'Одеса', isBot: true),
          ChatMessage(text: 'Київ', isBot: false),
          ChatMessage(text: 'Вінниця', isBot: true),
        ]);
        expect(state.requiredLetter, 'Я');
        // The player answered off CityBot's opening city, with the bot's city
        // already in the shared used-set — proves the chain runs across sides.
        final captured = verify(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: captureAny(named: 'previousCity'),
            mode: any(named: 'mode'),
            language: any(named: 'language'),
            usedCityIds: captureAny(named: 'usedCityIds'),
            historicUsedCityIds: any(named: 'historicUsedCityIds'),
          ),
        ).captured;
        expect(captured, [
          'Одеса',
          [1],
        ]);
      },
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'rejected answer keeps the board; CityBot does not reply',
      build: () {
        stubStartSuccess();
        stubValidate(
          const Success(ValidationOutcome.rejected(AnswerStatus.wrongLetter)),
        );
        botReturns = [const Success<BotMove?>(botOpenMove)];
        return bloc;
      },
      act: (bloc) async {
        bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(ValidateAnswer(cityName: 'Nope'));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(), // bot opening
        isA<GameSessionInProgress>(), // rejection verdict
      ],
      verify: (bloc) {
        final state = bloc.state as GameSessionInProgress;
        expect(state.session.score, 0);
        expect(state.session.usedCityIds, [1]); // only the bot's opening city
        expect(state.history, const [ChatMessage(text: 'Одеса', isBot: true)]);
        expect(state.lastOutcome?.status, AnswerStatus.wrongLetter);
        expect(state.requiredLetter, 'А'); // unchanged, preserved
        // Bot ran only for the opening — a rejection does not trigger a reply.
        verify(
          () => getBotCityUseCase(
            mode: any(named: 'mode'),
            language: any(named: 'language'),
            usedCityIds: any(named: 'usedCityIds'),
            previousCity: any(named: 'previousCity'),
          ),
        ).called(1);
      },
    );

    blocTest<GameSessionBloc, GameSessionState>(
      'emits GameSessionFailure(UnknownFailure) when validation throws',
      build: () {
        stubStartSuccess();
        when(
          () => validateCityAnswerUseCase(
            cityName: any(named: 'cityName'),
            previousCity: any(named: 'previousCity'),
            mode: any(named: 'mode'),
            language: any(named: 'language'),
            usedCityIds: any(named: 'usedCityIds'),
            historicUsedCityIds: any(named: 'historicUsedCityIds'),
          ),
        ).thenThrow(Exception('fail'));
        botReturns = [const Success<BotMove?>(botOpenMove)];
        return bloc;
      },
      act: (bloc) async {
        bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 30));
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
        stubStartSuccess();
        when(
          () => useHintUseCase(
            mode: any(named: 'mode'),
            language: any(named: 'language'),
            usedCityIds: any(named: 'usedCityIds'),
            previousCity: any(named: 'previousCity'),
          ),
        ).thenAnswer((_) async => const Success<String?>('Odesa'));
        botReturns = [const Success<BotMove?>(botOpenMove)];
        return bloc;
      },
      act: (bloc) async {
        bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(UseHint());
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<GameSessionInProgress>(),
      ],
      verify: (bloc) {
        final state = bloc.state as GameSessionInProgress;
        expect(state.hint, 'Odesa');
      },
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
      'TimerTick above zero re-emits the board with the new time',
      build: () {
        stubStartSuccess();
        botReturns = [const Success<BotMove?>(botOpenMove)];
        return bloc;
      },
      act: (bloc) async {
        bloc.add(
          StartSession(
            userId: 'u1',
            mode: GameMode.ukraine,
            language: AppLanguage.ua,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(TimerTick(secondsLeft: 10));
      },
      expect: () => [
        isA<GameSessionLoading>(),
        isA<GameSessionInProgress>(),
        isA<GameSessionInProgress>(),
      ],
      verify: (bloc) {
        expect((bloc.state as GameSessionInProgress).timerSeconds, 10);
      },
    );
  });
}
