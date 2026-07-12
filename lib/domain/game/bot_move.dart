import 'package:equatable/equatable.dart';

import '../entities/city.dart';

/// CityBot's chosen move: the [city] it names, plus the [nextLetter] the
/// player's answer must then start with (uppercase, per the dataset-driven
/// letter rule) — or null when it can't be determined (a dead-end city).
class BotMove extends Equatable {
  final City city;
  final String? nextLetter;

  const BotMove({required this.city, this.nextLetter});

  @override
  List<Object?> get props => [city, nextLetter];
}
