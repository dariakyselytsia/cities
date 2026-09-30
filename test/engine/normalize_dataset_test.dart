import 'dart:convert';
import 'dart:io';

import 'package:cities/engine/city.dart';
import 'package:cities/engine/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the fold table against the real data: every name in
/// `assets/data/cities.json` must normalize to plain letters of its language.
/// A new accented letter from a GeoNames update, or a non-Ukrainian letter in
/// a `uk` name, fails here instead of silently becoming unmatchable.
void main() {
  final json = jsonDecode(File('assets/data/cities.json').readAsStringSync());
  final cities = switch (json) {
    {'cities': final List<Object?> list} => [
      for (final entry in list) City.fromJson(entry as Map<String, Object?>),
    ],
    _ => throw const FormatException('cities.json has no "cities" list'),
  };

  RegExp alphabet(NameLanguage language) => switch (language) {
    NameLanguage.en => RegExp(r'^[a-z0-9]+( [a-z0-9]+)*$'),
    // The Ukrainian alphabet, minus ґ (folded to г).
    NameLanguage.uk => RegExp(r'^[а-щьюяєії]+( [а-щьюяєії]+)*$'),
  };

  test('the dataset parses', () {
    expect(cities, hasLength(greaterThan(30000)));
  });

  for (final language in NameLanguage.values) {
    test('every ${language.name} name normalizes to plain letters', () {
      final pattern = alphabet(language);
      final bad = [
        for (final city in cities)
          for (final name in [?city.name(language), ...city.aliases(language)])
            if (!pattern.hasMatch(normalizeName(name)))
              '${city.id} "$name" → "${normalizeName(name)}"',
      ];
      expect(bad, isEmpty);
    });
  }
}
