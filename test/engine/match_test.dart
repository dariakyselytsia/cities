import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/engine/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scripted_bot.dart';

City _city(int id, String name, int population,
        {List<String> aka = const [], String cc = 'XX'}) =>
    City(
      id: id,
      nameEn: name,
      countryCode: cc,
      population: population,
      aliasesEn: aka,
    );

/// An English World list. Tiers (limits 2 / 4 / 6):
/// T1 Kursk, Kyiv · T2 Vilnius, Seoul · T3 Lima, Ankara · T4 the rest.
final kursk = _city(1, 'Kursk', 1000000);
final kyiv = _city(2, 'Kyiv', 900000, aka: ['Kiev']);
final vilnius = _city(3, 'Vilnius', 800000);
final seoul = _city(4, 'Seoul', 700000);
final lima = _city(5, 'Lima', 600000);
final ankara = _city(6, 'Ankara', 500000);
final accra = _city(7, 'Accra', 400000);
final kaunas = _city(8, 'Kaunas', 300000);
final mumbai = _city(9, 'Mumbai', 250000, aka: ['Bombay']);
final zagreb = _city(10, 'Zagreb', 150000);
final amsterdam = _city(11, 'Amsterdam', 140000);
final paris = _city(12, 'Paris', 130000);
final azov = _city(13, 'Azov', 80000);
final lviv = _city(14, 'Lviv', 70000);
final victoriaCa = _city(15, 'Victoria', 90000, cc: 'CA');
final victoriaAu = _city(16, 'Victoria', 20000, cc: 'AU');
final bilbao = _city(17, 'Bilbao', 10000);

CityIndex _indexOf(List<City> cities) => CityCatalog(
      cities,
      tierLimits: const TierLimits(ukraine: [1, 2, 3], world: [2, 4, 6]),
      letterMinimums: const LetterMinimums(ukraine: 1, world: 1),
    ).index(CityListKind.world, NameLanguage.en);

final _index = _indexOf([
  kursk, kyiv, vilnius, seoul, lima, ankara, accra, kaunas, mumbai, zagreb,
  amsterdam, paris, azov, lviv, victoriaCa, victoriaAu, bilbao,
]);

Match _match(
  List<City> botScript, {
  Difficulty difficulty = Difficulty.medium,
  Set<int> discovered = const {},
  CityIndex? index,
  int seed = 1,
}) {
  final i = index ?? _index;
  return Match(
    index: i,
    difficulty: difficulty,
    random: Random(seed),
    discoveredIds: discovered,
    bot: ScriptedBot(i, botScript),
  );
}

/// Asserts [result] is [Accepted] and returns the city it played.
City _accepted(SubmitResult result) => switch (result) {
      Accepted(:final turn) => turn.city,
      Rejected(:final reason) => fail('Rejected: $reason'),
    };

void main() {
  group('turns', () {
    test('the bot opens; there is no required letter yet', () {
      final match = _match([kursk]);
      expect(match.turn, Side.bot);
      expect(match.requiredLetter, isNull);

      expect(match.botMove(), BotPlays(kursk));
      expect(match.turn, Side.player);
      expect(match.requiredLetter, 'k');
      expect(match.history, [Turn(city: kursk, side: Side.bot)]);
    });

    test('the player can open instead: any city goes', () {
      final match = Match(
        index: _index,
        difficulty: Difficulty.medium,
        random: Random(1),
        firstTurn: Side.player,
        bot: ScriptedBot(_index, [vilnius]),
      );
      expect(match.turn, Side.player);
      expect(match.requiredLetter, isNull);
      expect(() => match.botMove(), throwsStateError);

      expect(_accepted(match.submit('Paris')), paris);
      expect(match.turn, Side.bot);
      expect(match.requiredLetter, 's');
    });

    test('an opening hint plays a best-known city', () {
      final match = Match(
        index: _index,
        difficulty: Difficulty.medium,
        random: Random(1),
        firstTurn: Side.player,
        bot: ScriptedBot(_index, const []),
      );
      // No letter yet: any tier-1 city (Kursk or Kyiv).
      expect(match.hint()?.city, anyOf(kursk, kyiv));
    });

    test('moving out of turn is a programming error', () {
      final match = _match([kursk]);
      expect(() => match.submit('Kyiv'), throwsStateError);
      expect(() => match.hint(), throwsStateError);
      expect(() => match.timeout(), throwsStateError);
      match.botMove();
      expect(() => match.botMove(), throwsStateError);
    });

    test('an accepted answer passes the turn to the bot', () {
      final match = _match([kursk])..botMove();
      match.submit('Kyiv');
      expect(match.turn, Side.bot);
      expect(match.requiredLetter, 'v');
      expect(match.usedIds, {kursk.id, kyiv.id});
    });
  });

  group('rejections', () {
    late Match match;
    setUp(() => match = _match([kursk])..botMove()); // requires «k»

    for (final (answer, reason) in [
      ('', RejectionReason.empty),
      ('   ', RejectionReason.empty),
      ("'-", RejectionReason.empty),
      ('Atlantis', RejectionReason.notInList),
      ('Київ', RejectionReason.notInList), // not in this game's language
      ('Paris', RejectionReason.wrongLetter),
      ('Kursk', RejectionReason.alreadyUsed),
      ('  KURSK ', RejectionReason.alreadyUsed),
    ]) {
      test('"$answer" → ${reason.name}', () {
        expect(match.submit(answer), Rejected(reason));
      });
    }

    test("a rejection changes nothing: it's still the player's turn", () {
      match.submit('Paris');
      expect(match.turn, Side.player);
      expect(match.history, hasLength(1));
      expect(match.score, 0);
      expect(match.chain, 0);
    });
  });

  group('accepting', () {
    test('by an alias, normalized', () {
      final match = _match([kursk])..botMove();
      expect(_accepted(match.submit('  kiev ')), kyiv);
    });

    test('an alias may fit the letter by its own spelling…', () {
      // Zagreb → «b»: "Bombay" fits, though the city is Mumbai.
      final match = _match([zagreb])..botMove();
      expect(match.requiredLetter, 'b');
      expect(_accepted(match.submit('Bombay')), mumbai);
      // The next letter comes from the display name: Mumbai → «i» isn't
      // playable here, so «a».
      expect(match.requiredLetter, 'a');
    });

    test('…or by the display name', () {
      // Amsterdam → «m»: "Bombay" is Mumbai, which starts with «m».
      final match = _match([amsterdam])..botMove();
      expect(_accepted(match.submit('Bombay')), mumbai);
    });

    test('…but not if neither fits', () {
      final match = _match([kursk])..botMove();
      expect(match.submit('Bombay'), const Rejected(RejectionReason.wrongLetter));
    });

    test('same-named cities: the most populous unused one is played', () {
      // Victoria (CA) first; once used, Victoria (AU).
      final match = _match([victoriaCa, vilnius, lviv])..botMove(); // «a»
      _accepted(match.submit('Azov')); // → «v»
      match.botMove(); // Vilnius → «s»
      _accepted(match.submit('Seoul')); // → «l»
      match.botMove(); // Lviv → «v»
      expect(_accepted(match.submit('Victoria')), victoriaAu);
    });

    test('a shared name picks the most populous city first', () {
      final match = _match([kyiv])..botMove(); // «v»
      expect(_accepted(match.submit('Victoria')), victoriaCa);
    });
  });

  group('rare letters skipped at the end can be played too', () {
    // Letters 2+ cities start with are playable: «c», «a». «n» and «e»
    // start one city each: rare, so "Nice" asks for «c» (skipping «e»).
    final nice = _city(101, 'Nice', 340000);
    final cairo = _city(102, 'Cairo', 9000000);
    final cork = _city(103, 'Cork', 220000);
    final essen = _city(104, 'Essen', 580000);
    final accra = _city(105, 'Accra', 2300000);
    final ankara = _city(106, 'Ankara', 5000000);
    final index = CityCatalog(
      [nice, cairo, cork, essen, accra, ankara],
      letterMinimums: const LetterMinimums(ukraine: 2, world: 2),
    ).index(CityListKind.world, NameLanguage.en);

    Match afterNice() {
      final match = _match([nice], index: index)..botMove();
      return match;
    }

    test('the extra letters are the skipped rare ones', () {
      final match = afterNice();
      expect(match.requiredLetter, 'c');
      expect(match.extraLetters, ['e']);
    });

    test('the required letter works', () {
      expect(_accepted(afterNice().submit('Cork')), cork);
    });

    test('so does a skipped rare letter', () {
      expect(_accepted(afterNice().submit('Essen')), essen);
    });

    test('other letters are still wrong', () {
      expect(
        afterNice().submit('Accra'),
        const Rejected(RejectionReason.wrongLetter),
      );
    });

    test('a hint uses the required letter', () {
      expect(afterNice().hint()?.city, anyOf(cairo, cork));
    });

    test('no extra letters before the first city', () {
      expect(_match([nice], index: index).extraLetters, isEmpty);
    });
  });

  group('scoring', () {
    test('a city never named before is worth $pointsForNewCity', () {
      final match = _match([kursk])..botMove();
      final result = match.submit('Kyiv');
      expect(
        result,
        Accepted(Turn(
          city: kyiv,
          side: Side.player,
          points: pointsForNewCity,
          isNew: true,
        )),
      );
      expect(match.score, 25);
    });

    test('a city named in an earlier game is worth $pointsForCity', () {
      final match = _match([kursk], discovered: {kyiv.id})..botMove();
      match.submit('Kyiv');
      expect(match.history.last.points, 10);
      expect(match.history.last.isNew, isFalse);
      expect(match.score, 10);
    });

    test('a win adds the bonus × difficulty', () {
      for (final (difficulty, bonus) in [
        (Difficulty.easy, 50),
        (Difficulty.medium, 100),
        (Difficulty.hard, 150),
      ]) {
        final match = _match([kursk], difficulty: difficulty)..botMove();
        match.submit('Kyiv'); // 25
        expect(match.botMove(), const BotGivesUp());
        expect(match.result?.score, 25 + bonus, reason: difficulty.name);
        expect(match.score, 25 + bonus);
      }
    });
  });

  group('hints', () {
    test('play a best-known unused city for 0 points', () {
      final match = _match([kursk])..botMove(); // «k»: Kyiv is tier 1
      final turn = match.hint();
      expect(
        turn,
        Turn(city: kyiv, side: Side.player, points: 0, isHint: true),
      );
      expect(match.hintsLeft, hintsPerGame - 1);
      expect(match.turn, Side.bot);
      expect(match.usedIds, contains(kyiv.id));
      expect(match.score, 0);
      expect(match.chain, 0, reason: "hints don't count toward the chain");
    });

    test('there are $hintsPerGame per game', () {
      // Kursk → hint Kyiv → Vilnius → hint Seoul → Lima → hint Ankara →
      // Accra → no hints left.
      final match = _match([kursk, vilnius, lima, accra])..botMove();
      expect(match.hint()?.city, kyiv);
      match.botMove();
      expect(match.hint()?.city, seoul);
      match.botMove();
      expect(match.hint()?.city, ankara);
      match.botMove();

      expect(match.hintsLeft, 0);
      expect(match.hint(), isNull);
      expect(match.turn, Side.player, reason: 'still the player to move');
    });

    test('a hint is not spent when no city fits', () {
      // «k»'s only city, Kursk, is used.
      final index = _indexOf([kursk, lima]);
      final match = _match([kursk], index: index)..botMove();
      expect(match.requiredLetter, 'k');
      expect(match.hint(), isNull);
      expect(match.hintsLeft, hintsPerGame);
    });

    test('hinted cities are not new discoveries', () {
      final match = _match([kursk])..botMove();
      match.hint();
      match.botMove(); // gives up
      expect(match.result?.newCityIds, isEmpty);
      expect(match.result?.namedCityIds, isEmpty);
    });
  });

  group('the end', () {
    test('the bot giving up is a win', () {
      final match = _match([kursk, vilnius])..botMove();
      match.submit('Kyiv'); // 25, new
      match.botMove(); // Vilnius → «s»
      match.submit('Seoul'); // 25, new
      expect(match.botMove(), const BotGivesUp());

      expect(match.isOver, isTrue);
      expect(
        match.result,
        MatchResult(
          outcome: MatchOutcome.botGaveUp,
          score: 25 + 25 + 100,
          chain: 2,
          newCityIds: [kyiv.id, seoul.id],
          namedCityIds: [kyiv.id, seoul.id],
        ),
      );
      expect(match.result?.isWin, isTrue);
    });

    test('a timeout is a loss, with no bonus', () {
      final match = _match([kursk, vilnius], discovered: {kyiv.id})..botMove();
      match.submit('Kyiv'); // 10, already discovered
      match.botMove();
      final result = match.timeout();

      expect(
        result,
        MatchResult(
          outcome: MatchOutcome.timeout,
          score: 10,
          chain: 1,
          newCityIds: const [],
          namedCityIds: [kyiv.id],
        ),
      );
      expect(result.isWin, isFalse);
    });

    test('giving up is a loss, allowed on either turn', () {
      final onPlayersTurn = _match([kursk])..botMove();
      expect(onPlayersTurn.surrender().outcome, MatchOutcome.surrendered);

      final whileBotThinks = _match([kursk]);
      expect(whileBotThinks.surrender().isWin, isFalse);
    });

    test('nothing can be played after the end', () {
      final match = _match([kursk])..botMove();
      match.timeout();
      expect(() => match.submit('Kyiv'), throwsStateError);
      expect(() => match.hint(), throwsStateError);
      expect(() => match.timeout(), throwsStateError);
      expect(() => match.surrender(), throwsStateError);
    });
  });
}
