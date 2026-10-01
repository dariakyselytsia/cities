import 'package:cities/engine/letter_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LetterRule.requiredNextLetter', () {
    // Ukrainian letters some cities start with. No city starts with «ь» or
    // «и»; «й» is left out as too rare (see LetterMinimums).
    const uk = {
      'а', 'б', 'в', 'г', 'д', 'е', 'ж', 'з', 'і', 'к', 'л', 'м', 'н', 'о', //
      'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'я',
    };
    const en = {
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', //
      'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'y', 'z',
    };

    // (previous city, playable letters, required letter)
    final cases = <(String, Set<String>, String?)>[
      // The last letter, when it's playable.
      ('Львів', uk, 'в'),
      ('Одеса', uk, 'а'),
      // Apostrophes and hyphens are not letters.
      ("Кам'янець", uk, 'ц'),
      ('Кам’янець', uk, 'ц'),
      ('Камʼянець', uk, 'ц'),
      ("Кам'янець-Подільський", uk, 'к'),
      // «ь» is skipped: no city starts with it.
      ('Мелітополь', uk, 'л'),
      ('Ірпінь', uk, 'н'),
      // «и» and «й» are skipped too: back past «-ий» to «к».
      ('Хмельницький', uk, 'к'),
      ('Шанхай', uk, 'а'),
      // Skipping walks back as far as needed: «ї», then «а».
      ('Мумбаї', uk, 'а'),
      // A rare letter is skipped when the list leaves it out (Ukraine list:
      // «ц» → back to «н» past «ь» and «е»).
      ("Кам'янець", uk.difference({'ц', 'е'}), 'н'),
      // …and required when it's playable: the rule is dataset-driven.
      ('Хмельницький', {...uk, 'й'}, 'й'),
      // «ґ» reads as «г».
      ('Беґ', uk, 'г'),
      // Case and spaces don't matter.
      ('  ОДЕСА  ', uk, 'а'),
      ('Біла Церква', uk, 'а'),
      // English: diacritics fold, punctuation and digits are skipped.
      ('Kyiv', en, 'v'),
      ('Kraków', en, 'w'),
      ('São Paulo', en, 'o'),
      ("St. John's", en, 's'),
      ('Seremban 2', en, 'n'),
      ('Halle (Saale)', en, 'e'),
      // «x» and «q» aren't in this English set: skipped.
      ('Halifax', en, 'a'),
      // No playable letter at all: a dead end, any letter will do.
      ('иьй', uk, null),
      ('', uk, null),
    ];

    for (final (previous, letters, expected) in cases) {
      test('"$previous" → ${expected ?? 'any letter'}', () {
        expect(LetterRule.requiredNextLetter(previous, letters), expected);
        expect(
          LetterRule.nextLetterSpan(previous, letters)?.letter,
          expected,
          reason: 'nextLetterSpan agrees',
        );
      });
    }
  });

  group('LetterRule.nextLetterSpan points at the character shown', () {
    const uk = {'а', 'в', 'к', 'л', 'н', 'с', 'ц'};
    const en = {'a', 'o', 'v', 'w'};

    // (name, playable letters, the highlighted text, its start)
    final cases = <(String, Set<String>, String, int)>[
      ('Львів', uk, 'в', 4),
      ('Рівне', uk, 'н', 3),
      ("Кам'янець", uk, 'ц', 7),
      ("Кам'янець", uk.difference({'ц'}), 'н', 5),
      ('  ОДЕСА  ', uk, 'А', 6),
      ('Kraków', en, 'w', 5),
      // A diacritic letter is highlighted as it's written.
      ('Ponta Delgadó', en, 'ó', 12),
      // A letter with a combining mark is one character: «й» = и + ̆.
      ('Хмельницькй', {...uk, 'й'}, 'й', 10),
      // Characters outside the BMP are skipped whole.
      ('Odesa\u{1F642}', en, 'a', 4),
    ];

    for (final (name, letters, text, start) in cases) {
      test('"$name" → «$text» at $start', () {
        final span = LetterRule.nextLetterSpan(name, letters);
        expect(span, isNotNull);
        if (span == null) return;
        expect(span.start, start);
        expect(name.substring(span.start, span.end), text);
      });
    }
  });

  group(
    'LetterRule.letterMarks marks the letters skipped after the next one',
    () {
      // As in the Ukraine list: «е», «ц», «й» start a few cities (too few to
      // be asked for); «ь» and «и» start none.
      const playable = {'к', 'л', 'н', 'р', 'с', 'т', 'х'};
      const starting = {...playable, 'е', 'ц', 'й'};

      String marked(String name) {
        final marks = LetterRule.letterMarks(
          name,
          playable,
          startingLetters: starting,
        );
        String text(LetterSpan span) => name.substring(span.start, span.end);
        final next = marks.next;
        return '${next == null ? '-' : text(next)} '
            '[${marks.skipped.map(text).join(',')}]';
      }

      test('«ь» is not marked, «е» and «ц» are', () {
        expect(marked('Кременець'), 'н [е,ц]');
      });
      test('«и» is not marked, «й» is', () {
        expect(marked('Хмельницький'), 'к [й]');
      });
      test('nothing skipped', () {
        expect(marked('Херсон'), 'н []');
        // «в» and «і» start no city in this set: passed over, not marked.
        expect(marked('Харків'), 'к []');
      });
      test('without starting letters, nothing is skipped', () {
        expect(LetterRule.letterMarks('Кременець', playable).skipped, isEmpty);
      });
    },
  );

  group('LetterRule.startsWithRequired', () {
    test('accepts an answer starting with the required letter', () {
      expect(LetterRule.startsWithRequired('Вінниця', 'в'), isTrue);
      expect(LetterRule.startsWithRequired('вінниця', 'в'), isTrue);
      expect(LetterRule.startsWithRequired('  Вінниця', 'в'), isTrue);
    });

    test('folds the answer like the letter rule does', () {
      expect(LetterRule.startsWithRequired('Ґданськ', 'г'), isTrue);
      expect(LetterRule.startsWithRequired('Århus', 'a'), isTrue);
      expect(LetterRule.startsWithRequired("'s-Hertogenbosch", 's'), isTrue);
    });

    test('rejects an answer starting with another letter', () {
      expect(LetterRule.startsWithRequired('Київ', 'в'), isFalse);
      expect(
        LetterRule.startsWithRequired('Ірпінь', 'и'),
        isFalse,
        reason: 'і and и are different letters',
      );
    });

    test('with no required letter, any answer goes', () {
      expect(LetterRule.startsWithRequired('Київ', null), isTrue);
    });
  });
}
