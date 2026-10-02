import 'package:bloc_test/bloc_test.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/setup/setup_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with Ukraine / Medium', () {
    expect(
      SetupCubit().state,
      const GameSetup(
        list: CityListKind.ukraine,
        difficulty: Difficulty.medium,
      ),
    );
  });

  blocTest<SetupCubit, GameSetup>(
    'remembers each choice',
    build: SetupCubit.new,
    act: (cubit) => cubit
      ..selectList(CityListKind.world)
      ..selectDifficulty(Difficulty.hard),
    expect: () => const [
      GameSetup(list: CityListKind.world, difficulty: Difficulty.medium),
      GameSetup(list: CityListKind.world, difficulty: Difficulty.hard),
    ],
  );
}
