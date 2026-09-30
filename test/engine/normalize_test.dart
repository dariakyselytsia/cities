import 'package:cities/engine/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeName', () {
    // (rule, input, expected)
    const cases = <(String, String, String)>[
      // 1. Case and whitespace.
      ('lowercases Cyrillic', 'КИЇВ', 'київ'),
      ('lowercases Latin', 'NEW YORK', 'new york'),
      ('trims', '  Львів  ', 'львів'),
      ('collapses inner whitespace', 'Нова   Ушиця', 'нова ушиця'),
      ('tabs and non-breaking spaces are spaces', 'Кривий \tРіг', 'кривий ріг'),
      ('empty input stays empty', '   ', ''),

      // 2. Hyphens and other separators become one space.
      ('hyphen', 'Івано-Франківськ', 'івано франківськ'),
      ('en dash', 'Івано–Франківськ', 'івано франківськ'),
      ('spaced hyphen', 'Івано - Франківськ', 'івано франківськ'),
      ('dot', 'St. Louis', 'st louis'),
      ('dot without a space', 'St.Louis', 'st louis'),
      ('brackets', 'Frankfurt (Oder)', 'frankfurt oder'),
      ('slash', 'Biel/Bienne', 'biel bienne'),
      ('trailing punctuation', 'Київ.', 'київ'),
      ('digits are kept', '6th of October City', '6th of october city'),

      // 2. Apostrophes are removed, whatever the keyboard sends.
      ('ASCII apostrophe', "Кам'янець-Подільський", 'камянець подільський'),
      ('right single quote', 'Кам’янець-Подільський', 'камянець подільський'),
      ('modifier apostrophe', 'Камʼянець-Подільський', 'камянець подільський'),
      ('backtick', 'Кам`янець-Подільський', 'камянець подільський'),
      ('no apostrophe', 'Камянець-Подільський', 'камянець подільський'),
      ('English apostrophe', "St. John's", 'st johns'),
      ('ʻokina-style mark', 'Qoʻqon', 'qoqon'),
      ('ayn and hamza marks', 'Biʾr as-Sabʿ', 'bir as sab'),

      // 3. Latin diacritics.
      ('tilde', 'São Paulo', 'sao paulo'),
      ('acute', 'Kraków', 'krakow'),
      ('stroke', 'Łódź', 'lodz'),
      ('sharp s', 'Gießen', 'giessen'),
      ('umlaut', 'Zürich', 'zurich'),
      ('ring', 'Århus', 'arhus'),
      ('slashed o', 'Tromsø', 'tromso'),
      ('ligature', 'Æbeltoft', 'aebeltoft'),
      ('cedilla and breve', 'Şanlıurfa', 'sanliurfa'),
      ('dotted capital I', 'İzmir', 'izmir'),
      ('Vietnamese stacked marks', 'Hà Nội', 'ha noi'),
      ('schwa', 'Gəncə', 'gence'),
      ('dot below', 'Ḩalab', 'halab'),
      ('decomposed accent', 'Bogotá', 'bogota'),

      // 3. Ukrainian.
      ('ґ→г', 'Ґалаґан', 'галаган'),
      ('capital Ґ→г', 'ҐОРҐАНИ', 'горгани'),
      ('ё→е', 'Орёл', 'орел'),
      ('й survives', 'Херсонський', 'херсонський'),
      ('ї survives', 'Їжакевичі', 'їжакевичі'),
      ('decomposed й is recomposed', 'Херсонський', 'херсонський'),
      ('decomposed Latin ï loses its mark', 'Kï', 'ki'),
      ('decomposed Cyrillic ї is recomposed', 'Кїв', 'кїв'),
      ('є stays', 'Єнакієве', 'єнакієве'),
      ('ы stays distinct', 'Сыктывкар', 'сыктывкар'),
      ('э stays distinct', 'Элиста', 'элиста'),
    ];

    for (final (rule, input, expected) in cases) {
      test('$rule: "$input" → "$expected"', () {
        expect(normalizeName(input), expected);
      });
    }

    test('is idempotent', () {
      for (final (_, input, _) in cases) {
        final once = normalizeName(input);
        expect(normalizeName(once), once, reason: input);
      }
    });

    test('distinct letters stay distinct (no typo guessing)', () {
      const pairs = [
        ('Київ', 'Кийв'), // і vs и
        ('Ірпінь', 'Ирпинь'),
        ('Сиктивкар', 'Сыктывкар'), // и vs ы
        ('Єнакієве', 'Енакиеве'), // є vs е
        ('Херсонський', 'Херсонськии'), // й vs и
        ('Paris', 'Pariss'),
      ];
      for (final (a, b) in pairs) {
        expect(normalizeName(a), isNot(normalizeName(b)), reason: '$a vs $b');
      }
    });
  });
}
