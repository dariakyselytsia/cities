import 'dart:convert';
import 'dart:isolate';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../engine/city_catalog.dart';

/// Where the city data lives (built by `tool/build_cities.dart`).
const String citiesAssetPath = 'assets/data/cities.json';

/// Why the city data couldn't be loaded.
enum CityLoadFailure {
  /// The asset is missing or unreadable: a broken build.
  missingAsset,

  /// The asset isn't a valid `cities.json`, e.g. a format version this app
  /// doesn't know.
  invalidData,
}

/// The outcome of loading the city data. A failure is a value, never thrown
/// (CLAUDE.md): the app shows a friendly screen instead of crashing.
sealed class CityLoadResult extends Equatable {
  const CityLoadResult();
}

final class CitiesLoaded extends CityLoadResult {
  const CitiesLoaded(this.catalog, this.loadTime);

  final CityCatalog catalog;

  /// From starting the read to having the catalog: the cold-start cost.
  final Duration loadTime;

  @override
  List<Object?> get props => [catalog, loadTime];
}

final class CitiesLoadFailed extends CityLoadResult {
  const CitiesLoadFailed(this.failure);

  final CityLoadFailure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads the bundled city data into a [CityCatalog].
///
/// The JSON is 1.9 MB and indexing it takes a few hundred milliseconds, so
/// decoding and indexing run in a background isolate (`Isolate.run`). The UI
/// keeps animating the splash meanwhile.
class CityLoader {
  /// [bundle] defaults to the app's assets; tests pass a fake.
  CityLoader({AssetBundle? bundle, this.assetPath = citiesAssetPath})
    : _bundle = bundle;

  final AssetBundle? _bundle;
  final String assetPath;

  Future<CityLoadResult> load() async {
    final watch = Stopwatch()..start();

    final String json;
    try {
      // Not cached: it's read once, and caching would keep 1.9 MB alive.
      json = await (_bundle ?? rootBundle).loadString(assetPath, cache: false);
    } on FlutterError catch (error, stack) {
      _report(error, stack);
      return const CitiesLoadFailed(CityLoadFailure.missingAsset);
    }

    try {
      final catalog = await Isolate.run(() => _parse(json));
      final elapsed = watch.elapsed;
      // One line per launch, in release builds too (logcat), so the
      // cold-start cost can be measured on a real device (T10).
      debugPrint(
        'city_loader: ${catalog.cities.length} cities in '
        '${elapsed.inMilliseconds} ms',
      );
      return CitiesLoaded(catalog, elapsed);
    } on FormatException catch (error, stack) {
      _report(error, stack);
      return const CitiesLoadFailed(CityLoadFailure.invalidData);
    }
  }

  /// Keeps the details visible in debug logs and crash reporting, while the
  /// app only ever sees the typed [CityLoadFailure].
  void _report(Object error, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'city_loader',
        context: ErrorDescription('while loading $assetPath'),
        silent: true,
      ),
    );
  }
}

/// Runs in the background isolate. [jsonDecode] throws a [FormatException]
/// for malformed JSON, and [CityCatalog.fromJson] for an unexpected shape.
CityCatalog _parse(String json) => CityCatalog.fromJson(jsonDecode(json));
