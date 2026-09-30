import 'dart:convert';

import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:flutter_test/flutter_test.dart';

/// A small `cities.json`. Populations are chosen so that, with [limits],
/// cities land exactly on the tier boundaries.
const _fixture = '''
{"v":1,"cities":[
 {"id":1,"uk":"Київ","en":"Kyiv","cc":"UA","cap":true,"pop":2952301,"akaEn":["Kiev"]},
 {"id":2,"uk":"Харків","en":"Kharkiv","cc":"UA","pop":1421125},
 {"id":3,"uk":"Одеса","en":"Odesa","cc":"UA","pop":1010537,"akaEn":["Odessa"]},
 {"id":4,"uk":"Львів","en":"Lviv","cc":"UA","pop":717273,"akaUk":["Лемберг"],"akaEn":["Lemberg","Lvov"]},
 {"id":5,"uk":"Кам'янець-Подільський","en":"Kamianets-Podilskyi","cc":"UA","pop":100462},
 {"id":6,"uk":"Вільне","en":"Vilne","cc":"UA","pop":6000,"uaOnly":true},
 {"id":10,"uk":"Мумбаї","en":"Mumbai","cc":"IN","pop":12442373,"akaUk":["Бомбей"],"akaEn":["Bombay"]},
 {"id":11,"uk":"Париж","en":"Paris","cc":"FR","cap":true,"pop":2138551},
 {"id":12,"en":"Paris","cc":"US","pop":25171},
 {"id":13,"uk":"Вікторія","en":"Victoria","cc":"CA","pop":91867},
 {"id":14,"uk":"Вікторія","en":"Victoria","cc":"SC","cap":true,"pop":22881},
 {"id":15,"en":"6th of October City","cc":"EG","pop":50000},
 {"id":16,"uk":"Флаїнг-Фіш-Коув","en":"Flying Fish Cove","cc":"CX","cap":true,"pop":1355},
 {"id":17,"uk":"Гданськ","en":"Gdańsk","cc":"PL","pop":461865}
]}
''';

/// Ukraine: ranks 1–2 → T1, 3–4 → T2, 5 → T3, the rest T4.
/// World: ranks 1–3 → T1, 4–6 → T2, 7–9 → T3, the rest T4.
const limits = TierLimits(ukraine: [2, 4, 5], world: [3, 6, 9]);

void main() {
  final json = jsonDecode(_fixture);
  final catalog = CityCatalog([
    for (final city in CityCatalog.fromJson(json).cities) city,
  ], tierLimits: limits);

  List<int> ids(List<City> cities) => [for (final c in cities) c.id];
  City byId(int id) => catalog.cities.firstWhere((c) => c.id == id);

  group('fromJson', () {
    test('reads every city', () {
      expect(CityCatalog.fromJson(json).cities, hasLength(14));
    });

    test('rejects other format versions and malformed documents', () {
      for (final bad in <Object?>[
        {'v': 2, 'cities': <Object?>[]},
        {'v': 1},
        {'v': 1, 'cities': 'none'},
        {'v': 1, 'cities': [1, 2]},
        [1, 2],
        null,
      ]) {
        expect(() => CityCatalog.fromJson(bad), throwsFormatException,
            reason: '$bad');
      }
    });

    test('rejects a duplicate id', () {
      expect(
        () => CityCatalog.fromJson({
          'v': 1,
          'cities': [
            {'id': 1, 'en': 'A', 'cc': 'UA', 'pop': 1},
            {'id': 1, 'en': 'B', 'cc': 'UA', 'pop': 2},
          ],
        }),
        throwsFormatException,
      );
    });
  });

  group('lists', () {
    test('Ukraine is every UA city, including the small towns', () {
      final index = catalog.index(CityListKind.ukraine, NameLanguage.en);
      expect(ids(index.cities).toSet(), {1, 2, 3, 4, 5, 6});
    });

    test('World is every city except the Ukraine-only towns', () {
      final index = catalog.index(CityListKind.world, NameLanguage.en);
      expect(index.cities, hasLength(13));
      expect(ids(index.cities), isNot(contains(6)));
    });

    test('a city without a Ukrainian name is not playable in Ukrainian', () {
      final index = catalog.index(CityListKind.world, NameLanguage.uk);
      expect(ids(index.cities), isNot(contains(12)));
      expect(ids(index.cities), isNot(contains(15)));
      expect(index.cities, hasLength(11));
    });
  });

  group('lookup', () {
    final worldUk = catalog.index(CityListKind.world, NameLanguage.uk);
    final worldEn = catalog.index(CityListKind.world, NameLanguage.en);

    test('finds a city by its display name, normalized', () {
      expect(ids(worldUk.lookup('  київ ')), [1]);
      expect(ids(worldUk.lookup('Камянець подільський')), [5]);
      expect(ids(worldEn.lookup('gdansk')), [17]);
    });

    test('finds a city by an alias, in the same language', () {
      expect(ids(worldEn.lookup('Kiev')), [1]);
      expect(ids(worldEn.lookup('Bombay')), [10]);
      expect(ids(worldEn.lookup('lemberg')), [4]);
      expect(ids(worldUk.lookup('Бомбей')), [10]);
      expect(ids(worldUk.lookup('Лемберг')), [4]);
    });

    test('matches only names in the index language', () {
      expect(worldUk.lookup('Kyiv'), isEmpty);
      expect(worldEn.lookup('Київ'), isEmpty);
    });

    test('same-named cities come most populous first', () {
      expect(ids(worldEn.lookup('Paris')), [11, 12]);
      // By population, not by tier: the Seychelles capital is tier 1 but
      // smaller than Victoria, Canada.
      expect(ids(worldUk.lookup('Вікторія')), [13, 14]);
    });

    test('only lists cities in the index list', () {
      final ukraineEn = catalog.index(CityListKind.ukraine, NameLanguage.en);
      expect(ukraineEn.lookup('Paris'), isEmpty);
      expect(worldEn.lookup('Vilne'), isEmpty, reason: 'Ukraine-only');
    });

    test('an unknown name finds nothing', () {
      expect(worldEn.lookup('Atlantis'), isEmpty);
      expect(worldEn.lookup(''), isEmpty);
    });
  });

  group('tiers', () {
    final ukraine = catalog.index(CityListKind.ukraine, NameLanguage.uk);
    final world = catalog.index(CityListKind.world, NameLanguage.en);

    test('follow population rank within the list, at the exact limits', () {
      // Ukraine: Київ, Харків | Одеса, Львів | Кам'янець | Вільне
      expect([for (final id in [1, 2, 3, 4, 5, 6]) ukraine.tierOf(byId(id))],
          [1, 1, 2, 2, 3, 4]);
      // World: Mumbai, Kyiv, Paris | Kharkiv, Odesa, Lviv |
      // Gdańsk, Kamianets, Victoria CA | 6th of October, Paris US, …
      expect(
        [for (final id in [10, 1, 11, 2, 3, 4, 17, 5, 13, 15, 12]) world.tierOf(byId(id))],
        [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4],
      );
    });

    test('the same city can have different tiers in different lists', () {
      expect(ukraine.tierOf(byId(2)), 1);
      expect(world.tierOf(byId(2)), 2);
    });

    test('sovereign capitals are forced into tier 1', () {
      // Victoria, Seychelles: ranked 12th of 13 by population.
      expect(world.tierOf(byId(14)), 1);
    });

    test('territory capitals are not', () {
      // Flying Fish Cove, Christmas Island (Australia): smallest in the list.
      expect(isSovereignCapital(byId(16)), isFalse);
      expect(world.tierOf(byId(16)), 4);
    });

    test('are the same in both languages', () {
      final worldUk = catalog.index(CityListKind.world, NameLanguage.uk);
      for (final city in worldUk.cities) {
        expect(worldUk.tierOf(city), world.tierOf(city), reason: city.nameEn);
      }
    });

    test('are null for a city outside the index', () {
      expect(world.tierOf(byId(6)), isNull, reason: 'Ukraine-only town');
      final worldUk = catalog.index(CityListKind.world, NameLanguage.uk);
      expect(worldUk.tierOf(byId(12)), isNull, reason: 'no Ukrainian name');
    });

    test('limits must be ascending, positive, one per tier boundary', () {
      for (final bad in [
        const TierLimits(ukraine: [2, 2, 5], world: [3, 6, 9]),
        const TierLimits(ukraine: [0, 4, 5], world: [3, 6, 9]),
        const TierLimits(ukraine: [2, 4, 5], world: [3, 6]),
      ]) {
        expect(() => CityCatalog(catalog.cities, tierLimits: bad),
            throwsArgumentError);
      }
    });
  });

  group('letters', () {
    final worldUk = catalog.index(CityListKind.world, NameLanguage.uk);
    final worldEn = catalog.index(CityListKind.world, NameLanguage.en);

    test('startingWith lists cities best known first: tier, then population', () {
      expect(ids(worldUk.startingWith('к')), [1, 5]);
      // Victoria, Seychelles (tier 1) before Victoria, Canada (tier 3).
      expect(ids(worldUk.startingWith('в')), [14, 13]);
      expect(ids(worldEn.startingWith('p')), [11, 12]);
    });

    test('uses the display name, not aliases', () {
      // Mumbai is also "Bombay", but it starts with «м».
      expect(ids(worldUk.startingWith('б')), isEmpty);
      expect(ids(worldUk.startingWith('м')), [10]);
    });

    test('normalizes the letter it is given', () {
      expect(ids(worldUk.startingWith('К')), [1, 5]);
      expect(ids(worldUk.startingWith('ґ')), [17], reason: 'ґ → г');
    });

    test('firstLetters is the set of letters some city starts with', () {
      expect(worldUk.firstLetters, {'к', 'х', 'о', 'л', 'м', 'п', 'в', 'ф', 'г'});
      // "6th of October City" starts with a digit: it can be named, but no
      // letter leads to it.
      expect(worldEn.firstLetters, isNot(contains('6')));
      expect(ids(worldEn.lookup('6th of October City')), [15]);
    });
  });
}
