// Builds assets/data/cities.json from GeoNames dumps. See tool/README.md.
//
// Run from the project root:  dart run tool/build_cities.dart
import 'dart:convert';
import 'dart:io';

import 'src/city_builder.dart';
import 'src/districts.dart';

/// World list: every city with population ≥ 15,000.
const String _worldDump = 'cities15000';

/// Ukraine list: Ukrainian cities with population ≥ 5,000. It's fuller than
/// World, because Ukrainian players know smaller towns.
const String _ukraineDump = 'cities5000';

/// Real `uk`/`en` names and aliases (~750 MB unzipped, so it's streamed).
const String _altNamesDump = 'alternateNamesV2';

const String _outPath = 'assets/data/cities.json';

/// Manual fixes on top of GeoNames, keyed by GeoNames id (see tool/README.md).
const String _overridesPath = 'tool/overrides.json';

/// Human review sheet of the most visible cities (T04). UTF-8 with a BOM so
/// Excel shows Cyrillic correctly.
const String _reviewPath = 'tool/review/cities_review.csv';

/// Rows in the review sheet: the World cities the bot and players meet most
/// (≈ tiers 1–2), and the Ukraine top tier.
const int _reviewWorldTop = 1500;
const int _reviewUkraineTop = 150;

/// District candidates are listed for review down to this World rank: about
/// the vocabulary of Hard CityBot (tiers 1–3, game_design §2.5).
const int _reviewDistrictsTop = 5000;

Future<void> main() async {
  final watch = Stopwatch()..start();
  final root = File.fromUri(Platform.script).parent.parent;
  final srcDir = Directory('${root.path}/tool/geonames');

  for (final dump in [_worldDump, _ukraineDump, _altNamesDump]) {
    await _ensureExtracted(srcDir, dump);
  }

  final world = await _readCities(File('${srcDir.path}/$_worldDump.txt'));
  final ukraine = [
    for (final c in await _readCities(File('${srcDir.path}/$_ukraineDump.txt')))
      if (c.countryCode == 'UA') c,
  ];
  final worldIds = {for (final c in world) c.id};
  final byId = {for (final c in [...world, ...ukraine]) c.id: c};

  stdout.writeln('Streaming $_altNamesDump.txt …');
  final alts = await _readAltNames(
    File('${srcDir.path}/$_altNamesDump.txt'),
    byId.keys.toSet(),
  );

  final overrides = await _readOverrides(File('${root.path}/$_overridesPath'));
  final unknownIds = overrides.keys.where((id) => !byId.containsKey(id));
  if (unknownIds.isNotEmpty) {
    stderr.writeln('overrides.json refers to ids not in the city lists: '
        '${unknownIds.join(', ')}');
    exit(1);
  }

  final ids = byId.keys.toList()..sort();
  final records = <Map<String, Object>>[];
  final namesById = <int, CityNames>{};
  final autoExcluded = <String, int>{};
  for (final id in ids) {
    final city = byId[id];
    if (city == null) continue;
    final override = overrides[id];
    if (override?.exclude == true) continue;
    var names = pickNames(city, alts[id] ?? const []);
    if (override != null) names = applyOverride(names, override);
    // Official romanization for Ukrainian cities, unless an override set the
    // English name deliberately.
    if (city.countryCode == 'UA' && override?.en == null) {
      names = withOfficialUkrainianEnglish(names);
    }
    // `"exclude": false` is a reviewed decision to keep the place.
    final districtReason =
        override?.exclude == false ? null : autoDistrictReason(city, names.en);
    if (districtReason != null) {
      autoExcluded.update(districtReason, (n) => n + 1, ifAbsent: () => 1);
      continue;
    }
    namesById[id] = names;
    records.add(cityRecord(city, names, uaOnly: !worldIds.contains(id)));
  }

  final out = File('${root.path}/$_outPath');
  await out.parent.create(recursive: true);
  await out.writeAsString('${jsonEncode({'v': 1, 'cities': records})}\n');

  final kept = namesById.keys.toSet();
  final keptWorld = [for (final c in world) if (kept.contains(c.id)) c];
  final keptUkraine = [for (final c in ukraine) if (kept.contains(c.id)) c];

  // Only undecided places are pending: an `exclude` override of either value
  // is a review decision.
  final candidates = findDistrictCandidates(keptWorld);
  final pendingDistricts = {
    for (final MapEntry(key: id, value: candidate) in candidates.entries)
      if (overrides[id]?.exclude == null) id: candidate,
  };

  await _writeReview(
    File('${root.path}/$_reviewPath'),
    world: keptWorld,
    ukraine: keptUkraine,
    namesById: namesById,
    overridden: overrides.keys.toSet(),
    candidates: candidates,
    pendingDistricts: pendingDistricts,
  );

  _report(
    world: keptWorld,
    ukraine: keptUkraine,
    namesById: namesById,
    overrideCount: overrides.length,
    autoExcluded: autoExcluded,
    pendingDistricts: pendingDistricts,
    outBytes: await out.length(),
    elapsed: watch.elapsed,
  );
}

Future<Map<int, CityOverride>> _readOverrides(File file) async {
  if (!file.existsSync()) return const {};
  try {
    return parseOverrides(jsonDecode(await file.readAsString()));
  } on FormatException catch (e) {
    stderr.writeln('Invalid ${file.path}: ${e.message}');
    exit(1);
  }
}

/// Writes the review sheet: World top-N and Ukraine top-N by population, plus
/// every capital and Ukrainian city still missing a `uk` name, and the
/// district candidates still waiting for a decision (T23).
///
/// The `note` column names the bigger city a district candidate sits next
/// to.
///
/// It is sorted and deterministic, so a diff shows exactly what a GeoNames
/// update or an override changed.
Future<void> _writeReview(
  File file, {
  required List<GeoCity> world,
  required List<GeoCity> ukraine,
  required Map<int, CityNames> namesById,
  required Set<int> overridden,
  required Map<int, DistrictCandidate> candidates,
  required Map<int, DistrictCandidate> pendingDistricts,
}) async {
  int byPopulation(GeoCity a, GeoCity b) {
    final byPop = b.population.compareTo(a.population);
    return byPop != 0 ? byPop : a.id.compareTo(b.id);
  }

  final worldSorted = [...world]..sort(byPopulation);
  final ukraineSorted = [...ukraine]..sort(byPopulation);
  bool missingUk(GeoCity c) => namesById[c.id]?.uk == null;

  final sections = <(String, List<GeoCity>)>[
    ('world_top$_reviewWorldTop', worldSorted.take(_reviewWorldTop).toList()),
    ('ukraine_top$_reviewUkraineTop', ukraineSorted.take(_reviewUkraineTop).toList()),
    ('capital_missing_uk', [for (final c in worldSorted) if (c.isCapital && missingUk(c)) c]),
    ('ukraine_missing_uk', [for (final c in ukraineSorted) if (missingUk(c)) c]),
    (
      'district_candidates',
      [
        for (final c in worldSorted.take(_reviewDistrictsTop))
          if (pendingDistricts.containsKey(c.id)) c,
      ],
    ),
  ];

  String cell(String value) =>
      value.contains(RegExp('[",\n]')) ? '"${value.replaceAll('"', '""')}"' : value;

  final buffer = StringBuffer('﻿')
    ..writeln('section,rank,id,cc,population,capital,uk,en,akaUk,akaEn,status,note');
  for (final (section, cities) in sections) {
    for (final (index, city) in cities.indexed) {
      final names = namesById[city.id];
      if (names == null) continue;
      final status = [
        if (names.uk == null) 'missing_uk',
        if (overridden.contains(city.id)) 'override',
        if (pendingDistricts.containsKey(city.id)) 'district?',
      ].join(' ');
      final candidate = candidates[city.id];
      final note = candidate == null
          ? ''
          : 'near ${candidate.parent.name} (${candidate.distanceKm.round()} km)';
      buffer.writeln([
        section,
        '${index + 1}',
        '${city.id}',
        city.countryCode,
        '${city.population}',
        city.isCapital ? 'yes' : '',
        names.uk ?? '',
        names.en,
        names.akaUk.join(' | '),
        names.akaEn.join(' | '),
        status,
        note,
      ].map(cell).join(','));
    }
  }
  await file.parent.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

/// Unzips `<dump>.zip` when the `.txt` isn't there yet. Uses `tar`, which
/// ships with Windows 10+, macOS and Linux, so the script needs no packages.
Future<void> _ensureExtracted(Directory dir, String dump) async {
  if (File('${dir.path}/$dump.txt').existsSync()) return;
  final zip = File('${dir.path}/$dump.zip');
  if (!zip.existsSync()) {
    stderr.writeln(
      'Missing ${zip.path}.\n'
      'Download https://download.geonames.org/export/dump/$dump.zip '
      'into tool/geonames/ (see tool/README.md).',
    );
    exit(1);
  }
  stdout.writeln('Extracting $dump.zip …');
  final result = await Process.run('tar', ['-xf', zip.path, '-C', dir.path]);
  if (result.exitCode != 0) {
    stderr.writeln('Failed to extract ${zip.path}: ${result.stderr}');
    exit(1);
  }
}

/// Reads a GeoNames cities dump, keeping only playable places (see
/// [excludedFeatureCodes]).
Future<List<GeoCity>> _readCities(File file) async {
  final cities = <GeoCity>[];
  for (final line in await file.readAsLines()) {
    final city = GeoCity.tryParse(line);
    if (city != null && city.isPlayable) cities.add(city);
  }
  return cities;
}

/// Streams the alternate-names dump and keeps only `uk`/`en` rows for [ids].
///
/// The cheap `contains` pre-check skips ~95% of the file's ~16M lines before
/// any splitting, which keeps the pass to well under a minute.
Future<Map<int, List<AltName>>> _readAltNames(File file, Set<int> ids) async {
  final byId = <int, List<AltName>>{};
  final lines = file
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  await for (final line in lines) {
    if (!line.contains('\tuk\t') && !line.contains('\ten\t')) continue;
    final alt = AltName.tryParse(line);
    if (alt == null || !ids.contains(alt.geonameId)) continue;
    if (alt.language != 'uk' && alt.language != 'en') continue;
    (byId[alt.geonameId] ??= []).add(alt);
  }
  return byId;
}

void _report({
  required List<GeoCity> world,
  required List<GeoCity> ukraine,
  required Map<int, CityNames> namesById,
  required int overrideCount,
  required Map<String, int> autoExcluded,
  required Map<int, DistrictCandidate> pendingDistricts,
  required int outBytes,
  required Duration elapsed,
}) {
  bool hasUk(GeoCity c) => namesById[c.id]?.uk != null;
  final worldUk = world.where(hasUk).length;
  final ukraineUk = ukraine.where(hasUk).length;
  final worldIds = {for (final c in world) c.id};
  final uaOnly = ukraine.where((c) => !worldIds.contains(c.id)).length;

  final missingUkCapitals = [
    for (final c in world)
      if (c.isCapital && !hasUk(c)) '${c.name} (${c.countryCode})',
  ];
  final biggestMissingUk = [...world.where((c) => !hasUk(c))]
    ..sort((a, b) => b.population.compareTo(a.population));

  final byPopulation = [...world]
    ..sort((a, b) => b.population.compareTo(a.population));
  int pendingIn(int top) => byPopulation
      .take(top)
      .where((c) => pendingDistricts.containsKey(c.id))
      .length;
  final autoTotal = autoExcluded.values.fold(0, (a, b) => a + b);
  final autoByReason =
      autoExcluded.entries.map((e) => '${e.key} ${e.value}').join(', ');

  stdout
    ..writeln('')
    ..writeln('Wrote $_outPath: ${(outBytes / 1024 / 1024).toStringAsFixed(2)} MB '
        'in ${elapsed.inSeconds}s')
    ..writeln('Overrides applied: $overrideCount · review sheet: $_reviewPath')
    ..writeln('Districts excluded automatically: $autoTotal ($autoByReason)')
    ..writeln('District candidates pending review: '
        'World top $_reviewWorldTop: ${pendingIn(_reviewWorldTop)}, '
        'top $_reviewDistrictsTop: ${pendingIn(_reviewDistrictsTop)}, '
        'all: ${pendingDistricts.length}')
    ..writeln('World:   ${world.length} cities, $worldUk with a Ukrainian name')
    ..writeln('Ukraine: ${ukraine.length} cities ($uaOnly below 15k), '
        '$ukraineUk with a Ukrainian name')
    ..writeln('Capitals without a Ukrainian name (${missingUkCapitals.length}): '
        '${missingUkCapitals.join(', ')}')
    ..writeln('Largest cities without a Ukrainian name: '
        '${biggestMissingUk.take(15).map((c) => '${c.name} (${c.countryCode})').join(', ')}');
}
