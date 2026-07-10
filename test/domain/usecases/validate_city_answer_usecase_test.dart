import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/domain/usecases/validate_city_answer_usecase_impl.dart';

class MockCityRepository extends Mock implements CityRepository {}

void main() {
  late MockCityRepository cityRepository;
  late ValidateCityAnswerUseCaseImpl useCase;

  const kyiv = City(
    id: 1,
    nameUA: 'Київ',
    nameEN: 'Kyiv',
    countryCode: 'UA',
    isCapital: true,
    firstLetterUA: 'К',
    firstLetterEN: 'K',
  );

  setUp(() {
    cityRepository = MockCityRepository();
    useCase = ValidateCityAnswerUseCaseImpl(cityRepository);
    when(() => cityRepository.availableFirstLetters(
          isUkraineMode: any(named: 'isUkraineMode'),
        )).thenAnswer((_) async => {'к', 'л', 'а', 'в', 'о'});
  });

  Future<ValidationOutcome> validate({
    String city = 'Kyiv',
    String previous = '',
    List<int> used = const [],
    Set<int>? historic,
  }) =>
      useCase(
        cityName: city,
        previousCity: previous,
        mode: GameMode.ukraine,
        usedCityIds: used,
        historicUsedCityIds: historic,
      );

  test('empty answer is notFound', () async {
    final outcome = await validate(city: '   ');
    expect(outcome.status, AnswerStatus.notFound);
  });

  test('unknown city is notFound', () async {
    when(() => cityRepository.getCityByName(any(), isUA: any(named: 'isUA')))
        .thenAnswer((_) async => null);
    final outcome = await validate(city: 'Atlantis');
    expect(outcome.status, AnswerStatus.notFound);
  });

  test('city already used this session is alreadyUsed', () async {
    when(() => cityRepository.getCityByName(any(), isUA: any(named: 'isUA')))
        .thenAnswer((_) async => kyiv);
    final outcome = await validate(used: [kyiv.id]);
    expect(outcome.status, AnswerStatus.alreadyUsed);
    expect(outcome.city, kyiv);
  });

  test('wrong first letter is wrongLetter', () async {
    when(() => cityRepository.getCityByName(any(), isUA: any(named: 'isUA')))
        .thenAnswer((_) async => kyiv);
    // Previous "Львів" requires the next city to start with 'в'; Kyiv starts 'к'.
    final outcome = await validate(previous: 'Львів');
    expect(outcome.status, AnswerStatus.wrongLetter);
  });

  test('opening move accepts any real city and awards base points', () async {
    when(() => cityRepository.getCityByName(any(), isUA: any(named: 'isUA')))
        .thenAnswer((_) async => kyiv);
    final outcome = await validate();
    expect(outcome.isAccepted, isTrue);
    expect(outcome.points, kBasePoints);
    expect(outcome.isNewToPlayer, isFalse);
  });

  test('correct letter accepts and awards base points', () async {
    when(() => cityRepository.getCityByName(any(), isUA: any(named: 'isUA')))
        .thenAnswer((_) async => kyiv);
    // Previous "Одеса" ends in 'а'... use a previous ending in 'к' for Kyiv.
    final outcome = await validate(previous: 'Мурманськ');
    expect(outcome.isAccepted, isTrue);
    expect(outcome.points, kBasePoints);
  });

  test('absolute-new-city bonus applies when history is supplied', () async {
    when(() => cityRepository.getCityByName(any(), isUA: any(named: 'isUA')))
        .thenAnswer((_) async => kyiv);
    final outcome = await validate(historic: <int>{99});
    expect(outcome.isAccepted, isTrue);
    expect(outcome.isNewToPlayer, isTrue);
    expect(outcome.points, kBasePoints + kNewCityBonus);
  });
}
