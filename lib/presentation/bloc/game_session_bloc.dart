import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cities/domain/domain.dart';
import 'dart:async';

/// Events for GameSessionBloc
abstract class GameSessionEvent extends Equatable {
  const GameSessionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a new game session
class StartSession extends GameSessionEvent {
  final String userId;
  final GameMode mode;
  const StartSession({required this.userId, required this.mode});

  @override
  List<Object?> get props => [userId, mode];
}

/// Event to validate a city answer. The BLoC is authoritative over the previous
/// city and mode, so callers only supply the typed answer.
class ValidateAnswer extends GameSessionEvent {
  final String cityName;
  const ValidateAnswer({required this.cityName});

  @override
  List<Object?> get props => [cityName];
}

/// Event to use a hint for the active session.
class UseHint extends GameSessionEvent {
  const UseHint();
}

/// Event to revive a session
class ReviveSession extends GameSessionEvent {
  final String sessionId;
  const ReviveSession({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Event to end the session
class EndSession extends GameSessionEvent {
  final String sessionId;
  const EndSession({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Event for timer tick
class TimerTick extends GameSessionEvent {
  final int secondsLeft;
  const TimerTick({required this.secondsLeft});

  @override
  List<Object?> get props => [secondsLeft];
}

/// States for GameSessionBloc
abstract class GameSessionState extends Equatable {
  const GameSessionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GameSessionInitial extends GameSessionState {
  const GameSessionInitial();
}

/// State when loading (e.g., starting session)
class GameSessionLoading extends GameSessionState {
  const GameSessionLoading();
}

/// State when session is in progress
class GameSessionInProgress extends GameSessionState {
  final GameSession session;
  final int timerSeconds;
  const GameSessionInProgress({
    required this.session,
    required this.timerSeconds,
  });

  @override
  List<Object?> get props => [session, timerSeconds];
}

/// State when an answer is validated, carrying the full outcome (verdict,
/// matched city, and points).
class AnswerValidated extends GameSessionState {
  final ValidationOutcome outcome;
  const AnswerValidated({required this.outcome});

  bool get isCorrect => outcome.isAccepted;

  @override
  List<Object?> get props => [outcome];
}

/// State when a hint is used
class HintUsed extends GameSessionState {
  final String? suggestedCity;
  const HintUsed({this.suggestedCity});

  @override
  List<Object?> get props => [suggestedCity];
}

/// State when session is revived
class SessionRevived extends GameSessionState {
  const SessionRevived();
}

/// State when session ends
class GameSessionEnded extends GameSessionState {
  const GameSessionEnded();
}

/// State for errors/failures, carrying a typed [Failure] from the domain layer.
class GameSessionFailure extends GameSessionState {
  final Failure failure;
  const GameSessionFailure(this.failure);

  /// Developer-facing description. The UI should map [failure] subtypes to
  /// localized copy once localization is wired; this bridges until then.
  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

/// GameSessionBloc manages the full lifecycle and logic of a game session:
/// session start, answer validation, timer, scoring, hints, revive, and end.
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

  /// Last accepted city name — the BLoC is authoritative over the "previous
  /// city" the letter rule is checked against.
  String? _lastAcceptedCityName;

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
    final result = await _guard(
      () => startGameSessionUseCase(userId: event.userId, mode: event.mode),
    );
    switch (result) {
      case Success(:final value):
        _currentSession = value;
        _timerSeconds = value.timerSeconds;
        _lastAcceptedCityName = null;
        emit(
          GameSessionInProgress(session: value, timerSeconds: _timerSeconds),
        );
        _startTimer();
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Validates a city answer and updates session state.
  Future<void> _onValidateAnswer(
    ValidateAnswer event,
    Emitter<GameSessionState> emit,
  ) async {
    final session = _currentSession;
    if (session == null) {
      emit(const GameSessionFailure(NoActiveSessionFailure()));
      return;
    }
    final result = await _guard(
      () => validateCityAnswerUseCase(
        cityName: event.cityName,
        previousCity: _lastAcceptedCityName ?? '',
        mode: session.mode,
        usedCityIds: session.usedCityIds,
      ),
    );
    switch (result) {
      case Success(:final value):
        if (value.isAccepted && value.city != null) {
          final city = value.city!;
          final updated = GameSession(
            id: session.id,
            mode: session.mode,
            language: session.language,
            usedCityIds: [...session.usedCityIds, city.id],
            timerSeconds: _timerSeconds,
            isActive: true,
            score: session.score + value.points,
          );
          _currentSession = updated;
          _lastAcceptedCityName = event.cityName.trim();
          emit(
            GameSessionInProgress(
              session: updated,
              timerSeconds: _timerSeconds,
            ),
          );
        }
        emit(AnswerValidated(outcome: value));
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Uses a hint and emits the suggested city.
  Future<void> _onUseHint(UseHint event, Emitter<GameSessionState> emit) async {
    final session = _currentSession;
    if (session == null) {
      emit(const GameSessionFailure(NoActiveSessionFailure()));
      return;
    }
    final result = await _guard(
      () => useHintUseCase(
        mode: session.mode,
        usedCityIds: session.usedCityIds,
        previousCity: _lastAcceptedCityName ?? '',
      ),
    );
    switch (result) {
      case Success(:final value):
        emit(HintUsed(suggestedCity: value));
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Revives a session and restarts the timer.
  Future<void> _onReviveSession(
    ReviveSession event,
    Emitter<GameSessionState> emit,
  ) async {
    final result = await _guard(
      () => reviveSessionUseCase(sessionId: event.sessionId),
    );
    switch (result) {
      case Success(:final value):
        _currentSession = value;
        _timerSeconds = value.timerSeconds;
        emit(SessionRevived());
        emit(
          GameSessionInProgress(session: value, timerSeconds: _timerSeconds),
        );
        _startTimer();
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Ends the session and cancels the timer.
  Future<void> _onEndSession(
    EndSession event,
    Emitter<GameSessionState> emit,
  ) async {
    await _cancelTimer();
    final result = await _guard(
      () => endGameSessionUseCase(sessionId: event.sessionId),
    );
    switch (result) {
      case Success():
        emit(GameSessionEnded());
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
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
    int secondsLeft = _timerSeconds;
    _timerSub =
        Stream.periodic(
          const Duration(seconds: 1),
          (_) => --secondsLeft,
        ).take(_timerSeconds).listen((s) {
          add(TimerTick(secondsLeft: s));
        });
  }

  /// Cancels the timer subscription.
  Future<void> _cancelTimer() async {
    await _timerSub?.cancel();
    _timerSub = null;
  }

  /// Runs a use-case call and normalizes any *unexpected* thrown error into a
  /// typed [UnknownFailure]. Use cases already return a [Result]; this is
  /// defense-in-depth so an errant throw surfaces as a failure state instead of
  /// crashing the BLoC.
  Future<Result<T>> _guard<T>(Future<Result<T>> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return ResultFailure<T>(const UnknownFailure());
    }
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
