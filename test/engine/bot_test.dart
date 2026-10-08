import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

/// A World list whose tiers are known exactly (limits 3 / 6 / 9):
/// - T1: Mia (the most populous), Kaa, Kab
/// - T2: Kac, Kad, Kae
/// - T3: Kaf, Kag, Kah
/// - T4: Kai, Kaj, Kak, Kal, Mib
City _city(int id, String name, int population) =>
    City(id: id, nameEn: name, countryCode: 'XX', population: population);

final _cities = [
  _city(1, 'Mia', 5000),
  for (final (i, name) in ['Kaa', 'Kab', 'Kac', 'Kad', 'Kae', 'Kaf', 'Kag',
      'Kah', 'Kai', 'Kaj', 'Kak', 'Kal'].indexed)
    _city(10 + i, name, 1000 - i * 10),
  _city(2, 'Mib', 5),
];

final _index = CityCatalog(
  _cities,
  tierLimits: const TierLimits(ukraine: [1, 2, 3], world: [3, 6, 9]),
  letterMinimums: const LetterMinimums(ukraine: 1, world: 1),
).index(CityListKind.world, NameLanguage.en);

Set<String> _names(Iterable<City> cities) => {for (final c in cities) c.nameEn};

/// The «k» cities each difficulty knows.
const _kVocabulary = {
  Difficulty.easy: {'Kaa', 'Kab'},
  Difficulty.medium: {'Kaa', 'Kab', 'Kac', 'Kad', 'Kae'},
  Difficulty.hard: {'Kaa', 'Kab', 'Kac', 'Kad', 'Kae', 'Kaf', 'Kag', 'Kah'},
};

void main() {
  /// A bot that knows only its tiers: most tests are about those. The
  /// per-letter minimum has its own group.
  CityBot bot(Difficulty difficulty, {int seed = 1}) => CityBot(
    index: _index,
    difficulty: difficulty,
    random: Random(seed),
    minCitiesPerLetter: 0,
  );

  /// Plays «k» until the bot gives up; returns what it played, in order.
  List<City> playOut(CityBot bot) {
    final used = <int>{};
    final played = <City>[];
    while (true) {
      switch (bot.move(requiredLetter: 'k', usedIds: used)) {
        case BotPlays(:final city):
          played.add(city);
          used.add(city.id);
        case BotGivesUp():
          return played;
      }
    }
  }

  test('the fixture has the intended tiers', () {
    expect(
      [for (final c in _index.startingWith('k')) _index.tierOf(c)],
      [1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4],
    );
  });

  for (final difficulty in Difficulty.values) {
    group(difficulty.name, () {
      for (final seed in [1, 2, 3, 42]) {
        test('seed $seed: plays its whole «k» vocabulary once, then gives up',
            () {
          final played = playOut(bot(difficulty, seed: seed));

          // Never a repeat…
          expect(played.map((c) => c.id).toSet(), hasLength(played.length));
          // …never outside its tiers, and gives up exactly when the letter's
          // vocabulary is exhausted.
          expect(_names(played), _kVocabulary[difficulty]);
        });
      }

      test('only ever plays cities of its tiers', () {
        final b = bot(difficulty);
        for (var i = 0; i < 500; i++) {
          final move = b.move(requiredLetter: null, usedIds: const {});
          expect(move, isA<BotPlays>());
          if (move case BotPlays(:final city)) {
            expect(_index.tierOf(city), lessThanOrEqualTo(difficulty.maxTier));
          }
        }
      });
    });
  }

  test('respects the required letter', () {
    final b = bot(Difficulty.hard);
    for (var i = 0; i < 200; i++) {
      final move = b.move(requiredLetter: 'm', usedIds: const {});
      expect(move, const BotPlays(_mia));
    }
  });

  test('gives up at once when it knows no city for the letter', () {
    // «m»'s only other city, Mib, is tier 4: unknown even on Hard.
    expect(
      bot(Difficulty.hard).move(requiredLetter: 'm', usedIds: {1}),
      const BotGivesUp(),
    );
    expect(
      bot(Difficulty.hard).move(requiredLetter: 'z', usedIds: const {}),
      const BotGivesUp(),
    );
  });

  test('falls back to an extra letter only when it knows no city for the '
      'required one', () {
    final b = bot(Difficulty.hard);
    // Mia is free: it is always played, however many «k» cities there are.
    for (var i = 0; i < 200; i++) {
      expect(
        b.move(requiredLetter: 'm', extraLetters: ['k'], usedIds: const {}),
        const BotPlays(_mia),
      );
    }
    // Mia is used (Mib is unknown): a «k» city it knows instead.
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      if (b.move(requiredLetter: 'm', extraLetters: ['k'], usedIds: {1})
          case BotPlays(:final city)) {
        seen.add(city.nameEn);
      }
    }
    expect(seen, _kVocabulary[Difficulty.hard]);
    // Nothing known for either letter: it gives up.
    expect(
      b.move(requiredLetter: 'm', extraLetters: ['z'], usedIds: {1}),
      const BotGivesUp(),
    );
  });

  test('an opening move (no letter) can be any city it knows', () {
    final b = bot(Difficulty.easy);
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      if (b.move(requiredLetter: null, usedIds: const {})
          case BotPlays(:final city)) {
        seen.add(city.nameEn);
      }
    }
    expect(seen, {'Mia', 'Kaa', 'Kab'});
  });

  test('prefers better-known cities: tier 1 is 4× as likely as tier 3', () {
    // Leave only Kaa (tier 1, weight 4) and Kaf (tier 3, weight 1).
    final used = {
      for (final c in _index.startingWith('k'))
        if (c.nameEn != 'Kaa' && c.nameEn != 'Kaf') c.id,
    };
    final b = bot(Difficulty.hard, seed: 7);
    var tierOne = 0;
    const draws = 10000;
    for (var i = 0; i < draws; i++) {
      if (b.move(requiredLetter: 'k', usedIds: used)
          case BotPlays(:final city) when city.nameEn == 'Kaa') {
        tierOne++;
      }
    }
    expect(tierOne / draws, closeTo(0.8, 0.02));
  });

  test('is deterministic for a given seed', () {
    List<String> run(int seed) =>
        [for (final c in playOut(bot(Difficulty.hard, seed: seed))) c.nameEn];
    expect(run(5), run(5));
    expect(run(5), isNot(run(6)), reason: 'but varies between seeds');
  });

  group('the per-letter minimum', () {
    CityBot standard(Difficulty difficulty) =>
        CityBot(index: _index, difficulty: difficulty, random: Random(1));
    Set<String> knownOf(CityBot b, String letter) =>
        _names(_index.startingWith(letter).where(b.knows));

    test('adds the best-known cities of each letter, beyond the tiers', () {
      // «k»: Medium's tiers stop at Kae; its 6 best known reach Kaf (tier 3).
      expect(knownOf(standard(Difficulty.medium), 'k'), {
        ..._kVocabulary[Difficulty.medium]!,
        'Kaf',
      });
      // Hard's 10 reach into tier 4: Kai, Kaj.
      expect(knownOf(standard(Difficulty.hard), 'k'), {
        ..._kVocabulary[Difficulty.hard]!,
        'Kai',
        'Kaj',
      });
      // Easy's 2 best «k» are tier 1 anyway.
      expect(
        knownOf(standard(Difficulty.easy), 'k'),
        _kVocabulary[Difficulty.easy],
      );
    });

    test('a letter with fewer cities is known whole, even tier 4', () {
      // «m»: Mia (tier 1) and Mib (tier 4).
      expect(knownOf(standard(Difficulty.easy), 'm'), {'Mia', 'Mib'});
      expect(
        standard(Difficulty.hard).move(requiredLetter: 'm', usedIds: {1}),
        BotPlays(_index.lookup('Mib').single),
      );
    });

    test('is set per difficulty', () {
      expect([for (final d in Difficulty.values) d.minCitiesPerLetter], [
        2,
        6,
        10,
      ]);
    });
  });

  group('Difficulty', () {
    test('harder levels know more, allow less time and pay more', () {
      expect([for (final d in Difficulty.values) d.maxTier], [1, 2, 3]);
      expect(
        [for (final d in Difficulty.values) d.turnTime.inSeconds],
        [45, 30, 20],
      );
      expect([for (final d in Difficulty.values) d.winMultiplier], [1, 2, 3]);
    });
  });

  test('the bot thinks for 0.6–1.2 s, and not always the same time', () {
    final random = Random(3);
    final times = [for (var i = 0; i < 200; i++) botThinkingTime(random)];
    for (final time in times) {
      expect(
        time.inMicroseconds,
        inInclusiveRange(
          botThinkingMin.inMicroseconds,
          botThinkingMax.inMicroseconds,
        ),
      );
    }
    expect(times.toSet().length, greaterThan(100));
  });
}

const _mia =
    City(id: 1, nameEn: 'Mia', countryCode: 'XX', population: 5000);
