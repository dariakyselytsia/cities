import 'dart:convert';
import 'dart:io';

import 'package:cities/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every key of a translation file, flattened (`game.rejection.empty`) to
/// its text.
Map<String, String> _flatten(Map<String, Object?> json, [String prefix = '']) =>
    {
      for (final MapEntry(:key, :value) in json.entries)
        ...switch (value) {
          final Map<String, Object?> nested => _flatten(nested, '$prefix$key.'),
          final String text => {'$prefix$key': text},
          _ => throw FormatException('Not a string: $prefix$key'),
        },
    };

Map<String, String> _load(String language) => _flatten(
  jsonDecode(File('assets/translations/$language.json').readAsStringSync())
      as Map<String, Object?>,
);

Set<String> _placeholders(String text) => {
  for (final match in RegExp(r'\{(\w+)\}').allMatches(text)) match.group(1)!,
};

void main() {
  final uk = _load('uk');
  final en = _load('en');

  test('both languages have the same keys', () {
    expect(uk.keys.toSet().difference(en.keys.toSet()), isEmpty);
    expect(en.keys.toSet().difference(uk.keys.toSet()), isEmpty);
  });

  test('no text is empty, and both languages use the same placeholders', () {
    for (final key in uk.keys) {
      expect(uk[key], isNotEmpty, reason: 'uk $key');
      expect(en[key], isNotEmpty, reason: 'en $key');
      expect(
        _placeholders(en[key] ?? ''),
        _placeholders(uk[key] ?? ''),
        reason: key,
      );
    }
  });

  test('every key the code translates exists', () {
    // Literal keys: 'game.win'.tr(). Keys built from enum names
    // ('list.${list.name}') are covered by the screens' tests.
    final literal = RegExp(r"'([a-z_]+(?:\.[a-zA-Z_]+)*)'\.tr\(");
    final missing = <String>[];
    var found = 0;
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      for (final match in literal.allMatches(file.readAsStringSync())) {
        final key = match.group(1)!;
        found++;
        if (!uk.containsKey(key)) missing.add('${file.path}: $key');
      }
    }
    expect(missing, isEmpty);
    expect(found, greaterThan(40), reason: 'the scan finds the keys');
  });

  test('the version shown in About matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version: ([\d.]+)', multiLine: true)
        .firstMatch(pubspec)
        ?.group(1);
    expect(appVersion, version);
  });
}
