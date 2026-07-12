import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/start_game_session_usecase_impl.dart';

class MockCityRepository extends Mock implements CityRepository {}

class MockGameSessionRepository extends Mock
    implements GameSessionRepository {}

void main() {
  late MockCityRepository cityRepository;
  late MockGameSessionRepository sessionRepository;
  late StartGameSessionUseCaseImpl useCase;

  setUpAll(() {
    registerFallbackValue(
      const GameSession(
        id: '0',
        mode: GameMode.ukraine,
        language: AppLanguage.ua,
        usedCityIds: [],
        timerSeconds: 0,
        isActive: false,
      ),
    );
  });

  setUp(() {
    cityRepository = MockCityRepository();
    sessionRepository = MockGameSessionRepository();
    useCase = StartGameSessionUseCaseImpl(cityRepository, sessionRepository);
    when(() => cityRepository.loadCities(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenAnswer((_) async => const []);
    when(() => sessionRepository.saveSession(any()))
        .thenAnswer((_) async {});
  });

  test('starts a fresh Ukraine session and persists it', () async {
    final result = await useCase(
      userId: 'u1',
      mode: GameMode.ukraine,
      language: AppLanguage.ua,
    );

    expect(result, isA<Success<GameSession>>());
    final session = (result as Success<GameSession>).value;
    expect(session.mode, GameMode.ukraine);
    expect(session.language, AppLanguage.ua);
    expect(session.isActive, isTrue);
    expect(session.usedCityIds, isEmpty);
    expect(session.score, 0);
    expect(session.timerSeconds, kDefaultTimerSeconds);
    // Warms the cache for the chosen mode and persists the new session.
    verify(() => cityRepository.loadCities(isUkraineMode: true)).called(1);
    verify(() => sessionRepository.saveSession(session)).called(1);
  });

  test('language is independent of mode (World dataset, Ukrainian names)',
      () async {
    final result = await useCase(
      userId: 'u1',
      mode: GameMode.world,
      language: AppLanguage.ua, // playing the World list in Ukrainian
    );

    final session = (result as Success<GameSession>).value;
    expect(session.mode, GameMode.world);
    expect(session.language, AppLanguage.ua);
    verify(() => cityRepository.loadCities(isUkraineMode: false)).called(1);
  });

  test('an asset load error surfaces as Result.failure(AssetFailure)', () async {
    when(() => cityRepository.loadCities(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenThrow(Exception('asset missing'));

    final result = await useCase(
      userId: 'u1',
      mode: GameMode.ukraine,
      language: AppLanguage.ua,
    );

    expect(result, isA<ResultFailure<GameSession>>());
    expect((result as ResultFailure<GameSession>).failure, isA<AssetFailure>());
    verifyNever(() => sessionRepository.saveSession(any()));
  });

  test('a persistence error surfaces as Result.failure(DataFailure)', () async {
    when(() => sessionRepository.saveSession(any()))
        .thenThrow(Exception('disk full'));

    final result = await useCase(
      userId: 'u1',
      mode: GameMode.ukraine,
      language: AppLanguage.ua,
    );

    expect(result, isA<ResultFailure<GameSession>>());
    expect((result as ResultFailure<GameSession>).failure, isA<DataFailure>());
  });
}
