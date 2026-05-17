import 'package:flutter_bloc/flutter_bloc.dart';

/// Events for GameSessionBloc
abstract class GameSessionEvent {}

/// States for GameSessionBloc
abstract class GameSessionState {}

/// BLoC for managing the lifecycle and logic of a game session.
/// Handles session start, answer validation, timer, scoring, hints, revive, and end.
class GameSessionBloc extends Bloc<GameSessionEvent, GameSessionState> {
  GameSessionBloc() : super(GameSessionInitial());
}

class GameSessionInitial extends GameSessionState {}
