import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/player_data.dart';
import '../../data/player_store.dart';

export '../../data/player_data.dart' show PlayerData;

/// The player's progress for Home's stats card and Statistics: the saved
/// [PlayerData], kept current as games end. It lives above the router, so
/// Home shows the new numbers as soon as you return from a game.
class StatsCubit extends Cubit<PlayerData> {
  StatsCubit(PlayerStore store) : super(store.data) {
    _changes = store.changes.listen(emit);
  }

  late final StreamSubscription<PlayerData> _changes;

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
