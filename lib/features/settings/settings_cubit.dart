import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/player_data.dart';
import '../../data/player_store.dart';
import '../../engine/match.dart';

export '../../data/player_data.dart' show Settings;

/// Holds [Settings] above the router, so new games pick them up. It starts
/// from the saved settings and saves every change.
class SettingsCubit extends Cubit<Settings> {
  SettingsCubit(this._store) : super(_store.data.settings);

  final PlayerStore _store;

  void setFirstTurn(Side side) {
    emit(Settings(firstTurn: side));
    unawaited(_store.update((data) => data.copyWith(settings: state)));
  }
}
