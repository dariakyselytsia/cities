import 'package:bloc_test/bloc_test.dart';
import 'package:cities/features/stats/stats_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_player_store.dart';

void main() {
  test('starts from the saved data', () {
    const saved = PlayerData(gamesPlayed: 3, longestChain: 8);
    expect(StatsCubit(FakePlayerStore(saved)).state, saved);
  });

  late FakePlayerStore store;
  blocTest<StatsCubit, PlayerData>(
    'follows every change to the store',
    setUp: () => store = FakePlayerStore(),
    build: () => StatsCubit(store),
    act: (_) async {
      await store.update((data) => data.copyWith(gamesPlayed: 1));
      await store.update((data) => data.copyWith(longestChain: 5));
    },
    expect: () => const [
      PlayerData(gamesPlayed: 1),
      PlayerData(gamesPlayed: 1, longestChain: 5),
    ],
  );

  test('stops following the store when closed', () async {
    final store = FakePlayerStore();
    final cubit = StatsCubit(store);
    await cubit.close();
    // An emit after close would throw.
    await store.update((data) => data.copyWith(gamesPlayed: 1));
    expect(cubit.state, const PlayerData());
  });
}
