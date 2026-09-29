import 'package:flutter_test/flutter_test.dart';
import 'package:cities/engine/letter_rule.dart';

void main() {
  group('LetterRule.requiredNextLetter', () {
    // A realistic-ish set of Ukrainian first letters. Note the soft sign 'ь'
    // and 'и' are absent (no city starts with them) so they must be skipped.
    final ukLetters = {'к', 'а', 'о', 'л', 'д', 'п', 'х', 'в', 'с'};

    test('returns the last letter when it is playable', () {
      expect(LetterRule.requiredNextLetter('Львів', ukLetters), 'в');
    });

    test('skips a trailing soft sign (ь) and backtracks to the previous letter',
        () {
      // "Харків" ends in 'в' (playable) — use a word ending in ь to prove skip.
      expect(LetterRule.requiredNextLetter('Мелітополь', ukLetters), 'л');
    });

    test('skips multiple unplayable trailing letters', () {
      // Ends with 'и','й' etc. that are not in the set -> backtrack to 'к'.
      expect(LetterRule.requiredNextLetter('Донецький', ukLetters), 'к');
    });

    test('is case-insensitive and trims whitespace', () {
      expect(LetterRule.requiredNextLetter('  ОДЕСА  ', ukLetters), 'а');
    });

    test('returns null when no trailing letter is playable', () {
      expect(LetterRule.requiredNextLetter('иьй', ukLetters), isNull);
    });

    test('returns null for an empty string', () {
      expect(LetterRule.requiredNextLetter('', ukLetters), isNull);
    });
  });

  group('LetterRule.isValidNext', () {
    final letters = {'к', 'а', 'л', 'в'};

    test('opening move (empty previous) is always valid', () {
      expect(
        LetterRule.isValidNext(
          previousCity: '',
          candidateFirstLetter: 'К',
          availableFirstLetters: letters,
        ),
        isTrue,
      );
    });

    test('valid when candidate starts with the required letter', () {
      // "Львів" -> required 'в'; candidate starting with 'В' is valid.
      expect(
        LetterRule.isValidNext(
          previousCity: 'Львів',
          candidateFirstLetter: 'В',
          availableFirstLetters: letters,
        ),
        isTrue,
      );
    });

    test('invalid when candidate starts with the wrong letter', () {
      expect(
        LetterRule.isValidNext(
          previousCity: 'Львів',
          candidateFirstLetter: 'К',
          availableFirstLetters: letters,
        ),
        isFalse,
      );
    });

    test('invalid when the previous city is a dead end', () {
      expect(
        LetterRule.isValidNext(
          previousCity: 'ь',
          candidateFirstLetter: 'к',
          availableFirstLetters: letters,
        ),
        isFalse,
      );
    });
  });
}
