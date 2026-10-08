// Plays many seeded games of CityBot against simulated players and prints
// how often each difficulty is won (T20). See tool/README.md.
//
//   dart run tool/simulate.dart [--games 200]
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';

import 'src/simulator.dart';

/// How many cities the simulated players know, per list: a casual player, a
/// keen one and an expert.
const Map<CityListKind, List<int>> playerSizes = {
  CityListKind.ukraine: [30, 100, 300],
  CityListKind.world: [100, 400, 1500],
};

void main(List<String> args) {
  final gamesArg = args.indexOf('--games');
  final games = gamesArg >= 0 ? int.parse(args[gamesArg + 1]) : 200;
  final catalog = CityCatalog.fromJson(
    jsonDecode(File('assets/data/cities.json').readAsStringSync()),
  );
  stdout.writeln('$games games per row; CityBot opens.');
  for (final list in CityListKind.values) {
    for (final language in NameLanguage.values) {
      _report(catalog.index(list, language), games);
    }
  }
}

void _report(CityIndex index, int games) {
  stdout
    ..writeln('\n## ${index.list.name} · ${index.language.name}')
    ..writeln(
      'Bot knows: ${[for (final d in Difficulty.values) _vocabulary(index, d)].join(' / ')} '
      '(Easy / Medium / Hard) of ${index.cities.length}.',
    )
    ..writeln()
    ..writeln(
      '| Difficulty | Player knows | Strategy | Win % | Avg chain '
      '| Avg turns | Wins end on | Losses end on |',
    )
    ..writeln('|---|---|---|---|---|---|---|---|');
  for (final difficulty in Difficulty.values) {
    for (final known in playerSizes[index.list] ?? const <int>[]) {
      for (final strategy in PlayerStrategy.values) {
        final player = SimPlayer(
          index: index,
          bot: CityBot(index: index, difficulty: difficulty, random: Random()),
          known: known,
          strategy: strategy,
        );
        final records = [
          for (var seed = 0; seed < games; seed++)
            simulateGame(player: player, seed: seed),
        ];
        final wins = records.where((r) => r.isWin).toList();
        final losses = records.where((r) => r.outcome?.isWin == false).toList();
        double avg(Iterable<int> values) =>
            values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
        stdout.writeln(
          '| ${difficulty.name} | $known | ${strategy.name} '
          '| ${(100 * wins.length / games).round()} '
          '| ${avg(records.map((r) => r.chain)).toStringAsFixed(1)} '
          '| ${avg(records.map((r) => r.turns)).toStringAsFixed(0)} '
          '| ${_topLetters(wins)} | ${_topLetters(losses)} |',
        );
      }
    }
  }
}

/// How many cities CityBot knows: its tiers and the per-letter minimum.
int _vocabulary(CityIndex index, Difficulty difficulty) => index.cities
    .where(
      CityBot(index: index, difficulty: difficulty, random: Random()).knows,
    )
    .length;

/// The three most common end letters, with their share.
String _topLetters(List<GameRecord> records) {
  if (records.isEmpty) return '—';
  final counts = <String, int>{};
  for (final record in records) {
    final letter = record.endLetter ?? 'any';
    counts[letter] = (counts[letter] ?? 0) + 1;
  }
  final top = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [
    for (final e in top.take(3))
      '${e.key} ${(100 * e.value / records.length).round()}%',
  ].join(', ');
}
