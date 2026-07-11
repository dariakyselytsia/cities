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
          isUkrainianLanguage: any(named: 'isUkrainianLanguage'),
        )).thenAnswer((_) async => {'к', 'л', 'о', 'а'});
  });

  // Unwraps the Success branch for the happy-path suggestion tests.
  Future<String?> hint({List<int> used = const [], String previous = ''}) async {
    final result = await useCase(
      mode: GameMode.ukraine,
      language: AppLanguage.ua,
      usedCityIds: used,
      previousCity: previous,
    );
    return (result as Success<String?>).value;
  }

  test('opening move suggests the first unused city', () async {
    expect(await hint(), 'Київ');
  });

  test('suggests a city matching the required next letter', () async {
    // "Бордо" ends in 'о' -> required next letter 'о' -> only Odesa qualifies.
    expect(await hint(previous: 'Бордо'), 'Одеса');
  });

  test('skips already-used cities', () async {
    expect(await hint(used: const [1]), 'Львів');
  });

  test('returns null when no unused city matches the required letter', () async {
    // Previous ends in 'л' -> requires 'л'; Lviv (л) is already used.
    expect(await hint(used: const [2], previous: 'Байкал'), isNull);
  });

  test('an asset load error surfaces as Result.failure(AssetFailure)', () async {
    when(() => cityRepository.loadCities(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenThrow(Exception('asset missing'));
    final result = await useCase(
      mode: GameMode.ukraine,
      language: AppLanguage.ua,
      usedCityIds: const [],
      previousCity: '',
    );
    expect(result, isA<ResultFailure<String?>>());
    expect((result as ResultFailure<String?>).failure, isA<AssetFailure>());
  });
}
