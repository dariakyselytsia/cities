import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import '../models/city_model.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementation of CityRepository using Isar for local storage.
@LazySingleton(as: CityRepository)
class CityRepositoryImpl implements CityRepository {
  final Isar isar;
  CityRepositoryImpl(this.isar);

  IsarCollection<CityModel> get cityModels => isar.collection<CityModel>();

  @override
  Future<List<City>> loadCities({required bool isUkraineMode}) async {
    final assetPath = isUkraineMode
        ? 'assets/data/cities_ua.json'
        : 'assets/data/cities_world.json';
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonList = json.decode(jsonString);
    final cities = jsonList
        .map(
          (e) => CityModel()
            ..id = e['id']
            ..nameUA = e['nameUA']
            ..nameEN = e['nameEN']
            ..countryCode = e['countryCode']
            ..isCapital = e['isCapital']
            ..firstLetterUA = e['firstLetterUA']
            ..firstLetterEN = e['firstLetterEN'],
        )
        .toList();
    // Save to Isar for fast lookup
    await isar.writeTxn(() async {
      await cityModels.putAll(cities);
    });
    return cities.map((c) => c.toDomain()).toList();
  }

  @override
  Future<Set<String>> availableFirstLetters({
    required bool isUkraineMode,
  }) async {
    final cities = await loadCities(isUkraineMode: isUkraineMode);
    return cities
        .map((c) =>
            (isUkraineMode ? c.firstLetterUA : c.firstLetterEN).toLowerCase())
        .where((letter) => letter.isNotEmpty)
        .toSet();
  }

  @override
  Future<City?> getCityByName(String name, {required bool isUA}) async {
    // Indexed lookup on the name field (see @Index on CityModel.nameUA/nameEN).
    final model = isUA
        ? await cityModels.where().nameUAEqualTo(name).findFirst()
        : await cityModels.where().nameENEqualTo(name).findFirst();
    return model?.toDomain();
  }
}
