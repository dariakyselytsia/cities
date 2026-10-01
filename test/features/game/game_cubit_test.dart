import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/engine/scoring.dart';
import 'package:cities/features/game/game_cubit.dart';
import 'package:cities/features/game/game_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/scripted_bot.dart';

City _city(int id, String name, int population) =>
    City(id: id, nameEn: name, countryCode: 'XX', population: population);

/// One city per first letter, so every move and hint is predictable:
/// Kyiv → «v» Vilnius → «s» Seoul → «l» Lima → «a» Ankara.
final kyiv = _city(1, 'Kyiv', 900000);
final vilnius = _city(2, 'Vilnius', 800000);
final seoul = _city(3, 'Seoul', 700000);
final lima = _city(4, 'Lima', 600000);
final ankara = _city(5, 'Ankara', 500000);

final _index = CityCatalog(
  [kyiv, vilnius, seoul, lima, ankara],
  letterMinimums: const LetterMinimums(ukraine: 1, world: 1),
).index(CityListKind.world, NameLanguage.en);

const _difficulty = Difficulty.medium;
final _turnSeconds = _difficulty.turnTime.inSeconds;

GameCubit _cubit(List<City> botScript, {Side firstTurn = Side.bot}) =>
    GameCubit(
      createMatch: () => Match(
        index: _index,
        difficulty: _difficulty,
        random: Random(1),
        firstTurn: firstTurn,
        bot: ScriptedBot(_index, botScript),
      ),
      random: Random(1),
    );

GamePlaying _playing(
  List<Turn> history, {
  required Side turn,
  String? letter,
  int? secondsLeft,
  int score = 0,
  int hintsLeft = hintsPerGame,
  RejectionReason? rejection,
}) =>
    GamePlaying(
      history: history,
      turn: turn,
      requiredLetter: letter,
      secondsLeft: secondsLeft ?? _turnSeconds,
      score: score,
      hintsLeft: hintsLeft,
      lastRejection: rejection,
    );

Turn _bot(City city) => Turn(city: city, side: Side.bot);

Turn _named(City city) => Turn(
      city: city,
      side: Side.player,
      points: pointsForNewCity,
      isNew: true,
    );

/// Runs [body] in fake time, with a started game from [cubit].
void _inFakeTime(GameCubit cubit, void Function(FakeAsync async) body) {
  fakeAsync((async) {
    cubit.start();
    body(async);
    cubit.close();
    async.flushMicrotasks();
  });
}

void main() {
  group('a full game, in fake time', () {
    test('the bot opens → the player answers → the bot replies → win', () {
      final cubit = _cubit([kyiv, seoul]);
      _inFakeTime(cubit, (async) {
        expect(cubit.state, _playing(const [], turn: Side.bot));

        // The bot thinks for 0.6–1.2 s.
        async.elapse(botThinkingMin - const Duration(milliseconds: 1));
        expect(cubit.state, _playing(const [], turn: Side.bot));
        async.elapse(botThinkingMax - botThinkingMin);
        expect(
          cubit.state,
          _playing([_bot(kyiv)], turn: Side.player, letter: 'v'),
        );

        cubit.submit('vilnius');
        final afterVilnius = [_bot(kyiv), _named(vilnius)];
        expect(
          cubit.state,
          _playing(afterVilnius, turn: Side.bot, letter: 's', score: 25),
        );

        async.elapse(botThinkingMax);
        final afterSeoul = [...afterVilnius, _bot(seoul)];
        expect(
          cubit.state,
          _playing(afterSeoul, turn: Side.player, letter: 'l', score: 25),
        );

        cubit.submit('Lima');
        async.elapse(botThinkingMax);
        expect(
          cubit.state,
          GameOver(
            result: MatchResult(
              outcome: MatchOutcome.botGaveUp,
              score: 2 * pointsForNewCity + winPoints(_difficulty),
              chain: 2,
              newCityIds: [vilnius.id, lima.id],
              namedCityIds: [vilnius.id, lima.id],
            ),
            history: [...afterSeoul, _named(lima)],
          ),
        );
      });
    });

    test('the countdown ticks each second; timeout is a loss', () {
      final cubit = _cubit([kyiv]);
      _inFakeTime(cubit, (async) {
        async.elapse(botThinkingMax);
        final seconds = <int>[];
        final sub = cubit.stream.listen((state) {
          if (state is GamePlaying) seconds.add(state.secondsLeft);
        });

        async.elapse(Duration(seconds: _turnSeconds - 1));
        expect(seconds, [for (var s = _turnSeconds - 1; s >= 1; s--) s]);
        expect(cubit.state, isA<GamePlaying>());

        async.elapse(const Duration(seconds: 1));
        expect(
          cubit.state,
          GameOver(
            result: const MatchResult(
              outcome: MatchOutcome.timeout,
              score: 0,
              chain: 0,
              newCityIds: [],
              namedCityIds: [],
            ),
            history: [_bot(kyiv)],
          ),
        );
        sub.cancel();
      });
    });

    test('a rejection keeps the timer running; an answer resets it', () {
      final cubit = _cubit([kyiv, seoul]);
      _inFakeTime(cubit, (async) {
        async.elapse(botThinkingMax);
        async.elapse(const Duration(seconds: 5));

        cubit.submit('Paris');
        expect(
          cubit.state,
          _playing(
            [_bot(kyiv)],
            turn: Side.player,
            letter: 'v',
            secondsLeft: _turnSeconds - 5,
            rejection: RejectionReason.notInList,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        cubit.submit('Seoul');
        expect(
          cubit.state,
          _playing(
            [_bot(kyiv)],
            turn: Side.player,
            letter: 'v',
            secondsLeft: _turnSeconds - 6,
            rejection: RejectionReason.wrongLetter,
          ),
        );

        // The next turn starts with the full time, and no rejection.
        cubit.submit('Vilnius');
        async.elapse(botThinkingMax);
        expect(
          cubit.state,
          _playing(
            [_bot(kyiv), _named(vilnius), _bot(seoul)],
            turn: Side.player,
            letter: 'l',
            score: 25,
          ),
        );
      });
    });

    test('a hint plays a city for 0 points and passes the turn', () {
      final cubit = _cubit([kyiv, seoul]);
      _inFakeTime(cubit, (async) {
        async.elapse(botThinkingMax);
        cubit.hint();
        final hinted = Turn(
          city: vilnius,
          side: Side.player,
          points: pointsForHint,
          isHint: true,
        );
        expect(
          cubit.state,
          _playing(
            [_bot(kyiv), hinted],
            turn: Side.bot,
            letter: 's',
            hintsLeft: hintsPerGame - 1,
          ),
        );

        async.elapse(botThinkingMax);
        expect(
          cubit.state,
          _playing(
            [_bot(kyiv), hinted, _bot(seoul)],
            turn: Side.player,
            letter: 'l',
            hintsLeft: hintsPerGame - 1,
          ),
        );
      });
    });

    test('a hint that finds no city does nothing, and spends nothing', () {
      final cubit = _cubit([kyiv, seoul, ankara]);
      _inFakeTime(cubit, (async) {
        async.elapse(botThinkingMax);
        cubit.hint(); // Vilnius
        async.elapse(botThinkingMax);
        cubit.hint(); // Lima
        async.elapse(botThinkingMax);
        async.elapse(const Duration(seconds: 3));

        // Ankara → «a», and every «a» city is used.
        final stuck = cubit.state;
        expect(
          stuck,
          isA<GamePlaying>()
              .having((s) => s.requiredLetter, 'letter', 'a')
              .having((s) => s.hintsLeft, 'hints', hintsPerGame - 2),
        );
        cubit.hint();
        expect(cubit.state, stuck);
      });
    });

    test('giving up while the bot thinks ends the game; the bot never moves',
        () {
      final cubit = _cubit([kyiv]);
      _inFakeTime(cubit, (async) {
        cubit.giveUp();
        const surrendered = GameOver(
          result: MatchResult(
            outcome: MatchOutcome.surrendered,
            score: 0,
            chain: 0,
            newCityIds: [],
            namedCityIds: [],
          ),
          history: [],
        );
        expect(cubit.state, surrendered);

        async.elapse(const Duration(minutes: 1));
        expect(cubit.state, surrendered);
      });
    });

    test('when the player opens, the countdown starts right away', () {
      final cubit = _cubit([vilnius], firstTurn: Side.player);
      _inFakeTime(cubit, (async) {
        expect(cubit.state, _playing(const [], turn: Side.player));

        async.elapse(const Duration(seconds: 1));
        expect(
          cubit.state,
          _playing(const [], turn: Side.player, secondsLeft: _turnSeconds - 1),
        );

        cubit.submit('Kyiv');
        async.elapse(botThinkingMax);
        expect(
          cubit.state,
          _playing(
            [_named(kyiv), _bot(vilnius)],
            turn: Side.player,
            letter: 's',
            score: 25,
          ),
        );
      });
    });

    test('closing the cubit stops its timers', () {
      final cubit = _cubit([kyiv]);
      fakeAsync((async) {
        cubit.start();
        cubit.close();
        // An emit after close would throw.
        async.elapse(const Duration(minutes: 1));
        expect(cubit.isClosed, isTrue);
      });
    });
  });

  group('GameCubit', () {
    blocTest<GameCubit, GameState>(
      'starts in GameLoading',
      build: () => _cubit([kyiv]),
      verify: (cubit) => expect(cubit.state, const GameLoading()),
    );

    blocTest<GameCubit, GameState>(
      'ignores answers, hints and give-ups at the wrong moment',
      build: () => _cubit([kyiv]),
      act: (cubit) {
        cubit.giveUp(); // not started yet
        cubit.start();
        cubit.submit('Vilnius'); // the bot is thinking
        cubit.hint();
        cubit.giveUp();
        cubit.submit('Vilnius'); // the game is over
        cubit.giveUp();
      },
      expect: () => [
        _playing(const [], turn: Side.bot),
        isA<GameOver>(),
      ],
    );

    blocTest<GameCubit, GameState>(
      'start() again begins a fresh game (Play again)',
      build: () => _cubit(const [], firstTurn: Side.player),
      act: (cubit) {
        cubit.start();
        cubit.submit('Paris');
        cubit.giveUp();
        cubit.start();
      },
      expect: () => [
        _playing(const [], turn: Side.player),
        _playing(
          const [],
          turn: Side.player,
          rejection: RejectionReason.notInList,
        ),
        isA<GameOver>(),
        _playing(const [], turn: Side.player),
      ],
    );
  });
}
