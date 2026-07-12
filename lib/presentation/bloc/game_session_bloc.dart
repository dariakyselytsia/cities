import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cities/domain/domain.dart';
import 'dart:async';

/// A single line in the game's chat history: a city [text] named by either the
/// player or CityBot. [isBot] drives the left/right bubble alignment in the UI.
class ChatMessage extends Equatable {
  final String text;
  final bool isBot;

  const ChatMessage({required this.text, required this.isBot});

  @override
  List<Object?> get props => [text, isBot];
}

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

  /// Display/matching language for the round (the app locale) — independent of
  /// [mode], so e.g. the World list can be played with Ukrainian names.
  final AppLanguage language;

  const StartSession({
    required this.userId,
    required this.mode,
    required this.language,
  });

  @override
  List<Object?> get props => [userId, mode, language];
}

/// Event to validate a city answer. The BLoC is authoritative over the previous
/// city and mode, so callers only supply the typed answer.
class ValidateAnswer extends GameSessionEvent {
  final String cityName;
  const ValidateAnswer({required this.cityName});

  @override
  List<Object?> get props => [cityName];
}

/// Internal event: CityBot takes its turn — the opening move, or a reply to the
/// player's last accepted city. The BLoC dispatches this to itself so an
/// opponent turn is a discrete, swappable step (the seam a future PvP "network
/// turn" would slot into; see game_design.md roadmap).
class BotTurn extends GameSessionEvent {
  const BotTurn();
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

/// State when loading (e.g., starting session, or while CityBot opens the game)
class GameSessionLoading extends GameSessionState {
  const GameSessionLoading();
}

/// The single in-progress "board" state and source of truth while a session is
/// active. It carries the last answer verdict and the last hint inline instead
/// of emitting separate transient states that would replace the board in the
/// UI (and strand the player with no way back to it).
class GameSessionInProgress extends GameSessionState {
  final GameSession session;
  final int timerSeconds;

  /// The player's persisted lifetime best for this session's mode, shown under
  /// CityBot's name. 0 until any session has been recorded.
  final int highScore;

  /// The volley of cities named this session, in play order — the chat history
  /// the game screen renders (player and CityBot bubbles).
  final List<ChatMessage> history;

  /// The letter the player's next city must start with (uppercase), or null on
  /// the opening move. Sourced from the last city on the board (CityBot's reply
  /// or the player's accepted answer) and preserved across rejected attempts.
  final String? requiredLetter;

  /// The most recent answer verdict (accepted/rejected, with points and matched
  /// city), or null before the first answer this session.
  final ValidationOutcome? lastOutcome;

  /// The most recent hint suggestion currently shown, or null when none.
  final String? hint;

  const GameSessionInProgress({
    required this.session,
    required this.timerSeconds,
    this.highScore = 0,
    this.history = const [],
    this.requiredLetter,
    this.lastOutcome,
    this.hint,
  });

  /// Convenience: whether the last answer was accepted.
  bool get lastAnswerCorrect => lastOutcome?.isAccepted ?? false;

  @override
  List<Object?> get props => [
    session,
    timerSeconds,
    highScore,
    history,
    requiredLetter,
    lastOutcome,
    hint,
  ];
}

/// State when session is revived
class SessionRevived extends GameSessionState {
  const SessionRevived();
}

/// State when the session ends (timeout, surrender, or an exhausted pool),
/// carrying the final score.
class GameSessionEnded extends GameSessionState {
  final int score;
  const GameSessionEnded({this.score = 0});

  @override
  List<Object?> get props => [score];
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

/// GameSessionBloc manages the full lifecycle and logic of a Player-vs-CityBot
/// session: start, CityBot's turns, answer validation, the per-turn timer,
/// scoring, hints, revive, and end. Turns alternate — CityBot opens, then each
/// accepted player answer triggers a [BotTurn] reply — and the shared used-city
/// set means neither side may repeat a city (game_design.md §2).
class GameSessionBloc extends Bloc<GameSessionEvent, GameSessionState> {
  final StartGameSessionUseCase startGameSessionUseCase;
  final ValidateCityAnswerUseCase validateCityAnswerUseCase;
  final GetBotCityUseCase getBotCityUseCase;
  final UseHintUseCase useHintUseCase;
  final ReviveSessionUseCase reviveSessionUseCase;
  final EndGameSessionUseCase endGameSessionUseCase;
  final GetUserStatsUseCase getUserStatsUseCase;
  final RecordSessionResultUseCase recordSessionResultUseCase;

  GameSession? _currentSession;

  /// Snapshot of the player's lifetime used-city ids, loaded once at session
  /// start. Passed into validation to award the absolute-new-city bonus (a city
  /// absent from this set is "new to the player"). Null when lifetime history
  /// couldn't be loaded — the bonus stays off rather than being over-awarded.
  Set<int>? _historicCityIds;

  /// The player's lifetime best for the current session's mode (shown in the
  /// header). Loaded at session start; 0 when nothing is persisted yet.
  int _historicHighScore = 0;

  /// Ids of the cities the *player* has named this session (excludes CityBot's).
  /// Recorded into lifetime stats when the session ends; its length is the
  /// session streak.
  final List<int> _playerCityIds = [];

  /// Seconds remaining in the current player turn.
  int _timerSeconds = 0;

  /// The per-turn time budget; the countdown resets to this at the start of each
  /// player turn (after CityBot replies). game_design.md §2: "resets every turn".
  int _turnDuration = 0;

  StreamSubscription<int>? _timerSub;

  /// The last city on the board — named by the player *or* CityBot. The next
  /// answer's letter rule is checked against this, so the chain runs across both
  /// sides.
  String? _lastCityName;

  /// Last answer verdict and last hint, carried on every [GameSessionInProgress]
  /// emission so the board remains the single source of truth. A new user action
  /// (answer / hint) replaces them; a timer tick preserves them.
  ValidationOutcome? _lastOutcome;
  String? _lastHint;

  /// Cities named this session, in play order (the chat history).
  final List<ChatMessage> _history = [];

  /// Letter the player's next city must start with (uppercase); null on the
  /// opening move.
  String? _requiredLetter;

  GameSessionBloc({
    required this.startGameSessionUseCase,
    required this.validateCityAnswerUseCase,
    required this.getBotCityUseCase,
    required this.useHintUseCase,
    required this.reviveSessionUseCase,
    required this.endGameSessionUseCase,
    required this.getUserStatsUseCase,
    required this.recordSessionResultUseCase,
  }) : super(GameSessionInitial()) {
    on<StartSession>(_onStartSession);
    on<ValidateAnswer>(_onValidateAnswer);
    on<BotTurn>(_onBotTurn);
    on<UseHint>(_onUseHint);
    on<ReviveSession>(_onReviveSession);
    on<EndSession>(_onEndSession);
    on<TimerTick>(_onTimerTick);
  }

  /// Starts a new game session, then lets CityBot make the opening move (which
  /// emits the first board and starts the player's timer).
  Future<void> _onStartSession(
    StartSession event,
    Emitter<GameSessionState> emit,
  ) async {
    emit(GameSessionLoading());
    await _cancelTimer();
    final result = await _guard(
      () => startGameSessionUseCase(
        userId: event.userId,
        mode: event.mode,
        language: event.language,
      ),
    );
    switch (result) {
      case Success(:final value):
        _currentSession = value;
        _turnDuration = value.timerSeconds;
        _timerSeconds = value.timerSeconds;
        _lastCityName = null;
        _lastOutcome = null;
        _lastHint = null;
        _requiredLetter = null;
        _history.clear();
        _playerCityIds.clear();
        await _loadLifetimeStats(value.mode);
        // CityBot opens the game; that emission shows the first board.
        add(const BotTurn());
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Loads the player's lifetime stats to seed the absolute-new-city bonus and
  /// the header's best-score, for the [mode] being played. A failure here is
  /// non-fatal: the game still runs, just without the bonus (history stays null)
  /// and with a 0 best.
  Future<void> _loadLifetimeStats(GameMode mode) async {
    _historicCityIds = null;
    _historicHighScore = 0;
    final result = await _guard(() => getUserStatsUseCase());
    if (result case Success(:final value)) {
      _historicCityIds = value.usedCityIds.toSet();
      _historicHighScore =
          mode.isUkraine ? value.highScoreUA : value.highScoreWorld;
    }
  }

  /// CityBot's turn: pick a valid unused city answering the last city on the
  /// board (any unused city on the opening move), append it to the chat, set the
  /// letter the player must now answer, and reset + restart the player's timer.
  /// An exhausted pool (no valid city) ends the round.
  Future<void> _onBotTurn(BotTurn event, Emitter<GameSessionState> emit) async {
    final session = _currentSession;
    if (session == null) return;
    // Suspend the countdown while the bot moves so a tick can't race the reply.
    await _cancelTimer();
    final result = await _guard(
      () => getBotCityUseCase(
        mode: session.mode,
        language: session.language,
        usedCityIds: session.usedCityIds,
        previousCity: _lastCityName ?? '',
      ),
    );
    switch (result) {
      case Success(:final value):
        if (value == null) {
          // CityBot has no valid city (exhausted pool) — the round ends.
          await _finishSession(emit);
          return;
        }
        final city = value.city;
        final name = session.language.isUkrainian ? city.nameUA : city.nameEN;
        _timerSeconds = _turnDuration; // fresh countdown for the player's turn
        _currentSession = GameSession(
          id: session.id,
          mode: session.mode,
          language: session.language,
          usedCityIds: [...session.usedCityIds, city.id],
          timerSeconds: _timerSeconds,
          isActive: true,
          score: session.score,
        );
        _lastCityName = name;
        _history.add(ChatMessage(text: name, isBot: true));
        _requiredLetter = value.nextLetter;
        _lastHint = null;
        _emitInProgress(emit);
        _startTimer();
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Validates a city answer against CityBot's last city and, when accepted,
  /// scores it and triggers CityBot's reply.
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
        previousCity: _lastCityName ?? '',
        mode: session.mode,
        language: session.language,
        usedCityIds: session.usedCityIds,
        historicUsedCityIds: _historicCityIds,
      ),
    );
    switch (result) {
      case Success(:final value):
        _lastOutcome = value;
        _lastHint = null;
        if (value.isAccepted && value.city != null) {
          final city = value.city!;
          final name = session.language.isUkrainian ? city.nameUA : city.nameEN;
          _currentSession = GameSession(
            id: session.id,
            mode: session.mode,
            language: session.language,
            usedCityIds: [...session.usedCityIds, city.id],
            timerSeconds: _timerSeconds,
            isActive: true,
            score: session.score + value.points,
          );
          // Store the canonical city name so the letter chain and chat use the
          // dataset spelling, not the player's raw input.
          _lastCityName = name;
          _playerCityIds.add(city.id); // recorded into lifetime stats at end
          _history.add(ChatMessage(text: name, isBot: false));
          _requiredLetter = value.nextLetter;
          _emitInProgress(emit); // show the player's accepted bubble…
          add(const BotTurn()); // …then CityBot replies.
        } else {
          // Rejected: same turn, timer keeps running; show the verdict inline.
          _emitInProgress(emit);
        }
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Uses a hint and emits the suggested city (a city answering CityBot's last).
  Future<void> _onUseHint(UseHint event, Emitter<GameSessionState> emit) async {
    final session = _currentSession;
    if (session == null) {
      emit(const GameSessionFailure(NoActiveSessionFailure()));
      return;
    }
    final result = await _guard(
      () => useHintUseCase(
        mode: session.mode,
        language: session.language,
        usedCityIds: session.usedCityIds,
        previousCity: _lastCityName ?? '',
      ),
    );
    switch (result) {
      case Success(:final value):
        _lastHint = value;
        _lastOutcome = null;
        _emitInProgress(emit);
      case ResultFailure(:final failure):
        emit(GameSessionFailure(failure));
    }
  }

  /// Revives a session and restarts the timer, continuing the same chain.
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
        _turnDuration = value.timerSeconds;
        _timerSeconds = value.timerSeconds;
        _lastOutcome = null;
        _lastHint = null;
        emit(SessionRevived());
        _emitInProgress(emit);
        _startTimer();
      // NOTE: history and the letter chain are preserved across a revive.
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
        await _finishSession(emit);
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
      await _finishSession(emit);
    } else if (_currentSession != null) {
      // Preserve the last verdict/hint across ticks — the board is unchanged.
      _emitInProgress(emit);
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

  /// Ends the round: records this session into lifetime stats (best-effort — a
  /// persistence failure must not block the game-over screen), then emits
  /// [GameSessionEnded] with the final score. All three end paths (timeout,
  /// surrender, exhausted pool) funnel through here.
  Future<void> _finishSession(Emitter<GameSessionState> emit) async {
    final session = _currentSession;
    final score = session?.score ?? 0;
    if (session != null) {
      await _guard(
        () => recordSessionResultUseCase(
          sessionId: session.id,
          mode: session.mode,
          score: score,
          playerCityIds: List<int>.of(_playerCityIds),
          // Total session duration isn't tracked yet (only the per-turn timer);
          // recorded as 0 until an elapsed-time counter is wired.
          durationSeconds: 0,
        ),
      );
    }
    emit(GameSessionEnded(score: score));
  }

  /// Emits the current board state from the BLoC's own fields, so every
  /// in-progress emission (answer, bot turn, hint, timer tick) is built the same
  /// way and carries the latest verdict/hint. No-op if there is no active
  /// session.
  void _emitInProgress(Emitter<GameSessionState> emit) {
    final session = _currentSession;
    if (session == null) return;
    emit(
      GameSessionInProgress(
        session: session,
        timerSeconds: _timerSeconds,
        highScore: _historicHighScore,
        history: List<ChatMessage>.of(_history),
        requiredLetter: _requiredLetter,
        lastOutcome: _lastOutcome,
        hint: _lastHint,
      ),
    );
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
