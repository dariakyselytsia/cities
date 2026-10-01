import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';

City _city(int id, String name, int population) =>
    City(id: id, nameEn: name, countryCode: 'XX', population: population);

/// One city per first letter, so every move and hint is predictable:
/// Kyiv → «v» Vilnius → «s» Seoul → «l» Lima → «a» Ankara.
final kyiv = _city(1, 'Kyiv', 900000);
final vilnius = _city(2, 'Vilnius', 800000);
final seoul = _city(3, 'Seoul', 700000);
final lima = _city(4, 'Lima', 600000);
final ankara = _city(5, 'Ankara', 500000);

/// The five cities as an English World list.
final chainIndex = CityCatalog(
  [kyiv, vilnius, seoul, lima, ankara],
  letterMinimums: const LetterMinimums(ukraine: 1, world: 1),
).index(CityListKind.world, NameLanguage.en);
