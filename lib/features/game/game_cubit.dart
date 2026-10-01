import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

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
/// - hints, giving up, and the end of the game.
///
/// Player actions that come at the wrong moment (a double tap while the bot
/// thinks, a tap after the game ended) are ignored: they are UI races, not
/// errors.
class GameCubit extends Cubit<GameState> {
  /// [createMatch] builds a fresh game for [start], with the setup the
  /// player chose (list, difficulty, who starts) and the cities discovered
  /// so far. [discoveredIds] are the cities the player had named before;
  /// [random] drives the bot's thinking time.
  GameCubit({
    required Match Function(Set<int> discoveredIds) createMatch,
    required Random random,
    Set<int> discoveredIds = const {},
  }) : _createMatch = createMatch,
       _random = random,
       _discoveredIds = {...discoveredIds},
       super(const GameLoading());

  final Match Function(Set<int> discoveredIds) _createMatch;
  final Random _random;

  /// Every city the player has named, this game included. It's in memory
  /// until T18 saves it, so "Play again" already scores a city named in the
  /// last game as known (+10), not new (+25).
  final Set<int> _discoveredIds;

  Match? _match;
  Timer? _botTimer;
  Timer? _countdown;
  int _secondsLeft = 0;
  RejectionReason? _lastRejection;

  /// Starts a new game, dropping any game in progress. When the bot opens,
  /// it thinks first; when the player opens, their countdown starts right
  /// away.
  void start() {
    _cancelTimers();
    final match = _createMatch(Set.unmodifiable(_discoveredIds));
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

  /// The player gives up and loses. Allowed while the bot thinks, too.
  void giveUp() {
    final match = _match;
    if (match == null || match.isOver) return;
    match.surrender();
    _endGame(match);
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }

  /// The match, when the player may move in it.
  Match? get _playerMatch {
    final match = _match;
    if (match == null || match.isOver || match.turn != Side.player) {
      return null;
    }
    return match;
  }

  void _beginTurn(Match match) {
    _cancelTimers();
    _secondsLeft = match.difficulty.turnTime.inSeconds;
    switch (match.turn) {
      case Side.bot:
        _botTimer = Timer(botThinkingTime(_random), () => _botMove(match));
      case Side.player:
        _countdown = Timer.periodic(
          const Duration(seconds: 1),
          (_) => _tick(match),
        );
    }
    _emitPlaying(match);
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

  void _endGame(Match match) {
    _cancelTimers();
    final result = match.result;
    if (result == null) return;
    _discoveredIds.addAll(result.newCityIds);
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
