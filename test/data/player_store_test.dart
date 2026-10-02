import 'dart:convert';
import 'dart:io';

import 'package:cities/data/player_data.dart';
import 'package:cities/data/player_store.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _played = PlayerData(
  discoveredIds: {703448, 702550},
  records: {GameSetup(): ModeRecord(wins: 1, bestScore: 120)},
  gamesPlayed: 1,
  gamesWon: 1,
  longestChain: 9,
  lastSetup: GameSetup(list: CityListKind.world, difficulty: Difficulty.easy),
  settings: Settings(firstTurn: Side.player),
);

void main() {
  late Directory directory;
  late File file;
  late File backup;

  FilePlayerStore store() => FilePlayerStore(directory: () async => directory);

  setUp(() {
    directory = Directory.systemTemp.createTempSync('player_store_test');
    file = File('${directory.path}/${FilePlayerStore.fileName}');
    backup = File('${directory.path}/${FilePlayerStore.backupName}');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('a missing file is a new player, and nothing is written', () async {
    expect(await store().load(), const PlayerData());
    expect(directory.listSync(), isEmpty);
  });

  test('round-trip: what one launch saves, the next one loads', () async {
    final first = store();
    await first.load();
    expect(await first.update((_) => _played), isTrue);
    expect(first.data, _played);

    final second = store();
    expect(second.data, const PlayerData(), reason: 'before load');
    expect(await second.load(), _played);
    expect(second.data, _played);
  });

  test('the file carries the version, and no temporary file is left', () async {
    await store().update((_) => _played);
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(json['version'], playerDataVersion);
    expect(directory.listSync().map((entry) => entry.uri.pathSegments.last), [
      FilePlayerStore.fileName,
    ]);
  });

  test('a change applies at once, before it is saved', () async {
    final playerStore = store();
    final saved = playerStore.update((data) => data.copyWith(gamesPlayed: 1));
    expect(playerStore.data.gamesPlayed, 1);
    expect(await saved, isTrue);
  });

  test('quick changes from different places all land, in order', () async {
    final playerStore = store();
    await playerStore.load();
    final saves = [
      for (var i = 1; i <= 20; i++)
        playerStore.update(
          (data) => data.copyWith(
            gamesPlayed: i,
            settings: i.isEven
                ? const Settings(firstTurn: Side.player)
                : data.settings,
          ),
        ),
    ];
    expect(await Future.wait(saves), everyElement(isTrue));
    final loaded = await store().load();
    expect(loaded.gamesPlayed, 20);
    expect(loaded.settings.firstTurn, Side.player);
  });

  group('an unreadable file is backed up and reset, and never crashes:', () {
    Future<void> expectReset(List<int> bytes) async {
      file.writeAsBytesSync(bytes);
      final playerStore = store();
      expect(await playerStore.load(), const PlayerData());
      // The original is kept as the backup, and the next save starts over.
      expect(backup.readAsBytesSync(), bytes);
      expect(file.existsSync(), isFalse);
      expect(
        await playerStore.update((data) => data.copyWith(gamesPlayed: 1)),
        isTrue,
      );
      expect((await store().load()).gamesPlayed, 1);
    }

    test(
      'corrupt JSON',
      () => expectReset(utf8.encode('{"version": 1, "disc')),
    );

    test('valid JSON of the wrong shape', () async {
      await expectReset(utf8.encode('{"version": 1, "gamesPlayed": "many"}'));
    });

    test('an unknown version (from a newer app)', () async {
      final json = {..._played.toJson(), 'version': playerDataVersion + 1};
      await expectReset(utf8.encode(jsonEncode(json)));
    });

    test(
      'bytes that are not text',
      () => expectReset([0xff, 0xfe, 0x00, 0x81]),
    );

    test('an empty file', () => expectReset([]));
  });

  test('without a documents directory the app runs on, but can\'t '
      'remember', () async {
    final playerStore = FilePlayerStore(
      directory: () async => throw MissingPluginException('no path_provider'),
    );
    expect(await playerStore.load(), const PlayerData());
    expect(
      await playerStore.update((data) => data.copyWith(gamesPlayed: 1)),
      isFalse,
    );
    expect(playerStore.data.gamesPlayed, 1, reason: 'still held in memory');
  });

  test('a failed save keeps the change in memory, and the next save writes '
      'it', () async {
    final playerStore = store();
    await playerStore.load();
    // A directory where the file should be: the rename fails.
    Directory(file.path).createSync();
    expect(
      await playerStore.update((data) => data.copyWith(gamesPlayed: 1)),
      isFalse,
    );
    expect(playerStore.data.gamesPlayed, 1);

    Directory(file.path).deleteSync();
    expect(
      await playerStore.update((data) => data.copyWith(gamesWon: 1)),
      isTrue,
    );
    final loaded = await store().load();
    expect([loaded.gamesPlayed, loaded.gamesWon], [1, 1]);
  });
}
