// Builds assets/data/cities.json from GeoNames dumps. See tool/README.md.
//
// Run from the project root:  dart run tool/build_cities.dart
import 'dart:convert';
import 'dart:io';

import 'src/city_builder.dart';

/// World list: every city with population ≥ 15,000.
const String _worldDump = 'cities15000';

/// Ukraine list: Ukrainian cities with population ≥ 5,000. It's fuller than
/// World, because Ukrainian players know smaller towns.
const String _ukraineDump = 'cities5000';

/// Real `uk`/`en` names and aliases (~750 MB unzipped, so it's streamed).
const String _altNamesDump = 'alternateNamesV2';

const String _outPath = 'assets/data/cities.json';

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

  final ids = byId.keys.toList()..sort();
  final records = <Map<String, Object>>[];
  final namesById = <int, CityNames>{};
  for (final id in ids) {
    final city = byId[id];
    if (city == null) continue;
    final names = pickNames(city, alts[id] ?? const []);
    namesById[id] = names;
    records.add(cityRecord(city, names, uaOnly: !worldIds.contains(id)));
  }

  final out = File('${root.path}/$_outPath');
  await out.parent.create(recursive: true);
  await out.writeAsString('${jsonEncode({'v': 1, 'cities': records})}\n');

  _report(
    world: world,
    ukraine: ukraine,
    namesById: namesById,
    outBytes: await out.length(),
    elapsed: watch.elapsed,
  );
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

  stdout
    ..writeln('')
    ..writeln('Wrote $_outPath: ${(outBytes / 1024 / 1024).toStringAsFixed(2)} MB '
        'in ${elapsed.inSeconds}s')
    ..writeln('World:   ${world.length} cities, $worldUk with a Ukrainian name')
    ..writeln('Ukraine: ${ukraine.length} cities ($uaOnly below 15k), '
        '$ukraineUk with a Ukrainian name')
    ..writeln('Capitals without a Ukrainian name (${missingUkCapitals.length}): '
        '${missingUkCapitals.join(', ')}')
    ..writeln('Largest cities without a Ukrainian name: '
        '${biggestMissingUk.take(15).map((c) => '${c.name} (${c.countryCode})').join(', ')}');
}
