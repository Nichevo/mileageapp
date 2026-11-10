/// Places you name (Home, Work…), learned from where trips start and end.
/// Kept on the phone only.
library;

import 'dart:convert';

import 'trip_stats.dart' show haversineKm;

typedef LatLon = ({double lat, double lon});

class Place {
  final String id;
  final String name;
  final double lat, lon;
  const Place(this.id, this.name, this.lat, this.lon);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'lat': lat, 'lon': lon};
  static Place fromJson(Map<String, Object?> j) =>
      Place(j['id'] as String, j['name'] as String, (j['lat'] as num).toDouble(), (j['lon'] as num).toDouble());

  static List<Place> listFromJson(String? s) => s == null || s.isEmpty
      ? const []
      : [for (final m in (jsonDecode(s) as List)) Place.fromJson((m as Map).cast<String, Object?>())];
  static String listToJson(List<Place> p) => jsonEncode([for (final x in p) x.toJson()]);
}

/// A trip end within this distance of a place is "at" it.
const double placeRadiusM = 200;

Place? placeAt(LatLon? p, List<Place> places) {
  if (p == null) return null;
  Place? best;
  var bestM = placeRadiusM;
  for (final pl in places) {
    final m = haversineKm(p.lat, p.lon, pl.lat, pl.lon) * 1000;
    if (m <= bestM) {
      bestM = m;
      best = pl;
    }
  }
  return best;
}

/// Spots where trips often start or end that aren't named yet: clusters of
/// at least [minCount] trip starts or ends within [radiusM], biggest first.
List<({LatLon at, int count})> suggestPlaces(List<LatLon> ends, List<Place> places, {int minCount = 2, double radiusM = 150}) {
  final clusters = <({List<LatLon> pts})>[];
  for (final e in ends) {
    if (placeAt(e, places) != null) continue;
    final hit = clusters.where((c) => haversineKm(c.pts.first.lat, c.pts.first.lon, e.lat, e.lon) * 1000 <= radiusM).firstOrNull;
    if (hit != null) {
      hit.pts.add(e);
    } else {
      clusters.add((pts: [e]));
    }
  }
  final out = [
    for (final c in clusters)
      if (c.pts.length >= minCount)
        (
          at: (
            lat: c.pts.map((p) => p.lat).reduce((a, b) => a + b) / c.pts.length,
            lon: c.pts.map((p) => p.lon).reduce((a, b) => a + b) / c.pts.length,
          ),
          count: c.pts.length,
        ),
  ]..sort((a, b) => b.count.compareTo(a.count));
  return out;
}

/// "Home → Work", "Round trip from Home", "From Home", "To Work", or null
/// when neither end is a named place.
String? placeTitle(Place? from, Place? to) {
  if (from != null && to != null) return from.id == to.id ? 'Round trip from ${from.name}' : '${from.name} → ${to.name}';
  if (from != null) return 'From ${from.name}';
  if (to != null) return 'To ${to.name}';
  return null;
}
