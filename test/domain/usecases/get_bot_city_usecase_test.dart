import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/get_bot_city_usecase_impl.dart';

class MockCityRepository extends Mock implements CityRepository {}

void main() {
  late MockCityRepository cityRepository;

  const kyiv = City(
    id: 1,
    nameUA: 'Київ',
    nameEN: 'Kyiv',
    countryCode: 'UA',
    isCapital: true,
    firstLetterUA: 'К',
    firstLetterEN: 'K',
  );
  const lviv = City(
    id: 2,
    nameUA: 'Львів',
    nameEN: 'Lviv',
    countryCode: 'UA',
    isCapital: false,
    firstLetterUA: 'Л',
    firstLetterEN: 'L',
  );
  const odesa = City(
    id: 3,
    nameUA: 'Одеса',
    nameEN: 'Odesa',
    countryCode: 'UA',
    isCapital: false,
    firstLetterUA: 'О',
    firstLetterEN: 'O',
  );

  setUp(() {
    cityRepository = MockCityRepository();
    when(() => cityRepository.loadCities(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenAnswer((_) async => [kyiv, lviv, odesa]);
    when(() => cityRepository.availableFirstLetters(
          isUkraineMode: any(named: 'isUkraineMode'),
          isUkrainianLanguage: any(named: 'isUkrainianLanguage'),
        )).thenAnswer((_) async => {'к', 'л', 'о', 'а', 'в', 'і'});
  });

  GetBotCityUseCaseImpl useCaseWith(Random random) =>
      GetBotCityUseCaseImpl(cityRepository, random);

  Future<BotMove?> move(
    GetBotCityUseCase useCase, {
    GameMode mode = GameMode.ukraine,
    AppLanguage language = AppLanguage.ua,
    List<int> used = const [],
    String previous = '',
  }) async {
    final result = await useCase(
      mode: mode,
      language: language,
      usedCityIds: used,
      previousCity: previous,
    );
    return (result as Success<BotMove?>).value;
  }

  test('opening move picks an unused city and reports the next letter', () async {
    final m = await move(useCaseWith(Random(1)));
    expect([kyiv, lviv, odesa], contains(m!.city));
    expect(m.nextLetter, isNotNull);
  });

  test('respects the required next letter', () async {
    // "Бордо" ends in 'о' → required 'о' → only Одеса qualifies.
    final m = await move(useCaseWith(Random(1)), previous: 'Бордо');
    expect(m!.city, odesa);
    expect(m.nextLetter, 'А'); // 'Одеса' ends in 'а'
  });

  test('returns null when every valid city is already used', () async {
    final m = await move(useCaseWith(Random(1)), used: const [1, 2, 3]);
    expect(m, isNull);
  });

  test('World dataset played in Ukrainian names the city in Ukrainian', () async {
    final m = await move(
      useCaseWith(Random(1)),
      mode: GameMode.world,
      language: AppLanguage.ua,
      previous: 'Бордо',
    );
    expect(m!.city, odesa); // matched by UA name/letter
    // Dataset loaded for World, letters resolved for Ukrainian — decoupled.
    verify(() => cityRepository.loadCities(isUkraineMode: false)).called(1);
    verify(() => cityRepository.availableFirstLetters(
        isUkraineMode: false, isUkrainianLanguage: true)).called(1);
  });

  test('selection is randomized across candidates over many seeds', () async {
    final picks = <int>{};
    for (var seed = 0; seed < 20; seed++) {
      final m = await move(useCaseWith(Random(seed)));
      picks.add(m!.city.id);
    }
    // With three unused candidates on the opening move, a varied RNG should
    // surface more than one distinct city (not always the first match).
    expect(picks.length, greaterThan(1));
  });
}
