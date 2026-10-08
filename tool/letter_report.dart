// Prints, for each list × language, how many names require each letter
// ("demand") and how many cities start with it ("supply"): the numbers
// behind `LetterMinimums` and `trapLetterRatio` (game_design §2.3, T25).
//
//   dart run tool/letter_report.dart
import 'dart:convert';
import 'dart:io';

import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/letter_rule.dart';

void main() {
  final catalog = CityCatalog.fromJson(
    jsonDecode(File('assets/data/cities.json').readAsStringSync()),
  );
  for (final list in CityListKind.values) {
    for (final language in NameLanguage.values) {
      _report(catalog.index(list, language));
    }
  }
}

void _report(CityIndex index) {
  final skipped = index.firstLetters.difference(index.playableLetters);
  stdout
    ..writeln('\n## ${index.list.name} · ${index.language.name}: '
        '${index.cities.length} cities')
    ..writeln('Skipped as rare: ${_letters(skipped)}. '
        'Also skipped on Easy (traps): ${_letters(index.trapLetters)}.')
    ..writeln()
    ..writeln('| Letter | Starters | Easy / Medium / Hard bot knows '
        '| Demand if required | Demand ÷ starters |')
    ..writeln('|---|---|---|---|---|');

  final rows = <(double, String)>[];
  for (final letter in index.firstLetters) {
    // The names that would require [letter] if it were playable, with every
    // other letter as on Medium.
    final playable = {...index.playableLetters, letter};
    final demand = index.cities
        .where(
          (city) =>
              LetterRule.requiredNextLetter(
                city.name(index.language) ?? '',
                playable,
              ) ==
              letter,
        )
        .length;
    final starters = index.startingWith(letter);
    int botKnows(Difficulty difficulty) => starters
        .where((c) => (index.tierOf(c) ?? tierCount) <= difficulty.maxTier)
        .length;
    final ratio = demand / starters.length;
    final status = index.trapLetters.contains(letter)
        ? ' (trap)'
        : skipped.contains(letter)
        ? ' (rare)'
        : '';
    rows.add((
      ratio,
      '| $letter$status | ${starters.length} '
          '| ${Difficulty.values.map(botKnows).join(' / ')} '
          '| $demand | ${ratio.toStringAsFixed(1)} |',
    ));
  }
  rows.sort((a, b) => b.$1.compareTo(a.$1));
  for (final (_, row) in rows) {
    stdout.writeln(row);
  }
}

String _letters(Set<String> letters) =>
    letters.isEmpty ? 'none' : (letters.toList()..sort()).join(' ');
