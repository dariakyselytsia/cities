import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/city_builder.dart';
import '../../tool/src/districts.dart';

/// Covers the T23 district rules with places shaped like the real dump.
void main() {
  GeoCity place(
    String name, {
    int id = 1,
    String cc = 'XX',
    String featureCode = 'PPL',
    int population = 100000,
    double latitude = 0,
    double longitude = 0,
  }) =>
      GeoCity(
        id: id,
        name: name,
        featureCode: featureCode,
        countryCode: cc,
        population: population,
        latitude: latitude,
        longitude: longitude,
      );

  group('autoDistrictReason', () {
    test('matches the district name patterns', () {
      const districts = {
        'Paris 15 Vaugirard': 'arrondissement',
        'Marseille 01': 'arrondissement',
        'Kamigyō-ku': 'ward',
        'Quận Mười': 'district',
        'Huyện Lâm Hà': 'district',
        'Imara Daima Estate': 'housing estate',
        'Seen (Kreis 3)': 'district',
        'Banqiao District': 'district',
        'Chatuchak subdistrict': 'district',
        'District of Taher': 'district',
      };
      for (final MapEntry(key: name, value: reason) in districts.entries) {
        expect(autoDistrictReason(place(name), name), reason, reason: name);
      }
    });

    test('checks the English name too', () {
      // GeoNames' main name is "Ōta"; only the English name says "-ku".
      expect(autoDistrictReason(place('Ōta'), 'Ōta-ku'), 'ward');
    });

    test('leaves real cities alone', () {
      for (final name in [
        'Paris',
        'Hoffman Estates', // a village: plural "Estates"
        'Baku',
        'Kyiv',
        'Mile 91',
        'Frankfurt (Oder)',
        'Parisville',
      ]) {
        expect(autoDistrictReason(place(name), name), isNull, reason: name);
      }
    });

    test('keeps only the capital of a city-state', () {
      expect(
        autoDistrictReason(
          place('Hong Kong', cc: 'HK', featureCode: 'PPLC'),
          'Hong Kong',
        ),
        isNull,
      );
      expect(
        autoDistrictReason(place('Mong Kok', cc: 'HK'), 'Mong Kok'),
        'city-state neighborhood',
      );
      expect(
        autoDistrictReason(place('Bedok', cc: 'SG'), 'Bedok'),
        'city-state neighborhood',
      );
    });
  });

  group('findDistrictCandidates', () {
    final shanghai = place(
      'Shanghai',
      id: 1,
      cc: 'CN',
      featureCode: 'PPLA',
      population: 24874500,
      latitude: 31.22222,
      longitude: 121.45806,
    );

    test('flags a much smaller place next to a big city', () {
      final pudong = place(
        'Pudong',
        id: 2,
        cc: 'CN',
        population: 5681512,
        latitude: 31.22,
        longitude: 121.5,
      );

      final candidates = findDistrictCandidates([shanghai, pudong]);

      expect(candidates.keys, [2]);
      expect(candidates[2]?.parent, shanghai);
      expect(candidates[2]?.distanceKm, closeTo(4, 0.5));
    });

    test('picks the biggest city nearby as the parent', () {
      final medium = place(
        'Medium',
        id: 2,
        cc: 'CN',
        population: 3000000,
        latitude: 31.25,
        longitude: 121.45,
      );
      final small = place(
        'Small',
        id: 3,
        cc: 'CN',
        population: 500000,
        latitude: 31.24,
        longitude: 121.46,
      );

      final candidates = findDistrictCandidates([medium, small, shanghai]);

      expect(candidates[3]?.parent, shanghai);
    });

    test('ignores places that are far away, similar in size, abroad, or '
        'capitals', () {
      final far = place(
        'Far',
        id: 2,
        cc: 'CN',
        population: 100000,
        latitude: 31.5,
        longitude: 121.46, // ~31 km north
      );
      final bigNeighbor = place(
        'Big neighbor',
        id: 3,
        cc: 'CN',
        population: 9000000, // less than 3× smaller
        latitude: 31.23,
        longitude: 121.47,
      );
      final abroad = place(
        'Abroad',
        id: 4,
        cc: 'JP',
        population: 100000,
        latitude: 31.23,
        longitude: 121.46,
      );
      final capital = place(
        'Capital',
        id: 5,
        cc: 'CN',
        featureCode: 'PPLC',
        population: 100000,
        latitude: 31.23,
        longitude: 121.46,
      );

      final candidates =
          findDistrictCandidates([shanghai, far, bigNeighbor, abroad, capital]);

      expect(candidates, isEmpty);
    });

    test('finds neighbors across grid cells', () {
      // Just either side of the 31° grid line.
      final north = place(
        'North',
        id: 1,
        population: 3000000,
        latitude: 31.01,
        longitude: 121.5,
      );
      final south = place(
        'South',
        id: 2,
        population: 100000,
        latitude: 30.99,
        longitude: 121.5,
      );

      expect(findDistrictCandidates([north, south]).keys, [2]);
    });
  });

  test('distanceKm matches a known distance (Kyiv–Lviv ≈ 469 km)', () {
    final kyiv = place('Kyiv', latitude: 50.45466, longitude: 30.5238);
    final lviv = place('Lviv', latitude: 49.83826, longitude: 24.02324);

    expect(distanceKm(kyiv, lviv), closeTo(469, 3));
  });
}
