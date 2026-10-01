import 'dart:math';

import 'package:equatable/equatable.dart';

import 'bot.dart';
import 'city.dart';
import 'city_catalog.dart';
import 'difficulty.dart';
import 'letter_rule.dart';
import 'normalize.dart';
import 'scoring.dart';

/// Hints per game (game_design §2.6).
const int hintsPerGame = 3;

/// Who is to move, or who moved.
enum Side { bot, player }

/// One city in the game's history.
final class Turn extends Equatable {
  const Turn({
    required this.city,
    required this.side,
    this.points = 0,
    this.isNew = false,
    this.isHint = false,
  });

  final City city;
  final Side side;

  /// Points the player got for it (always 0 for the bot and for hints).
  final int points;

  /// The player had never named this city before.
  final bool isNew;

  /// Played by a hint, on the player's behalf.
  final bool isHint;

  @override
  List<Object?> get props => [city, side, points, isNew, isHint];
}

/// Why an answer was rejected. A rejection is a value, not an error: the
/// player can retry until the timer runs out (game_design §2.4).
enum RejectionReason {
  /// Nothing but spaces or punctuation.
  empty,

  /// No city in the active list and language has this name.
  notInList,

  /// It names a city, but neither the answer nor the city's name starts with
  /// the required letter.
  wrongLetter,

  /// Every city with this name (and the right letter) was already played.
  alreadyUsed,
}

/// The outcome of the player's answer.
sealed class SubmitResult extends Equatable {
  const SubmitResult();
}

/// The answer was accepted and played.
final class Accepted extends SubmitResult {
  const Accepted(this.turn);

  final Turn turn;

  @override
  List<Object?> get props => [turn];
}

/// The answer was rejected. Nothing changed, and it's still the player's
/// turn.
final class Rejected extends SubmitResult {
  const Rejected(this.reason);

  final RejectionReason reason;

  @override
  List<Object?> get props => [reason];
}

/// How a game ended (game_design §2.7).
enum MatchOutcome {
  /// CityBot knew no unused city for the letter: the player wins.
  botGaveUp,

  /// The player's turn timer ran out.
  timeout,

  /// The player tapped Give up.
  surrendered;

  bool get isWin => this == MatchOutcome.botGaveUp;
}

/// The summary of a finished game, for the game-over view and the stats.
final class MatchResult extends Equatable {
  const MatchResult({
    required this.outcome,
    required this.score,
    required this.chain,
    required this.newCityIds,
    required this.namedCityIds,
  });

  final MatchOutcome outcome;

  /// The final score, including the win bonus.
  final int score;

  /// How many cities the player named themselves (hints don't count).
  final int chain;

  /// Cities the player named for the first time ever: they join the
  /// player's discovered cities (T18).
  final List<int> newCityIds;

  /// Every city the player named themselves, in order (not hinted ones).
  final List<int> namedCityIds;

  bool get isWin => outcome.isWin;

  @override
  List<Object?> get props => [outcome, score, chain, newCityIds, namedCityIds];
}

/// One game of Cities: the rules, with no timers or UI (tech_design §3).
///
/// The bot opens (or the player, with `firstTurn`), then turns alternate.
/// The `GameCubit` (T11) owns time: it
/// calls [botMove] after a "thinking" delay, [submit] and [hint] on player
/// input, and [timeout] when the countdown ends.
///
/// Calling a method out of turn, or after the game ended, is a programming
/// error and throws a [StateError]. A wrong answer is not: it's a
/// [Rejected] value.
class Match {
  /// [random] drives the bot and the hints. [firstTurn] is who opens: the
  /// bot by default, or the player (a setting, game_design §2.2). [bot] lets
  /// tests script the bot's moves; the game uses the default [CityBot].
  Match({
    required this.index,
    required this.difficulty,
    required Random random,
    Set<int> discoveredIds = const {},
    Side firstTurn = Side.bot,
    CityBot? bot,
  }) : _random = random,
       _discoveredIds = discoveredIds,
       _turn = firstTurn,
       _bot =
           bot ?? CityBot(index: index, difficulty: difficulty, random: random);

  /// The list × language being played.
  final CityIndex index;
  final Difficulty difficulty;
  final Random _random;
  final CityBot _bot;

  /// Cities the player had named in earlier games: naming one again is worth
  /// [pointsForCity], not [pointsForNewCity].
  final Set<int> _discoveredIds;

  final List<Turn> _history = [];
  final Set<int> _usedIds = {};
  Side _turn;
  int _hintsLeft = hintsPerGame;
  MatchResult? _result;

  /// Every city played so far, by both sides, in order.
  List<Turn> get history => List.unmodifiable(_history);

  /// The ids of every city played: one set shared by both sides.
  Set<int> get usedIds => Set.unmodifiable(_usedIds);

  /// Whose move it is. Meaningless once [isOver].
  Side get turn => _turn;

  int get hintsLeft => _hintsLeft;

  /// The score so far; once the game is over, the final score, including the
  /// win bonus.
  int get score =>
      _result?.score ?? _history.fold(0, (sum, t) => sum + t.points);

  /// How many cities the player named themselves.
  int get chain => _history.where(_namedByPlayer).length;

  /// The letter the next city must start with, or `null` when any letter
  /// will do (the opening move, or after a dead end).
  String? get requiredLetter =>
      _history.isEmpty ? null : index.requiredLetterAfter(_history.last.city);

  /// The result, once the game is over.
  MatchResult? get result => _result;

  bool get isOver => _result != null;

  /// CityBot's turn: it plays a city, or gives up and the player wins.
  BotMove botMove() {
    _expectTurn(Side.bot);
    final move = _bot.move(requiredLetter: requiredLetter, usedIds: _usedIds);
    switch (move) {
      case BotPlays(:final city):
        _play(Turn(city: city, side: Side.bot));
      case BotGivesUp():
        _end(MatchOutcome.botGaveUp);
    }
    return move;
  }

  /// The player's answer.
  ///
  /// [answer] may be a display name or an alias, typed in any case, with or
  /// without apostrophes and diacritics (`normalizeName`). It is accepted
  /// when it names a city of the active list and language that:
  /// 1. starts with the required letter: by the typed answer **or** by the
  ///    city's display name, so "Bombay" works for «b» and for «m». This is
  ///    forgiving on purpose. The next letter always comes from the display
  ///    name, which is what the chat shows;
  /// 2. hasn't been played in this game.
  ///
  /// Among same-named cities, the most populous one that qualifies is
  /// played.
  SubmitResult submit(String answer) {
    _expectTurn(Side.player);
    if (normalizeName(answer).isEmpty) {
      return const Rejected(RejectionReason.empty);
    }
    final named = index.lookup(answer);
    if (named.isEmpty) return const Rejected(RejectionReason.notInList);

    final letter = requiredLetter;
    final answerFits = LetterRule.startsWithRequired(answer, letter);
    final rightLetter = [
      for (final city in named)
        if (answerFits ||
            LetterRule.startsWithRequired(city.name(index.language) ?? '', letter))
          city,
    ];
    if (rightLetter.isEmpty) return const Rejected(RejectionReason.wrongLetter);

    final unused = rightLetter.where((c) => !_usedIds.contains(c.id));
    if (unused.isEmpty) return const Rejected(RejectionReason.alreadyUsed);

    final city = unused.first;
    final isNew = !_discoveredIds.contains(city.id);
    final turn = Turn(
      city: city,
      side: Side.player,
      points: isNew ? pointsForNewCity : pointsForCity,
      isNew: isNew,
    );
    _play(turn);
    return Accepted(turn);
  }

  /// Plays a valid unused city on the player's behalf, for
  /// [pointsForHint] points (game_design §2.6).
  ///
  /// It prefers well-known cities: a random one from the best-known tier
  /// that still has an unused city for the letter. Returns `null`, and
  /// spends no hint, when no hints are left or no city fits.
  Turn? hint() {
    _expectTurn(Side.player);
    if (_hintsLeft == 0) return null;
    final letter = requiredLetter;
    final candidates = [
      for (final city in letter == null ? index.cities : index.startingWith(letter))
        if (!_usedIds.contains(city.id)) city,
    ];
    if (candidates.isEmpty) return null;

    // Candidates are in fame order, so the first one's tier is the best.
    final bestTier = index.tierOf(candidates.first);
    final best = [
      for (final city in candidates)
        if (index.tierOf(city) == bestTier) city,
    ];
    final turn = Turn(
      city: best[_random.nextInt(best.length)],
      side: Side.player,
      points: pointsForHint,
      isHint: true,
    );
    _hintsLeft--;
    _play(turn);
    return turn;
  }

  /// The player's timer ran out: the player loses.
  MatchResult timeout() {
    _expectTurn(Side.player);
    return _end(MatchOutcome.timeout);
  }

  /// The player gave up. Allowed on either turn, e.g. while the bot thinks.
  MatchResult surrender() {
    _expectNotOver();
    return _end(MatchOutcome.surrendered);
  }

  void _play(Turn turn) {
    _history.add(turn);
    _usedIds.add(turn.city.id);
    _turn = turn.side == Side.bot ? Side.player : Side.bot;
  }

  MatchResult _end(MatchOutcome outcome) {
    final named = [
      for (final t in _history)
        if (_namedByPlayer(t)) t,
    ];
    final result = MatchResult(
      outcome: outcome,
      score: named.fold(0, (sum, t) => sum + t.points) +
          (outcome.isWin ? winPoints(difficulty) : 0),
      chain: named.length,
      newCityIds: List.unmodifiable([for (final t in named) if (t.isNew) t.city.id]),
      namedCityIds: List.unmodifiable([for (final t in named) t.city.id]),
    );
    _result = result;
    return result;
  }

  void _expectNotOver() {
    if (isOver) throw StateError('The match is over');
  }

  void _expectTurn(Side side) {
    _expectNotOver();
    if (_turn != side) throw StateError("It's the ${_turn.name}'s turn");
  }
}

bool _namedByPlayer(Turn turn) => turn.side == Side.player && !turn.isHint;
