import 'dart:convert';
import 'dart:io';

import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds the catalog from the real `assets/data/cities.json` and checks the
/// properties the game relies on.
void main() {
  final watch = Stopwatch()..start();
  final catalog = CityCatalog.fromJson(
    jsonDecode(File('assets/data/cities.json').readAsStringSync()),
  );
  final buildTime = watch.elapsed;

  test('builds every index from the real data', () {
    // Parse + index, on a desktop; the phone does it in a background
    // isolate (T10). Printed so a slowdown is visible in the test log.
    // ignore: avoid_print
    print('Catalog built in ${buildTime.inMilliseconds} ms');
    expect(
      catalog.index(CityListKind.ukraine, NameLanguage.uk).cities,
      hasLength(greaterThan(800)),
    );
    expect(
      catalog.index(CityListKind.world, NameLanguage.en).cities,
      hasLength(greaterThan(30000)),
    );
    expect(
      catalog.index(CityListKind.world, NameLanguage.uk).cities,
      hasLength(greaterThan(7000)),
    );
  });

  for (final list in CityListKind.values) {
    for (final language in NameLanguage.values) {
      test('${list.name}/${language.name}: every city is found by its own name',
          () {
        final index = catalog.index(list, language);
        final missing = [
          for (final city in index.cities)
            if (!index.lookup(city.name(language) ?? '').contains(city))
              city.nameEn,
        ];
        expect(missing, isEmpty);
      });
    }
  }

  test('every sovereign capital is tier 1, territory capitals are not '
      'boosted', () {
    final world = catalog.index(CityListKind.world, NameLanguage.en);
    final capitals = [for (final c in world.cities) if (c.isCapital) c];
    for (final city in capitals) {
      if (isSovereignCapital(city)) {
        expect(world.tierOf(city), 1, reason: city.nameEn);
      }
    }
    final flyingFishCove = capitals.firstWhere((c) => c.countryCode == 'CX');
    expect(world.tierOf(flyingFishCove), tierCount);
    final vatican = capitals.firstWhere((c) => c.countryCode == 'VA');
    expect(world.tierOf(vatican), 1);
  });

  group('the letter rule on the real lists', () {
    String? after(CityListKind list, NameLanguage language, String name) {
      final index = catalog.index(list, language);
      return index.requiredLetterAfter(index.lookup(name).first);
    }

    const world = CityListKind.world;
    const ukraine = CityListKind.ukraine;
    const uk = NameLanguage.uk;
    const en = NameLanguage.en;

    test("Кам'янець: «ц» in World, but the Ukraine list skips its rare «ц»",
        () {
      // The city is "Кам'янець-Подільський" (→ «к»), so the -ець ending is
      // tested on a real city that ends with it.
      expect(after(world, uk, "Кам'янець-Подільський"), 'к');
      expect(after(world, uk, 'Кременець'), 'ц');
      expect(after(ukraine, uk, 'Кременець'), 'н');
    });

    test('-ький and -ий endings go back to «к»/the consonant', () {
      expect(after(ukraine, uk, 'Хмельницький'), 'к');
      expect(after(world, uk, 'Хмельницький'), 'к');
      expect(after(ukraine, uk, 'Кривий Ріг'), 'г');
    });

    test('«й» and «ї» are skipped in World', () {
      expect(after(world, uk, 'Шанхай'), 'а');
      expect(after(world, uk, 'Мумбаї'), 'а');
    });

    test('«ь» is always skipped', () {
      expect(after(ukraine, uk, 'Ірпінь'), 'н');
      expect(after(world, uk, 'Мелітополь'), 'л');
    });

    test('English', () {
      expect(after(world, en, 'Kyiv'), 'v');
      expect(after(world, en, 'Kraków'), 'w');
      expect(after(ukraine, en, 'Kamianets-Podilskyi'), 'i');
    });

    test('every required letter has cities to answer with', () {
      for (final list in CityListKind.values) {
        for (final language in NameLanguage.values) {
          final index = catalog.index(list, language);
          for (final city in index.cities) {
            final letter = index.requiredLetterAfter(city);
            if (letter == null) continue;
            expect(index.startingWith(letter), isNotEmpty,
                reason: '${list.name}/${language.name} ${city.nameEn}');
          }
        }
      }
    });
  });

  test('no Ukrainian name starts with «ь» or «и»', () {
    // «ь» can't start a word. «и» almost never does in Ukrainian: a name
    // like "Испарта" is a Russian spelling (Ukrainian: Іспарта). «й» is fine
    // (Йокогама). The letter rule skips letters outside this set.
    for (final list in CityListKind.values) {
      final letters = catalog.index(list, NameLanguage.uk).firstLetters;
      expect(letters, isNot(contains('ь')), reason: list.name);
      expect(letters, isNot(contains('и')), reason: list.name);
    }
  });
}
