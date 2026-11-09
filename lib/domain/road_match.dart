/// Road types and traffic lights along a trip, worked out by matching the
/// GPS track against OpenStreetMap data. Pure functions, tested directly;
/// fetching the map data lives in lib/trips/road_lookup.dart.
library;

import 'dart:math' as math;

import 'trip_stats.dart';

typedef LL = ({double lat, double lon});

enum RoadClass { motorway, main, suburban, local, other }

String roadLabel(RoadClass c) => switch (c) {
      RoadClass.motorway => 'Motorway',
      RoadClass.main => 'Highway / main road',
      RoadClass.suburban => 'Suburban road',
      RoadClass.local => 'Local street',
      RoadClass.other => 'Other',
    };

/// OpenStreetMap `highway=*` values grouped the way a driver thinks of them.
/// Most NZ state highways are tagged trunk or primary.
RoadClass? roadClassFor(String highway) => switch (highway) {
      'motorway' || 'motorway_link' => RoadClass.motorway,
      'trunk' || 'trunk_link' || 'primary' || 'primary_link' => RoadClass.main,
      'secondary' || 'secondary_link' || 'tertiary' || 'tertiary_link' => RoadClass.suburban,
      'residential' || 'unclassified' || 'living_street' || 'road' => RoadClass.local,
      _ => null,
    };

const _highwayRegex =
    '^(motorway|motorway_link|trunk|trunk_link|primary|primary_link|secondary|secondary_link|tertiary|tertiary_link|residential|unclassified|living_street|road)\$';

class OsmWay {
  final RoadClass cls;
  final List<LL> pts;
  /// Name of the toll road when the way is tagged `toll=yes`.
  final String? toll;
  const OsmWay(this.cls, this.pts, {this.toll});
}

/// A toll road driven on a trip.
class TollUse {
  final String name;
  final double km;
  const TollUse(this.name, this.km);
}

/// Less than this on a toll way is treated as a GPS mix-up with a road
/// alongside it.
const double tollMinKm = 0.4;

/// Traffic signal nodes and roads near a route, keyed by OSM id so results
/// from several queries can be merged without duplicates.
class OsmArea {
  final Map<int, LL> signals;
  final Map<int, OsmWay> ways;
  const OsmArea(this.signals, this.ways);

  static const empty = OsmArea({}, {});

  static OsmArea fromOverpass(Map<String, Object?> json) {
    final signals = <int, LL>{};
    final ways = <int, OsmWay>{};
    for (final e in (json['elements'] as List? ?? const [])) {
      if (e is! Map) continue;
      final id = (e['id'] as num?)?.toInt();
      if (id == null) continue;
      if (e['type'] == 'node' && e['lat'] is num && e['lon'] is num) {
        signals[id] = (lat: (e['lat'] as num).toDouble(), lon: (e['lon'] as num).toDouble());
      } else if (e['type'] == 'way') {
        final tags = (e['tags'] as Map?) ?? const {};
        final cls = roadClassFor((tags['highway'] as String?) ?? '');
        final geom = e['geometry'] as List?;
        if (cls == null || geom == null || geom.length < 2) continue;
        final toll = tags['toll'] == 'yes' || tags['toll:motorcar'] == 'yes'
            ? ((tags['official_name'] ?? tags['name'] ?? tags['ref'] ?? 'Toll road') as String)
            : null;
        ways[id] = OsmWay(cls, [
          for (final g in geom)
            if (g is Map && g['lat'] is num) (lat: (g['lat'] as num).toDouble(), lon: (g['lon'] as num).toDouble()),
        ], toll: toll);
      }
    }
    return OsmArea(signals, ways);
  }

  OsmArea merge(OsmArea o) => OsmArea({...signals, ...o.signals}, {...ways, ...o.ways});
}

/// A set of traffic signals at one intersection, as passed on the trip.
class LightPass {
  final double lat, lon;
  final bool stopped;
  const LightPass(this.lat, this.lon, this.stopped);
}

class RoadStats {
  final Map<RoadClass, double> roadKm;
  final List<LightPass> lights;
  final Duration waitAtLights;
  final List<TollUse> tolls;
  const RoadStats({required this.roadKm, required this.lights, required this.waitAtLights, this.tolls = const []});

  int get lightsPassed => lights.length;
  int get stoppedAtLights => lights.where((l) => l.stopped).length;

  Map<String, Object?> toJson() => {
        'roadKm': {for (final e in roadKm.entries) e.key.name: double.parse(e.value.toStringAsFixed(3))},
        'lights': [
          for (final l in lights) [double.parse(l.lat.toStringAsFixed(5)), double.parse(l.lon.toStringAsFixed(5)), l.stopped ? 1 : 0],
        ],
        'waitS': waitAtLights.inSeconds,
        if (tolls.isNotEmpty) 'tolls': [for (final t in tolls) [t.name, double.parse(t.km.toStringAsFixed(2))]],
      };

  static RoadStats fromJson(Map<String, Object?> j) {
    final km = (j['roadKm'] as Map?) ?? const {};
    return RoadStats(
      roadKm: {
        for (final c in RoadClass.values)
          if (km[c.name] is num) c: (km[c.name] as num).toDouble(),
      },
      lights: [
        for (final l in (j['lights'] as List? ?? const []))
          if (l is List && l.length >= 3) LightPass((l[0] as num).toDouble(), (l[1] as num).toDouble(), l[2] == 1),
      ],
      waitAtLights: Duration(seconds: (j['waitS'] as num?)?.toInt() ?? 0),
      tolls: [
        for (final t in (j['tolls'] as List? ?? const []))
          if (t is List && t.length >= 2 && t[0] is String) TollUse(t[0] as String, (t[1] as num).toDouble()),
      ],
    );
  }
}

// ---- tuning ----
const double roadMatchM = 25; // GPS point to road centre line
const double roadAngleDeg = 35; // heading must roughly follow the road
const double signalClusterM = 45; // signal nodes this close are one intersection
const double lightOnRouteM = 25; // route passes this close to a signal node
const double lightStopM = 50; // a stop this close to an intersection waited at it
const Duration lightStopMax = Duration(minutes: 5);

// ---- geometry in local metres ----
const _mPerDegLat = 110574.0;
double _mPerDegLon(double lat) => 111320.0 * math.cos(lat * math.pi / 180);

/// Distance in metres from p to the segment a–b, and the segment's bearing
/// in degrees (0–180, direction ignored).
({double dist, double bearing}) _toSegment(LL p, LL a, LL b) {
  final kx = _mPerDegLon(p.lat);
  final ax = (a.lon - p.lon) * kx, ay = (a.lat - p.lat) * _mPerDegLat;
  final bx = (b.lon - p.lon) * kx, by = (b.lat - p.lat) * _mPerDegLat;
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : -(ax * dx + ay * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final cx = ax + t * dx, cy = ay + t * dy;
  return (dist: math.sqrt(cx * cx + cy * cy), bearing: _bearing180(dx, dy));
}

double _bearing180(double dx, double dy) {
  var deg = math.atan2(dx, dy) * 180 / math.pi;
  if (deg < 0) deg += 180;
  if (deg >= 180) deg -= 180;
  return deg;
}

double _angleDiff(double a, double b) {
  final d = (a - b).abs() % 180;
  return d > 90 ? 180 - d : d;
}

double metresBetween(LL a, LL b) => haversineKm(a.lat, a.lon, b.lat, b.lon) * 1000;

/// Buckets line segments into ~200 m cells so nearby lookups stay fast on
/// long trips.
class _SegGrid<T> {
  static const cell = 0.002;
  final _cells = <(int, int), List<(LL, LL, T)>>{};

  (int, int) _key(double lat, double lon) => ((lat / cell).floor(), (lon / cell).floor());

  void add(LL a, LL b, T tag) {
    final k1 = _key(math.min(a.lat, b.lat), math.min(a.lon, b.lon));
    final k2 = _key(math.max(a.lat, b.lat), math.max(a.lon, b.lon));
    for (var i = k1.$1; i <= k2.$1; i++) {
      for (var j = k1.$2; j <= k2.$2; j++) {
        (_cells[(i, j)] ??= []).add((a, b, tag));
      }
    }
  }

  Iterable<(LL, LL, T)> near(LL p) sync* {
    final k = _key(p.lat, p.lon);
    for (var i = -1; i <= 1; i++) {
      for (var j = -1; j <= 1; j++) {
        final list = _cells[(k.$1 + i, k.$2 + j)];
        if (list != null) yield* list;
      }
    }
  }
}

List<GpsSample> _clean(List<GpsSample> raw) =>
    raw.where((s) => (s.accuracyM ?? 0) <= maxAccuracyM).toList()..sort((a, b) => a.at.compareTo(b.at));

/// Matches the track to roads and traffic lights. Distance uses the same
/// moving segments as [computeTripStats], so the road split adds up to the
/// trip distance (anything not near a known road counts as "Other").
RoadStats matchRoads(List<GpsSample> raw, OsmArea osm) {
  final pts = _clean(raw);

  final roads = _SegGrid<OsmWay>();
  for (final w in osm.ways.values) {
    for (var i = 1; i < w.pts.length; i++) {
      roads.add(w.pts[i - 1], w.pts[i], w);
    }
  }

  final roadKm = <RoadClass, double>{};
  final tollKm = <String, double>{};
  final route = _SegGrid<void>();
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    final dt = b.at.difference(a.at);
    if (dt <= Duration.zero) continue;
    final segKm = haversineKm(a.lat, a.lon, b.lat, b.lon);
    final hours = dt.inMilliseconds / 3600000;
    if (segKm / hours > 250) continue;
    final la = (lat: a.lat, lon: a.lon), lb = (lat: b.lat, lon: b.lon);
    route.add(la, lb, null);
    final kmh = b.speedMps != null ? b.speedMps! * 3.6 : segKm / hours;
    if (kmh < stillKmh) continue;

    final mid = (lat: (a.lat + b.lat) / 2, lon: (a.lon + b.lon) / 2);
    final kx = _mPerDegLon(mid.lat);
    final heading = segKm * 1000 >= 5 ? _bearing180((b.lon - a.lon) * kx, (b.lat - a.lat) * _mPerDegLat) : null;
    OsmWay? best;
    var bestScore = double.infinity;
    for (final (p, q, way) in roads.near(mid)) {
      final r = _toSegment(mid, p, q);
      if (r.dist > roadMatchM) continue;
      final ang = heading == null ? 0.0 : _angleDiff(heading, r.bearing);
      if (ang > roadAngleDeg) continue;
      final score = r.dist + ang * 0.3;
      if (score < bestScore) {
        bestScore = score;
        best = way;
      }
    }
    final cls = best?.cls ?? RoadClass.other;
    roadKm[cls] = (roadKm[cls] ?? 0) + segKm;
    final toll = best?.toll;
    if (toll != null) tollKm[toll] = (tollKm[toll] ?? 0) + segKm;
  }

  // Group signal nodes into intersections (one per approach is common).
  final clusters = <List<LL>>[];
  for (final s in osm.signals.values) {
    final hit = clusters.where((c) => metresBetween(c.first, s) <= signalClusterM).firstOrNull;
    if (hit != null) {
      hit.add(s);
    } else {
      clusters.add([s]);
    }
  }
  final passed = <List<LL>>[];
  for (final c in clusters) {
    final onRoute = c.any((s) => route.near(s).any((seg) => _toSegment(s, seg.$1, seg.$2).dist <= lightOnRouteM));
    if (onRoute) passed.add(c);
  }

  // Stops (short and long) near an intersection that was passed.
  final stats = computeTripStats(raw);
  final stoppedAt = <int>{};
  var wait = Duration.zero;
  for (final span in [...stats.shortStopSpans, ...stats.stops]) {
    if (span.duration > lightStopMax) continue;
    final p = (lat: span.lat, lon: span.lon);
    var bestI = -1;
    var bestD = double.infinity;
    for (var i = 0; i < passed.length; i++) {
      for (final s in passed[i]) {
        final d = metresBetween(p, s);
        if (d <= lightStopM && d < bestD) {
          bestD = d;
          bestI = i;
        }
      }
    }
    if (bestI >= 0) {
      stoppedAt.add(bestI);
      wait += span.duration;
    }
  }

  return RoadStats(
    roadKm: roadKm,
    lights: [
      for (var i = 0; i < passed.length; i++)
        LightPass(
          passed[i].map((s) => s.lat).reduce((a, b) => a + b) / passed[i].length,
          passed[i].map((s) => s.lon).reduce((a, b) => a + b) / passed[i].length,
          stoppedAt.contains(i),
        ),
    ],
    waitAtLights: wait,
    tolls: [
      for (final e in tollKm.entries)
        if (e.value >= tollMinKm) TollUse(e.key, e.value),
    ],
  );
}

/// The route as simplified polylines for map queries. The first and last
/// [trimM] metres are left off so the start and end (often home) aren't
/// sent anywhere. Each polyline has at most [maxPoints] points.
List<List<LL>> queryLines(List<GpsSample> raw, {double trimM = 300, double toleranceM = 15, int maxPoints = 150}) {
  final pts = [for (final s in _clean(raw)) (lat: s.lat, lon: s.lon)];
  if (pts.length < 2) return const [];
  final cum = <double>[0];
  for (var i = 1; i < pts.length; i++) {
    cum.add(cum.last + metresBetween(pts[i - 1], pts[i]));
  }
  final total = cum.last;
  if (total <= trimM * 2 + 100) return const [];
  final kept = [
    for (var i = 0; i < pts.length; i++)
      if (cum[i] >= trimM && cum[i] <= total - trimM) pts[i],
  ];
  if (kept.length < 2) return const [];
  final simple = _douglasPeucker(kept, toleranceM);
  final out = <List<LL>>[];
  for (var i = 0; i < simple.length - 1; i += maxPoints - 1) {
    out.add(simple.sublist(i, math.min(simple.length, i + maxPoints)));
  }
  return out;
}

List<LL> _douglasPeucker(List<LL> pts, double tol) {
  if (pts.length < 3) return pts;
  final keep = List<bool>.filled(pts.length, false);
  keep[0] = keep[pts.length - 1] = true;
  final stack = <(int, int)>[(0, pts.length - 1)];
  while (stack.isNotEmpty) {
    final (s, e) = stack.removeLast();
    var maxD = 0.0;
    var idx = -1;
    for (var i = s + 1; i < e; i++) {
      final d = _toSegment(pts[i], pts[s], pts[e]).dist;
      if (d > maxD) {
        maxD = d;
        idx = i;
      }
    }
    if (idx >= 0 && maxD > tol) {
      keep[idx] = true;
      stack
        ..add((s, idx))
        ..add((idx, e));
    }
  }
  return [for (var i = 0; i < pts.length; i++) if (keep[i]) pts[i]];
}

/// Overpass QL for traffic signals and drivable roads along [line].
String overpassQuery(List<LL> line) {
  final coords = line.map((p) => '${p.lat.toStringAsFixed(5)},${p.lon.toStringAsFixed(5)}').join(',');
  return '[out:json][timeout:60];'
      'node["highway"="traffic_signals"](around:${lightOnRouteM.round() + 15},$coords);out skel qt;'
      'way["highway"~"$_highwayRegex"](around:${roadMatchM.round() + 10},$coords);out geom qt;';
}

/// Share of the distance on each road type.
Map<RoadClass, double> roadShares(Map<RoadClass, double> km) {
  final total = km.values.fold(0.0, (a, b) => a + b);
  if (total <= 0) return const {};
  return {for (final e in km.entries) e.key: e.value / total};
}
