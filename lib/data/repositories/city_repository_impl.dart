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
  Future<City?> getCityByName(String name, {required bool isUA}) async {
    // Fallback: manual filtering if codegen is not available
    final allCities = await cityModels.where().findAll();
    CityModel? city;
    try {
      city = isUA
          ? allCities.firstWhere((c) => c.nameUA == name)
          : allCities.firstWhere((c) => c.nameEN == name);
    } catch (_) {
      city = null;
    }
    return city?.toDomain();
  }
}
