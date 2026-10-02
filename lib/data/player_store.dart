import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'player_data.dart';

/// Keeps [PlayerData] between launches (tech_design §6).
///
/// The store holds the current data in memory: it's read once at startup,
/// and every change goes through [update], so several Cubits can change
/// their parts without overwriting each other's. An interface so that tests
/// can use an in-memory fake.
abstract interface class PlayerStore {
  /// The player's data: a new player's until [load] finishes.
  PlayerData get data;

  /// [data] after each [update], so screens showing it (Home's stats card)
  /// stay current.
  Stream<PlayerData> get changes;

  /// Reads the saved data. It never fails: a missing file is a new player,
  /// and an unreadable one is backed up and reset.
  Future<PlayerData> load();

  /// Applies [change] to [data] at once, then saves it. Completes with
  /// whether the save worked; if it didn't, the change still holds in
  /// memory and the next save writes it.
  Future<bool> update(PlayerData Function(PlayerData data) change);
}

/// [PlayerStore] backed by `player_data.json` in the app documents
/// directory.
class FilePlayerStore implements PlayerStore {
  /// [directory] defaults to the app documents directory; tests pass a
  /// temporary one.
  FilePlayerStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  static const fileName = 'player_data.json';

  /// Where an unreadable file goes, so a bug that can't read good data
  /// doesn't destroy it. One backup: the latest replaces the last.
  static const backupName = 'player_data.json.bak';

  final Future<Directory> Function() _directory;

  /// The file, once the directory is known; null if it can't be.
  Future<File?>? _file;

  /// The last write, so writes happen one at a time and in order: an older
  /// write can't land after a newer one.
  Future<bool> _lastWrite = Future.value(true);

  @override
  PlayerData get data => _data;
  PlayerData _data = const PlayerData();

  // Lives as long as the app, like the store, so it's never closed.
  final _changes = StreamController<PlayerData>.broadcast();

  @override
  Stream<PlayerData> get changes => _changes.stream;

  @override
  Future<PlayerData> load() async {
    final file = await _resolveFile();
    if (file == null || !await file.exists()) return _data = const PlayerData();
    try {
      _data = PlayerData.fromJson(jsonDecode(await file.readAsString()));
    } on FormatException catch (error, stack) {
      _report(error, stack, 'reading');
      await _backUp(file);
    } on FileSystemException catch (error, stack) {
      // Unreadable, e.g. not UTF-8: handled like corrupt JSON.
      _report(error, stack, 'reading');
      await _backUp(file);
    }
    return _data;
  }

  @override
  Future<bool> update(PlayerData Function(PlayerData data) change) {
    final data = _data = change(_data);
    _changes.add(data);
    return _lastWrite = _lastWrite.then((_) => _write(data));
  }

  /// Writes to a temporary file, then renames it over the real one. A
  /// rename is atomic, so a crash mid-write leaves the old file whole.
  Future<bool> _write(PlayerData data) async {
    final file = await _resolveFile();
    if (file == null) return false;
    try {
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(data.toJson()), flush: true);
      await temp.rename(file.path);
      return true;
    } on FileSystemException catch (error, stack) {
      _report(error, stack, 'saving');
      return false;
    }
  }

  /// Renames the unreadable file to [backupName]. The player starts over.
  Future<void> _backUp(File file) async {
    try {
      await file.rename('${file.parent.path}/$backupName');
    } on FileSystemException catch (error, stack) {
      _report(error, stack, 'backing up');
    }
  }

  Future<File?> _resolveFile() => _file ??= () async {
    try {
      final directory = await _directory();
      return File('${directory.path}/$fileName');
      // The plugin's errors differ by platform (MissingPluginException,
      // PlatformException, MissingPlatformDirectoryException). Without a
      // directory the app still runs; it just can't remember.
    } on Exception catch (error, stack) {
      _report(error, stack, 'finding the documents directory');
      return null;
    }
  }();

  /// Keeps the details in debug logs; the app only sees the fallback.
  void _report(Object error, StackTrace stack, String doing) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'player_store',
        context: ErrorDescription('while $doing $fileName'),
        silent: true,
      ),
    );
  }
}
