import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/player_data.dart';
import '../../data/player_store.dart';
import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';

export '../../data/player_data.dart' show GameSetup;

/// The setup sheet's choice. It lives above the router and starts from the
/// saved last setup, so the sheet opens with the last choice, even after a
/// restart; every change is saved.
class SetupCubit extends Cubit<GameSetup> {
  SetupCubit(this._store) : super(_store.data.lastSetup);

  final PlayerStore _store;

  void selectList(CityListKind list) => _select(state.copyWith(list: list));

  void selectDifficulty(Difficulty difficulty) =>
      _select(state.copyWith(difficulty: difficulty));

  void _select(GameSetup setup) {
    emit(setup);
    unawaited(_store.update((data) => data.copyWith(lastSetup: setup)));
  }
}
