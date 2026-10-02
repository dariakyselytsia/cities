import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/player_data.dart';
import '../../data/player_store.dart';
import '../../engine/bot.dart';
import '../../engine/letter_rule.dart';
import '../../engine/match.dart';
import 'game_state.dart';

/// Runs one game: it wraps a [Match] (the rules) and adds time and flow
/// (tech_design §3):
/// - CityBot "thinks" for [botThinkingTime] before each move;
/// - the player's countdown runs on their turn, starting from the
///   difficulty's turn time. A wrong answer doesn't reset it, and when it
///   hits zero the player loses;
/// - hints, giving up, and the end of the game, whose result is saved to
///   the [PlayerStore] however it ended.
///
/// Player actions that come at the wrong moment (a double tap while the bot
/// thinks, a tap after the game ended) are ignored: they are UI races, not
/// errors.
class GameCubit extends Cubit<GameState> {
  /// [createMatch] builds a fresh game for [start], with the setup the
  /// player chose (list, difficulty, who starts) and the cities discovered
  /// so far, read from [store] at each start, so "Play again" scores a city
  /// named in the last game as known (+10), not new (+25). [random] drives
  /// the bot's thinking time.
  GameCubit({
    required Match Function(Set<int> discoveredIds) createMatch,
    required PlayerStore store,
    required Random random,
  }) : _createMatch = createMatch,
       _store = store,
       _random = random,
       super(const GameLoading());

  final Match Function(Set<int> discoveredIds) _createMatch;
  final PlayerStore _store;
  final Random _random;

  Match? _match;
  Timer? _botTimer;
  Timer? _countdown;
  int _secondsLeft = 0;
  bool _paused = false;
  RejectionReason? _lastRejection;

  /// Starts a new game, dropping any game in progress. When the bot opens,
  /// it thinks first; when the player opens, their countdown starts right
  /// away.
  void start() {
    _cancelTimers();
    _paused = false;
    final match = _createMatch(_store.data.discoveredIds);
    _match = match;
    _lastRejection = null;
    _beginTurn(match);
  }

  /// The player's answer. When it's accepted, the bot's turn begins; when
  /// it's rejected, the reason is shown and the countdown keeps running.
  void submit(String answer) {
    final match = _playerMatch;
    if (match == null) return;
    switch (match.submit(answer)) {
      case Accepted():
        _lastRejection = null;
        _beginTurn(match);
      case Rejected(:final reason):
        _lastRejection = reason;
        _emitPlaying(match);
    }
  }

  /// Plays a city on the player's behalf, for 0 points. Does nothing when
  /// no hints are left or no city fits.
  void hint() {
    final match = _playerMatch;
    if (match == null || match.hint() == null) return;
    _lastRejection = null;
    _beginTurn(match);
  }

  /// The player gives up and loses. Allowed while the bot thinks, and
  /// while paused.
  void giveUp() {
    final match = _match;
    if (match == null || match.isOver) return;
    _paused = false;
    match.surrender();
    _endGame(match);
  }

  /// Freezes the game while the app is in the background (a phone call, the
  /// app switcher): the countdown and the bot's thinking stop, and the
  /// player can't move until [resume].
  void pause() {
    final match = _match;
    if (match == null || match.isOver || _paused) return;
    _paused = true;
    _cancelTimers();
    _emitPlaying(match);
  }

  /// Picks up where [pause] left off, with the same seconds left. If the bot
  /// was thinking, it thinks again from the start.
  void resume() {
    final match = _match;
    if (match == null || match.isOver || !_paused) return;
    _paused = false;
    _startTimers(match);
    _emitPlaying(match);
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }

  /// The match, when the player may move in it.
  Match? get _playerMatch {
    final match = _match;
    if (match == null || match.isOver || _paused || match.turn != Side.player) {
      return null;
    }
    return match;
  }

  void _beginTurn(Match match) {
    _secondsLeft = match.difficulty.turnTime.inSeconds;
    _startTimers(match);
    _emitPlaying(match);
  }

  /// The bot's thinking or the player's countdown, from [_secondsLeft].
  void _startTimers(Match match) {
    _cancelTimers();
    switch (match.turn) {
      case Side.bot:
        _botTimer = Timer(botThinkingTime(_random), () => _botMove(match));
      case Side.player:
        _countdown = Timer.periodic(
          const Duration(seconds: 1),
          (_) => _tick(match),
        );
    }
  }

  void _botMove(Match match) {
    switch (match.botMove()) {
      case BotPlays():
        _beginTurn(match);
      case BotGivesUp():
        _endGame(match);
    }
  }

  void _tick(Match match) {
    _secondsLeft--;
    if (_secondsLeft > 0) {
      _emitPlaying(match);
      return;
    }
    match.timeout();
    _endGame(match);
  }

  /// Every way a game ends (win, timeout, giving up) comes here, so every
  /// result is saved.
  void _endGame(Match match) {
    _cancelTimers();
    final result = match.result;
    if (result == null) return;
    final mode = GameSetup(
      list: match.index.list,
      difficulty: match.difficulty,
    );
    unawaited(_store.update((data) => data.withResult(mode, result)));
    emit(GameOver(result: result, history: match.history));
  }

  void _emitPlaying(Match match) => emit(
    GamePlaying(
      history: match.history,
      letterMarks: _letterMarks(match),
      turn: match.turn,
      requiredLetter: match.requiredLetter,
      extraLetters: match.extraLetters,
      secondsLeft: _secondsLeft,
      score: match.score,
      chain: match.chain,
      hintsLeft: match.hintsLeft,
      lastRejection: _lastRejection,
      isPaused: _paused,
    ),
  );

  static LetterMarks? _letterMarks(Match match) => match.history.isEmpty
      ? null
      : match.index.letterMarks(match.history.last.city);

  void _cancelTimers() {
    _botTimer?.cancel();
    _countdown?.cancel();
  }
}
