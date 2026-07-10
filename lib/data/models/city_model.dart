import 'package:isar_community/isar.dart';
import '../../domain/entities/city.dart';

part 'city_model.g.dart';

/// Isar model for City, used for local database storage.
@Collection()
class CityModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String nameUA;
  @Index()
  late String nameEN;
  late String countryCode;
  late bool isCapital;
  @Index()
  late String firstLetterUA;
  @Index()
  late String firstLetterEN;

  CityModel();

  CityModel.fromDomain(City city) {
    id = city.id;
    nameUA = city.nameUA;
    nameEN = city.nameEN;
    countryCode = city.countryCode;
    isCapital = city.isCapital;
    firstLetterUA = city.firstLetterUA;
    firstLetterEN = city.firstLetterEN;
  }

  City toDomain() => City(
    id: id,
    nameUA: nameUA,
    nameEN: nameEN,
    countryCode: countryCode,
    isCapital: isCapital,
    firstLetterUA: firstLetterUA,
    firstLetterEN: firstLetterEN,
  );
}
