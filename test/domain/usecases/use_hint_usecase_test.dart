import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/use_hint_usecase_impl.dart';

class MockCityRepository extends Mock implements CityRepository {}

void main() {
  late MockCityRepository cityRepository;
  late UseHintUseCaseImpl useCase;

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
    useCase = UseHintUseCaseImpl(cityRepository);
    when(() => cityRepository.loadCities(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenAnswer((_) async => [kyiv, lviv, odesa]);
    when(() => cityRepository.availableFirstLetters(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenAnswer((_) async => {'к', 'л', 'о', 'а'});
  });

  test('opening move suggests the first unused city', () async {
    final hint = await useCase(mode: 'UA', usedCityIds: const [], previousCity: '');
    expect(hint, 'Київ');
  });

  test('suggests a city matching the required next letter', () async {
    // "Бордо" ends in 'о' -> required next letter 'о' -> only Odesa qualifies.
    final hint =
        await useCase(mode: 'UA', usedCityIds: const [], previousCity: 'Бордо');
    expect(hint, 'Одеса');
  });

  test('skips already-used cities', () async {
    final hint = await useCase(
      mode: 'UA',
      usedCityIds: const [1],
      previousCity: '',
    );
    expect(hint, 'Львів');
  });

  test('returns null when no unused city matches the required letter', () async {
    // Previous ends in 'л' -> requires 'л'; Lviv (л) is already used.
    final hint = await useCase(
      mode: 'UA',
      usedCityIds: const [2],
      previousCity: 'Байкал',
    );
    expect(hint, isNull);
  });
}
