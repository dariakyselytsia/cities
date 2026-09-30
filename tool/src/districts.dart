/// Finding city districts that GeoNames lists as towns (T23).
///
/// GeoNames codes many districts of big cities as ordinary places (`PPL`,
/// `PPLA2`, …) rather than `PPLX`: Pudong (Shanghai), Üsküdar (Istanbul),
/// Iztapalapa (Mexico City), Paris's arrondissements. CityBot would play them,
/// and players would rightly say they're not cities.
///
/// Two tools, because no single signal is reliable:
/// - [autoDistrictReason]: name patterns and city-states that are safe to
///   exclude **automatically**, list-wide.
/// - [findDistrictCandidates]: a distance heuristic that only **flags**
///   places for human review. It can't decide by itself: Kawasaki and Ōta
///   both sit next to Tokyo, but only Ōta is part of it. A review decision
///   is an `exclude` override (`true` or `false`).
library;

import 'dart:math' as math;

import 'city_builder.dart';

/// City-states whose GeoNames entries, apart from the capital, are
/// neighborhoods and housing estates (Mong Kok, Tuen Mun, Bedok, Taipa).
const Set<String> cityStates = {'HK', 'SG', 'MO'};

/// Name patterns that mark a district, not a city. Each is specific enough to
/// have no false positives in the World list.
final List<(RegExp, String)> _districtPatterns = [
  // Numbered arrondissements: "Paris 15 Vaugirard", "Marseille 01".
  (RegExp(r'^(Paris|Marseille|Lyon) \d'), 'arrondissement'),
  // Japanese wards: "Ōta-ku", "Kamigyō-ku".
  (RegExp(r'-ku$'), 'ward'),
  // Vietnamese urban and rural districts: "Quận Mười", "Huyện Lâm Hà".
  (RegExp(r'^(Quận|Huyện) '), 'district'),
  // Housing estates: "Choi Wan Estate (I & II)", "Imara Daima Estate". The
  // plural is left alone: "Hoffman Estates" is a village.
  (RegExp(r'\bEstate\b'), 'housing estate'),
  // Swiss city districts: "Seen (Kreis 3)".
  (RegExp(r'\(Kreis \d+\)'), 'district'),
  // "Banqiao District", "Chatuchak subdistrict", "District of Taher".
  (RegExp(r'\b(sub)?district\b', caseSensitive: false), 'district'),
];

/// Why [city] is automatically treated as a district, or `null` if it isn't.
///
/// [en] is the chosen English name: GeoNames' main name ("Ōta") sometimes
/// lacks the telltale suffix that the English name has ("Ōta-ku").
String? autoDistrictReason(GeoCity city, String en) {
  if (cityStates.contains(city.countryCode) && !city.isCapital) {
    return 'city-state neighborhood';
  }
  for (final (pattern, reason) in _districtPatterns) {
    if (pattern.hasMatch(city.name) || pattern.hasMatch(en)) return reason;
  }
  return null;
}

/// Places within this distance of a much bigger city are district
/// candidates. 25 km reaches the outer districts of the largest cities
/// (Esenyurt is 23 km from central Istanbul).
const double districtRadiusKm = 25;

/// …where "much bigger" means at least this many times the population.
const int districtPopulationRatio = 3;

/// A place that may be a district of [parent].
class DistrictCandidate {
  const DistrictCandidate(this.city, this.parent, this.distanceKm);

  final GeoCity city;

  /// The biggest city nearby that is [districtPopulationRatio]× bigger.
  final GeoCity parent;
  final double distanceKm;
}

/// Finds every place in [cities] within [districtRadiusKm] of a city in the
/// same country that is [districtPopulationRatio]× bigger. Capitals are
/// never candidates.
///
/// Returns a map keyed by the candidate's id. Uses a 1° grid, so it runs in
/// well under a second on the World list.
Map<int, DistrictCandidate> findDistrictCandidates(List<GeoCity> cities) {
  int cell(double degrees) => degrees.floor();
  final grid = <(int, int), List<GeoCity>>{};
  for (final c in cities) {
    (grid[(cell(c.latitude), cell(c.longitude))] ??= []).add(c);
  }

  final result = <int, DistrictCandidate>{};
  for (final city in cities) {
    if (city.isCapital) continue;
    DistrictCandidate? best;
    final (row, col) = (cell(city.latitude), cell(city.longitude));
    for (var dRow = -1; dRow <= 1; dRow++) {
      for (var dCol = -1; dCol <= 1; dCol++) {
        for (final other in grid[(row + dRow, col + dCol)] ?? const <GeoCity>[]) {
          if (other.countryCode != city.countryCode ||
              other.population < districtPopulationRatio * city.population) {
            continue;
          }
          final distance = distanceKm(city, other);
          if (distance <= districtRadiusKm &&
              (best == null || other.population > best.parent.population)) {
            best = DistrictCandidate(city, other, distance);
          }
        }
      }
    }
    if (best != null) result[city.id] = best;
  }
  return result;
}

/// Great-circle distance between two places, in kilometers (haversine).
double distanceKm(GeoCity a, GeoCity b) {
  const earthRadiusKm = 6371.0;
  double rad(double degrees) => degrees * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLon = rad(b.longitude - a.longitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) *
          math.cos(rad(b.latitude)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(h));
}
