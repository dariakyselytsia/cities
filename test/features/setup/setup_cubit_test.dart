import 'package:bloc_test/bloc_test.dart';
import 'package:cities/data/player_data.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/setup/setup_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_player_store.dart';

void main() {
  test('a new player starts with Ukraine / Medium', () {
    expect(
      SetupCubit(FakePlayerStore()).state,
      const GameSetup(
        list: CityListKind.ukraine,
        difficulty: Difficulty.medium,
      ),
    );
  });

  test('starts from the saved last setup', () {
    const saved = GameSetup(
      list: CityListKind.world,
      difficulty: Difficulty.easy,
    );
    final store = FakePlayerStore(const PlayerData(lastSetup: saved));
    expect(SetupCubit(store).state, saved);
  });

  late FakePlayerStore store;
  blocTest<SetupCubit, GameSetup>(
    'remembers and saves each choice',
    setUp: () => store = FakePlayerStore(),
    build: () => SetupCubit(store),
    act: (cubit) => cubit
      ..selectList(CityListKind.world)
      ..selectDifficulty(Difficulty.hard),
    expect: () => const [
      GameSetup(list: CityListKind.world, difficulty: Difficulty.medium),
      GameSetup(list: CityListKind.world, difficulty: Difficulty.hard),
    ],
    verify: (_) {
      expect(store.saves, 2);
      expect(
        store.data,
        const PlayerData(
          lastSetup: GameSetup(
            list: CityListKind.world,
            difficulty: Difficulty.hard,
          ),
        ),
      );
    },
  );
}
