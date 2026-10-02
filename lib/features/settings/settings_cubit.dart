import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../engine/match.dart';

/// The player's settings. The language isn't here: `easy_localization` owns
/// and saves it.
final class Settings extends Equatable {
  const Settings({this.firstTurn = Side.bot});

  /// Who names the first city (game_design §2.2). CityBot by default.
  final Side firstTurn;

  @override
  List<Object?> get props => [firstTurn];
}

/// Holds [Settings] above the router, so new games pick them up. In memory
/// until T17 saves them.
class SettingsCubit extends Cubit<Settings> {
  SettingsCubit([super.initial = const Settings()]);

  void setFirstTurn(Side side) => emit(Settings(firstTurn: side));
}
