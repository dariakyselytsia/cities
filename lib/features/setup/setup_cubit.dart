import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';

/// What the player picked for the next game (game_design §2.1).
final class GameSetup extends Equatable {
  const GameSetup({
    this.list = CityListKind.ukraine,
    this.difficulty = Difficulty.medium,
  });

  final CityListKind list;
  final Difficulty difficulty;

  GameSetup copyWith({CityListKind? list, Difficulty? difficulty}) => GameSetup(
    list: list ?? this.list,
    difficulty: difficulty ?? this.difficulty,
  );

  @override
  List<Object?> get props => [list, difficulty];
}

/// The setup sheet's choice. It lives above the router, so the sheet opens
/// with the last choice; it's in memory until T17 saves it.
class SetupCubit extends Cubit<GameSetup> {
  SetupCubit([super.initial = const GameSetup()]);

  void selectList(CityListKind list) => emit(state.copyWith(list: list));

  void selectDifficulty(Difficulty difficulty) =>
      emit(state.copyWith(difficulty: difficulty));
}
