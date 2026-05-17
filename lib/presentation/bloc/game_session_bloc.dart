import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cities/domain/domain.dart';

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

  // Internal session state
  GameSession? _currentSession;
  int _timerSeconds = 0;
  // Timer management placeholder (Ticker/StreamSubscription)
  // StreamSubscription<int>? _tickerSubscription;

  GameSessionBloc({
    required this.startGameSessionUseCase,
    required this.validateCityAnswerUseCase,
    required this.useHintUseCase,
    required this.reviveSessionUseCase,
    required this.endGameSessionUseCase,
  }) : super(GameSessionInitial()) {
    on<StartSession>(_onStartSession);
    on<ValidateAnswer>(_onValidateAnswer);
    on<UseHint>(_onUseHint);
    on<ReviveSession>(_onReviveSession);
    on<EndSession>(_onEndSession);
    on<TimerTick>(_onTimerTick);
  }

  /// Handles starting a new game session.
  Future<void> _onStartSession(
    StartSession event,
    Emitter<GameSessionState> emit,
  ) async {
    emit(GameSessionLoading());
    try {
      await startGameSessionUseCase(userId: event.userId, mode: event.mode);
      // For demo: create a dummy session (replace with real session retrieval)
      _currentSession = GameSession(
        id: 'session1',
        mode: event.mode,
        language: 'en',
        usedCityIds: [],
        timerSeconds: 60,
        isActive: true,
      );
      _timerSeconds = _currentSession!.timerSeconds;
      emit(GameSessionInProgress());
      // TODO: Start timer (Ticker/StreamSubscription)
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to start session: $e'));
    }
  }

  /// Handles validating a city answer.
  Future<void> _onValidateAnswer(
    ValidateAnswer event,
    Emitter<GameSessionState> emit,
  ) async {
    try {
      final isCorrect = await validateCityAnswerUseCase(
        cityName: event.cityName,
        previousCity: event.previousCity,
        mode: event.mode,
      );
      emit(AnswerValidated(isCorrect: isCorrect));
      // Update session state if needed
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to validate answer: $e'));
    }
  }

  /// Handles using a hint.
  Future<void> _onUseHint(UseHint event, Emitter<GameSessionState> emit) async {
    try {
      final suggestedCity = await useHintUseCase(sessionId: event.sessionId);
      emit(HintUsed(suggestedCity: suggestedCity));
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to use hint: $e'));
    }
  }

  /// Handles reviving a session.
  Future<void> _onReviveSession(
    ReviveSession event,
    Emitter<GameSessionState> emit,
  ) async {
    try {
      await reviveSessionUseCase(sessionId: event.sessionId);
      emit(SessionRevived());
      // Optionally reset timer/session state
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to revive session: $e'));
    }
  }

  /// Handles ending a session.
  Future<void> _onEndSession(
    EndSession event,
    Emitter<GameSessionState> emit,
  ) async {
    try {
      await endGameSessionUseCase(sessionId: event.sessionId);
      emit(GameSessionEnded());
      // TODO: Cancel timer if running
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to end session: $e'));
    }
  }

  /// Handles timer tick events.
  Future<void> _onTimerTick(
    TimerTick event,
    Emitter<GameSessionState> emit,
  ) async {
    _timerSeconds = event.secondsLeft;
    if (_timerSeconds <= 0) {
      emit(GameSessionEnded());
      // TODO: Cancel timer
    } else {
      emit(GameSessionInProgress());
    }
  }
}
