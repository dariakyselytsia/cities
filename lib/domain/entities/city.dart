/// Domain entity representing a City for the Cities game.
class City {
  final int id;
  final String nameUA;
  final String nameEN;
  final String countryCode;
  final bool isCapital;
  final String firstLetterUA;
  final String firstLetterEN;

  const City({
    required this.id,
    required this.nameUA,
    required this.nameEN,
    required this.countryCode,
    required this.isCapital,
    required this.firstLetterUA,
    required this.firstLetterEN,
  });
}
