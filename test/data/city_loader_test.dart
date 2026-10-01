import 'dart:io';

import 'package:cities/data/city_loader.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_list.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';

CityLoader loaderWith(String? json) => CityLoader(
      bundle: FakeAssetBundle({citiesAssetPath: ?json}),
    );

void main() {
  final fixture = File('test/fixtures/cities_fixture.json').readAsStringSync();

  test('loads a catalog from the asset, in a background isolate', () async {
    final result = await loaderWith(fixture).load();

    expect(result, isA<CitiesLoaded>());
    if (result case CitiesLoaded(:final catalog, :final loadTime)) {
      expect(catalog.cities, hasLength(5));
      final ukraine = catalog.index(CityListKind.ukraine, NameLanguage.uk);
      expect(ukraine.lookup('Київ').single.nameEn, 'Kyiv');
      expect(loadTime, greaterThan(Duration.zero));
    }
  });

  test('a missing asset is a missingAsset failure, not a crash', () async {
    expect(
      await loaderWith(null).load(),
      const CitiesLoadFailed(CityLoadFailure.missingAsset),
    );
  });

  for (final (problem, json) in [
    ('malformed JSON', '{"v":1,"cities":['),
    ('an unknown format version', '{"v":2,"cities":[]}'),
    ('a malformed city', '{"v":1,"cities":[{"id":"x"}]}'),
    ('a JSON array', '[1,2,3]'),
  ]) {
    test('$problem is an invalidData failure', () async {
      expect(
        await loaderWith(json).load(),
        const CitiesLoadFailed(CityLoadFailure.invalidData),
      );
    });
  }

  test('loads the real cities.json', () async {
    final real = File('assets/data/cities.json').readAsStringSync();
    final result = await loaderWith(real).load();
    expect(result, isA<CitiesLoaded>());
    if (result case CitiesLoaded(:final catalog)) {
      expect(catalog.cities, hasLength(greaterThan(30000)));
    }
  });
}
