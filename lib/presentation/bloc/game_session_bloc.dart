import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cities/domain/domain.dart';
import 'dart:async';

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
  final GameSession session;
  final int timerSeconds;
  GameSessionInProgress({required this.session, required this.timerSeconds});
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

/// GameSessionBloc manages the full lifecycle and logic of a game session.
/// It exposes all session state, timer, and error handling for the UI.
class GameSessionBloc extends Bloc<GameSessionEvent, GameSessionState> {
  final StartGameSessionUseCase startGameSessionUseCase;
  final ValidateCityAnswerUseCase validateCityAnswerUseCase;
  final UseHintUseCase useHintUseCase;
  final ReviveSessionUseCase reviveSessionUseCase;
  final EndGameSessionUseCase endGameSessionUseCase;

  GameSession? _currentSession;
  int _timerSeconds = 0;
  StreamSubscription<int>? _timerSub;

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

  /// Starts a new game session and timer.
  Future<void> _onStartSession(
    StartSession event,
    Emitter<GameSessionState> emit,
  ) async {
    emit(GameSessionLoading());
    await _cancelTimer();
    try {
      final session = await startGameSessionUseCase(
        userId: event.userId,
        mode: event.mode,
      );
      _currentSession = session;
      _timerSeconds = session.timerSeconds;
      emit(
        GameSessionInProgress(session: session, timerSeconds: _timerSeconds),
      );
      _startTimer();
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to start session: $e'));
    }
  }

  /// Validates a city answer and updates session state.
  Future<void> _onValidateAnswer(
    ValidateAnswer event,
    Emitter<GameSessionState> emit,
  ) async {
    if (_currentSession == null) {
      emit(GameSessionFailure(message: 'No active session.'));
      return;
    }
    try {
      final isCorrect = await validateCityAnswerUseCase(
        cityName: event.cityName,
        previousCity: event.previousCity,
        mode: event.mode,
      );
      if (isCorrect) {
        // Update session state (add city to used list)
        final updated = GameSession(
          id: _currentSession!.id,
          mode: _currentSession!.mode,
          language: _currentSession!.language,
          usedCityIds: List<int>.from(_currentSession!.usedCityIds)
            ..add(event.cityName.hashCode),
          timerSeconds: _timerSeconds,
          isActive: true,
        );
        _currentSession = updated;
        emit(
          GameSessionInProgress(session: updated, timerSeconds: _timerSeconds),
        );
      }
      emit(AnswerValidated(isCorrect: isCorrect));
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to validate answer: $e'));
    }
  }

  /// Uses a hint and emits the suggested city.
  Future<void> _onUseHint(UseHint event, Emitter<GameSessionState> emit) async {
    try {
      final suggestedCity = await useHintUseCase(sessionId: event.sessionId);
      emit(HintUsed(suggestedCity: suggestedCity));
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to use hint: $e'));
    }
  }

  /// Revives a session and restarts the timer.
  Future<void> _onReviveSession(
    ReviveSession event,
    Emitter<GameSessionState> emit,
  ) async {
    try {
      final revivedSession = await reviveSessionUseCase(
        sessionId: event.sessionId,
      );
      _currentSession = revivedSession;
      _timerSeconds = revivedSession.timerSeconds;
      emit(SessionRevived());
      emit(
        GameSessionInProgress(
          session: revivedSession,
          timerSeconds: _timerSeconds,
        ),
      );
      _startTimer();
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to revive session: $e'));
    }
  }

  /// Ends the session and cancels the timer.
  Future<void> _onEndSession(
    EndSession event,
    Emitter<GameSessionState> emit,
  ) async {
    await _cancelTimer();
    try {
      await endGameSessionUseCase(sessionId: event.sessionId);
      emit(GameSessionEnded());
    } catch (e) {
      emit(GameSessionFailure(message: 'Failed to end session: $e'));
    }
  }

  /// Handles timer tick events and session timeout.
  Future<void> _onTimerTick(
    TimerTick event,
    Emitter<GameSessionState> emit,
  ) async {
    _timerSeconds = event.secondsLeft;
    if (_timerSeconds <= 0) {
      await _cancelTimer();
      emit(GameSessionEnded());
    } else if (_currentSession != null) {
      emit(
        GameSessionInProgress(
          session: _currentSession!,
          timerSeconds: _timerSeconds,
        ),
      );
    }
  }

  /// Starts the countdown timer and emits TimerTick events.
  void _startTimer() {
    _timerSub?.cancel();
    _timerSub =
        Stream<int>.periodic(
          const Duration(seconds: 1),
          (x) => _timerSeconds - x - 1,
        ).take(_timerSeconds).listen((secondsLeft) {
          add(TimerTick(secondsLeft: secondsLeft));
        });
  }

  /// Cancels the timer subscription.
  Future<void> _cancelTimer() async {
    await _timerSub?.cancel();
    _timerSub = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
