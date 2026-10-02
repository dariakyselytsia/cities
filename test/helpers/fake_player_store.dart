import 'package:cities/data/player_data.dart';
import 'package:cities/data/player_store.dart';

/// An in-memory [PlayerStore] that counts its saves.
class FakePlayerStore implements PlayerStore {
  FakePlayerStore([this._data = const PlayerData()]);

  PlayerData _data;

  /// How many times [update] saved.
  int saves = 0;

  @override
  PlayerData get data => _data;

  @override
  Future<PlayerData> load() async => _data;

  @override
  Future<bool> update(PlayerData Function(PlayerData data) change) async {
    _data = change(_data);
    saves++;
    return true;
  }
}
