import 'package:flutter_bloc/flutter_bloc.dart';

/// Events for GameSessionBloc
abstract class GameSessionEvent {}

/// Event to start a new game session
class StartSession extends GameSessionEvent {
  final String userId;
  final String mode;
  StartSession({required this.userId, required this.mode});
}

/// Event to validate a city answer
class ValidateAnswer extends GameSessionEvent {
  final String cityName;
  final String previousCity;
  final String mode;
  ValidateAnswer({
    required this.cityName,
    required this.previousCity,
    required this.mode,
  });
}

/// Event to use a hint
class UseHint extends GameSessionEvent {
  final String sessionId;
  UseHint({required this.sessionId});
}

/// Event to revive a session
class ReviveSession extends GameSessionEvent {
  final String sessionId;
  ReviveSession({required this.sessionId});
}

/// Event to end the session
class EndSession extends GameSessionEvent {
  final String sessionId;
  EndSession({required this.sessionId});
}

/// Event for timer tick
class TimerTick extends GameSessionEvent {
  final int secondsLeft;
  TimerTick({required this.secondsLeft});
}

/// States for GameSessionBloc
abstract class GameSessionState {}

/// Initial state
class GameSessionInitial extends GameSessionState {}

/// State when loading (e.g., starting session)
class GameSessionLoading extends GameSessionState {}

/// State when session is in progress
class GameSessionInProgress extends GameSessionState {
  // Add session data fields as needed
}

/// State when answer is validated
class AnswerValidated extends GameSessionState {
  final bool isCorrect;
  AnswerValidated({required this.isCorrect});
}

/// State when a hint is used
class HintUsed extends GameSessionState {
  final String? suggestedCity;
  HintUsed({this.suggestedCity});
}

/// State when session is revived
class SessionRevived extends GameSessionState {}

/// State when session ends
class GameSessionEnded extends GameSessionState {}

/// State for errors/failures
class GameSessionFailure extends GameSessionState {
  final String message;
  GameSessionFailure({required this.message});
}

/// BLoC for managing the lifecycle and logic of a game session.
/// Handles session start, answer validation, timer, scoring, hints, revive, and end.
class GameSessionBloc extends Bloc<GameSessionEvent, GameSessionState> {
  final StartGameSessionUseCase startGameSessionUseCase;
  final ValidateCityAnswerUseCase validateCityAnswerUseCase;
  final UseHintUseCase useHintUseCase;
  final ReviveSessionUseCase reviveSessionUseCase;
  final EndGameSessionUseCase endGameSessionUseCase;

  GameSessionBloc({
    required this.startGameSessionUseCase,
    required this.validateCityAnswerUseCase,
    required this.useHintUseCase,
    required this.reviveSessionUseCase,
    required this.endGameSessionUseCase,
  }) : super(GameSessionInitial()) {
    on<StartSession>((event, emit) async {
      emit(GameSessionLoading());
      // TODO: Call startGameSessionUseCase and emit GameSessionInProgress or GameSessionFailure
    });
    on<ValidateAnswer>((event, emit) async {
      // TODO: Call validateCityAnswerUseCase and emit AnswerValidated or GameSessionFailure
    });
    on<UseHint>((event, emit) async {
      // TODO: Call useHintUseCase and emit HintUsed or GameSessionFailure
    });
    on<ReviveSession>((event, emit) async {
      // TODO: Call reviveSessionUseCase and emit SessionRevived or GameSessionFailure
    });
    on<EndSession>((event, emit) async {
      // TODO: Call endGameSessionUseCase and emit GameSessionEnded or GameSessionFailure
    });
    on<TimerTick>((event, emit) async {
      // TODO: Handle timer tick logic and emit updated state
    });
  }
}
