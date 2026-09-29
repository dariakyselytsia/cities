import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/ua_translit.dart';

/// Checks the KMU No. 55 (2010) transliteration against the resolution's own
/// examples and the official romanized names of Ukrainian cities.
void main() {
  const cases = <String, String>{
    // Cities: the official names used on maps, signs and by the MFA.
    'Київ': 'Kyiv',
    'Харків': 'Kharkiv',
    'Одеса': 'Odesa',
    'Запоріжжя': 'Zaporizhzhia',
    'Кривий Ріг': 'Kryvyi Rih',
    'Миколаїв': 'Mykolaiv',
    'Вінниця': 'Vinnytsia',
    'Кам\'янське': 'Kamianske',
    'Кам’янець-Подільський': 'Kamianets-Podilskyi',
    'Івано-Франківськ': 'Ivano-Frankivsk',
    'Біла Церква': 'Bila Tserkva',
    'Ізмаїл': 'Izmail',
    'Чорноморськ': 'Chornomorsk',
    'Ужгород': 'Uzhhorod',
    'Щастя': 'Shchastia',
    // Positional letters at the start of a word vs inside it.
    'Євпаторія': 'Yevpatoriia',
    'Єнакієве': 'Yenakiieve',
    'Їжакевич': 'Yizhakevych',
    'Кадиївка': 'Kadyivka',
    'Йосипівка': 'Yosypivka',
    'Стрий': 'Stryi',
    'Юрій': 'Yurii',
    'Корюківка': 'Koriukivka',
    'Яготин': 'Yahotyn',
    'Костянтин': 'Kostiantyn',
    'Нова Ушиця': 'Nova Ushytsia',
    // "зг" → "zgh", so it isn't read as "zh".
    'Згорани': 'Zghorany',
    'Розгон': 'Rozghon',
    // Ґ → G, Г → H.
    'Ґалаґан': 'Galagan',
    'Гадяч': 'Hadiach',
    // Soft sign dropped.
    'Львів': 'Lviv',
    'Біловодськ': 'Bilovodsk',
  };

  for (final MapEntry(key: uk, value: expected) in cases.entries) {
    test('$uk → $expected', () {
      expect(transliterateUk(uk), expected);
    });
  }
}
