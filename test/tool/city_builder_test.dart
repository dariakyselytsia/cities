import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/city_builder.dart';

/// Covers the name-selection rules of the GeoNames build script, using rows
/// shaped like the real dump (Kyiv, New York, Kropyvnytskyi, …).
void main() {
  GeoCity city(String name, {String featureCode = 'PPL', String cc = 'UA'}) =>
      GeoCity(
        id: 1,
        name: name,
        featureCode: featureCode,
        countryCode: cc,
        population: 100000,
      );

  AltName alt(
    String language,
    String name, {
    bool preferred = false,
    bool short = false,
    bool colloquial = false,
    bool historic = false,
  }) =>
      AltName(
        geonameId: 1,
        language: language,
        name: name,
        isPreferred: preferred,
        isShort: short,
        isColloquial: colloquial,
        isHistoric: historic,
      );

  group('pickNames', () {
    test('takes the current uk name and keeps a historic en name as alias', () {
      final names = pickNames(city('Kyiv'), [
        alt('en', 'Kiev', historic: true),
        alt('uk', 'Київ'),
        alt('en', 'Kyiv', preferred: true),
      ]);

      expect(names.uk, 'Київ');
      expect(names.en, 'Kyiv');
      expect(names.akaUk, isEmpty);
      expect(names.akaEn, ['Kiev']);
    });

    test('keeps historic uk names as aliases, never as the display name', () {
      final names = pickNames(city('Kropyvnytskyi'), [
        alt('uk', 'Кіровоград', historic: true),
        alt('uk', 'Кропивницький', preferred: true),
        alt('uk', 'Єлизаветград', historic: true),
      ]);

      expect(names.uk, 'Кропивницький');
      expect(names.akaUk, ['Єлизаветград', 'Кіровоград']);
    });

    test('prefers the short preferred en name and drops colloquial nicknames',
        () {
      final names = pickNames(city('New York City', cc: 'US'), [
        alt('en', 'Big Apple', colloquial: true),
        alt('en', 'New York City'),
        alt('en', 'New York', preferred: true, short: true),
      ]);

      expect(names.en, 'New York');
      expect(names.akaEn, ['New York City']);
    });

    test('rejects Latin-script rows tagged uk', () {
      final names = pickNames(city('Bila Tserkva'), [
        alt('uk', 'Біла Церква'),
        alt('uk', 'Bila Tserkva'),
      ]);

      expect(names.uk, 'Біла Церква');
      expect(names.akaUk, isEmpty);
    });

    test('rejects uk rows with letters outside the Ukrainian alphabet', () {
      final names = pickNames(city('Shyriaieve'), [
        alt('uk', 'Ширяэве', preferred: true), // Russian э
        alt('uk', 'Мохњин'), // Serbian њ
      ]);

      expect(names.uk, isNull);
      expect(names.akaUk, isEmpty);
    });

    test('leaves uk null when there is no real Ukrainian name', () {
      final names = pickNames(city('Andorra la Vella', cc: 'AD'), [
        alt('en', 'Andorra la Vella'),
      ]);

      expect(names.uk, isNull);
      expect(names.akaUk, isEmpty);
      expect(names.en, 'Andorra la Vella');
    });

    test('ignores a uk name that only exists as historic', () {
      final names = pickNames(city('Somewhere'), [
        alt('uk', 'Стара Назва', historic: true),
      ]);

      expect(names.uk, isNull);
      expect(names.akaUk, isEmpty);
    });

    test('ignores languages other than uk/en (no Russian aliases)', () {
      final names = pickNames(city('Lviv'), [
        alt('uk', 'Львів', preferred: true),
        alt('ru', 'Львов'),
      ]);

      expect(names.akaUk, isEmpty);
    });

    test('falls back to the GeoNames main name when no en row is preferred',
        () {
      final names = pickNames(city('Kraków', cc: 'PL'), [
        alt('en', 'Cracow', historic: true),
      ]);

      expect(names.en, 'Kraków');
      expect(names.akaEn, ['Cracow']);
    });

    test('capitalizes a lower-case uk display name', () {
      final names = pickNames(city('East Cleveland', cc: 'US'), [
        alt('uk', 'іст-Клівленд'),
      ]);

      expect(names.uk, 'Іст-Клівленд');
    });

    test('dedupes aliases differing only by case, hyphens or apostrophes', () {
      final names = pickNames(city("Kam'ianets-Podilskyi"), [
        alt('uk', "Кам'янець-Подільський", preferred: true),
        alt('uk', 'Камʼянець Подільський'),
        alt('en', "Kam'ianets-Podilskyi", preferred: true),
        alt('en', 'Kamianets Podilskyi'),
      ]);

      expect(names.akaUk, isEmpty);
      expect(names.akaEn, isEmpty);
    });
  });

  group('GeoCity', () {
    test('parses a real cities-dump line', () {
      const line = '703448\tKyiv\tKyiv\tKiev,Київ\t50.45466\t30.5238\tP\tPPLC'
          '\tUA\t\t12\t\t\t\t2952301\t\t187\tEurope/Kyiv\t2024-01-01';

      expect(
        GeoCity.tryParse(line),
        isA<GeoCity>()
            .having((c) => c.id, 'id', 703448)
            .having((c) => c.isCapital, 'isCapital', true)
            .having((c) => c.population, 'population', 2952301),
      );
    });

    test('returns null for a malformed line', () {
      expect(GeoCity.tryParse('not\ta\tcity'), isNull);
    });

    test('city sections, historic, abandoned and destroyed places are not playable',
        () {
      for (final code in ['PPLX', 'PPLH', 'PPLQ', 'PPLW']) {
        expect(city('X', featureCode: code).isPlayable, isFalse, reason: code);
      }
      expect(city('X', featureCode: 'PPLA').isPlayable, isTrue);
    });
  });

  group('overrides', () {
    const geonamesDelhi = CityNames(
      uk: 'Старе Делі',
      en: 'Sharjah city',
      akaUk: [],
      akaEn: [],
    );

    test('a uk override replaces the GeoNames name without keeping it', () {
      final names = applyOverride(geonamesDelhi, const CityOverride(uk: 'Делі'));

      expect(names.uk, 'Делі');
      expect(names.akaUk, isEmpty);
    });

    test('an en override keeps the old English name as an alias', () {
      final names =
          applyOverride(geonamesDelhi, const CityOverride(en: 'Sharjah'));

      expect(names.en, 'Sharjah');
      expect(names.akaEn, ['Sharjah city']);
    });

    test('override aliases are merged in', () {
      final names = applyOverride(
        const CityNames(uk: 'Хрустальний', en: 'Khrustalnyi', akaUk: [], akaEn: []),
        const CityOverride(akaUk: ['Красний Луч']),
      );

      expect(names.akaUk, ['Красний Луч']);
    });

    test('parseOverrides reads ids and fields', () {
      final overrides = parseOverrides({
        'cities': {
          '1273294': {'_name': 'Delhi', 'uk': 'Делі'},
          '1': {'exclude': true},
        },
      });

      expect(overrides.keys, [1273294, 1]);
      expect(overrides[1273294]?.uk, 'Делі');
      expect(overrides[1]?.exclude, isTrue);
    });

    test('parseOverrides rejects typos instead of ignoring them', () {
      expect(
        () => parseOverrides({
          'cities': {'1': {'ukk': 'Делі'}},
        }),
        throwsFormatException,
      );
      expect(
        () => parseOverrides({
          'cities': {'1': {'uk': 'Delhi'}},
        }),
        throwsFormatException,
        reason: 'uk must be Cyrillic',
      );
      expect(
        () => parseOverrides({
          'cities': {'1': {'uk': 'Ширяэве'}},
        }),
        throwsFormatException,
        reason: 'uk must use the Ukrainian alphabet',
      );
      expect(
        () => parseOverrides({
          'cities': {'Delhi': {'uk': 'Делі'}},
        }),
        throwsFormatException,
        reason: 'keys must be ids',
      );
    });
  });

  group('withOfficialUkrainianEnglish', () {
    test('replaces an outdated romanization and keeps it as an alias', () {
      final names = withOfficialUkrainianEnglish(
        const CityNames(
          uk: 'Запоріжжя',
          en: 'Zaporizhzhya',
          akaUk: [],
          akaEn: ['Zaporozhye'],
        ),
      );

      expect(names.en, 'Zaporizhzhia');
      expect(names.akaEn, ['Zaporizhzhya', 'Zaporozhye']);
    });

    test('transliterates pre-renaming uk aliases into en aliases', () {
      final names = withOfficialUkrainianEnglish(
        const CityNames(
          uk: 'Хрустальний',
          en: 'Khrustalnyi',
          akaUk: ['Красний Луч'],
          akaEn: [],
        ),
      );

      expect(names.akaEn, ['Krasnyi Luch']);
    });

    test('leaves a city without a uk name unchanged', () {
      const names = CityNames(uk: null, en: 'X', akaUk: [], akaEn: []);

      expect(withOfficialUkrainianEnglish(names), same(names));
    });
  });

  group('cityRecord', () {
    test('omits empty and default fields', () {
      final record = cityRecord(
        city('Andorra la Vella', featureCode: 'PPLC', cc: 'AD'),
        const CityNames(uk: null, en: 'Andorra la Vella', akaUk: [], akaEn: []),
        uaOnly: false,
      );

      expect(record, {
        'id': 1,
        'en': 'Andorra la Vella',
        'cc': 'AD',
        'cap': true,
        'pop': 100000,
      });
    });
  });
}
