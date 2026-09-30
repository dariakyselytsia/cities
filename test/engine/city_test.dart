import 'package:cities/engine/city.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('City.fromJson', () {
    test('parses every field', () {
      final city = City.fromJson({
        'id': 703448,
        'uk': 'Київ',
        'en': 'Kyiv',
        'cc': 'UA',
        'cap': true,
        'pop': 2952301,
        'akaUk': ['Кийів'],
        'akaEn': ['Kiev'],
      });

      expect(
        city,
        const City(
          id: 703448,
          nameUk: 'Київ',
          nameEn: 'Kyiv',
          countryCode: 'UA',
          isCapital: true,
          population: 2952301,
          aliasesUk: ['Кийів'],
          aliasesEn: ['Kiev'],
        ),
      );
    });

    test('omitted optional fields get their defaults', () {
      final city = City.fromJson({
        'id': 1,
        'en': 'Mohnyin',
        'cc': 'MM',
        'pop': 20000,
      });

      expect(city.nameUk, isNull);
      expect(city.isCapital, isFalse);
      expect(city.isUkraineOnly, isFalse);
      expect(city.aliasesUk, isEmpty);
      expect(city.aliasesEn, isEmpty);
    });

    test('reads the Ukraine-only flag', () {
      final city = City.fromJson({
        'id': 2,
        'uk': 'Вільне',
        'en': 'Vilne',
        'cc': 'UA',
        'pop': 6000,
        'uaOnly': true,
      });
      expect(city.isUkraineOnly, isTrue);
    });

    test('aliases are unmodifiable', () {
      final city = City.fromJson({
        'id': 3,
        'en': 'Mumbai',
        'cc': 'IN',
        'pop': 12691836,
        'akaEn': ['Bombay'],
      });
      expect(() => city.aliasesEn.add('x'), throwsUnsupportedError);
    });

    const valid = {'id': 1, 'en': 'Lviv', 'cc': 'UA', 'pop': 717273};
    final invalid = <String, Map<String, Object?>>{
      'missing id': {...valid}..remove('id'),
      'missing en': {...valid}..remove('en'),
      'missing cc': {...valid}..remove('cc'),
      'missing pop': {...valid}..remove('pop'),
      'id as a string': {...valid, 'id': '1'},
      'empty en': {...valid, 'en': ''},
      'uk as a number': {...valid, 'uk': 5},
      'empty uk': {...valid, 'uk': ''},
      'cap as a string': {...valid, 'cap': 'yes'},
      'aliases not a list': {...valid, 'akaEn': 'Lemberg'},
      'alias not a string': {...valid, 'akaEn': ['Lemberg', 7]},
    };
    for (final MapEntry(key: problem, value: json) in invalid.entries) {
      test('rejects $problem with a FormatException', () {
        expect(() => City.fromJson(json), throwsFormatException);
      });
    }
  });

  group('City names by language', () {
    const lviv = City(
      id: 702550,
      nameUk: 'Львів',
      nameEn: 'Lviv',
      countryCode: 'UA',
      population: 717273,
      aliasesUk: ['Лемберг'],
      aliasesEn: ['Lvov', 'Lemberg'],
    );
    const noUk = City(
      id: 1,
      nameEn: 'Mohnyin',
      countryCode: 'MM',
      population: 20000,
    );

    test('name() picks the language', () {
      expect(lviv.name(NameLanguage.uk), 'Львів');
      expect(lviv.name(NameLanguage.en), 'Lviv');
      expect(noUk.name(NameLanguage.uk), isNull);
    });

    test('aliases() picks the language', () {
      expect(lviv.aliases(NameLanguage.uk), ['Лемберг']);
      expect(lviv.aliases(NameLanguage.en), ['Lvov', 'Lemberg']);
    });
  });
}
