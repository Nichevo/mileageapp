import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/trips/road_lookup.dart';
import 'package:mileagelog/domain/road_match.dart';
import 'package:mileagelog/domain/trip_stats.dart';

const lat0 = -41.2;

/// Drives east along lat0 at 50 km/h from [fromLon] to [toLon], sampling
/// every 2 s, stopping for [stopFor] when first passing each of [stopAt].
List<GpsSample> drive(double fromLon, double toLon, {List<double> stopAt = const [], Duration stopFor = const Duration(seconds: 30)}) {
  const mps = 50 / 3.6;
  final stepLon = mps * 2 / (111320 * 0.75233); // cos(41.2°)
  var t = DateTime(2026, 11, 8, 8);
  var lon = fromLon;
  final out = <GpsSample>[];
  final pending = [...stopAt];
  while (lon <= toLon) {
    out.add(GpsSample(t, lat0, lon, speedMps: mps, accuracyM: 5));
    t = t.add(const Duration(seconds: 2));
    if (pending.isNotEmpty && lon >= pending.first) {
      pending.removeAt(0);
      for (var i = 0; i < stopFor.inSeconds ~/ 2; i++) {
        out.add(GpsSample(t, lat0, lon, speedMps: 0, accuracyM: 5));
        t = t.add(const Duration(seconds: 2));
      }
    }
    lon += stepLon;
  }
  return out;
}

Map<String, Object?> way(int id, String highway, List<List<double>> pts) => {
  'type': 'way',
  'id': id,
  'tags': {'highway': highway},
  'geometry': [
    for (final p in pts) {'lat': p[0], 'lon': p[1]},
  ],
};

Map<String, Object?> node(int id, double lat, double lon) => {'type': 'node', 'id': id, 'lat': lat, 'lon': lon};

OsmArea area() => OsmArea.fromOverpass({'elements': _elements});

final _elements = [
  // Two signal nodes at one intersection, either side of the road.
  node(1, lat0 + 0.00012, 174.7100), node(2, lat0 - 0.00012, 174.7101),
  node(3, lat0 + 0.00008, 174.7200), // driven through on green
  node(4, lat0 + 0.0030, 174.7250), // 330 m away, not on the route
  way(10, 'primary', [
    [lat0, 174.69],
    [lat0, 174.74],
  ]),
  way(11, 'residential', [
    [lat0 + 0.00036, 174.69],
    [lat0 + 0.00036, 174.74],
  ]), // parallel, 40 m north
  way(12, 'residential', [
    [lat0 - 0.01, 174.715],
    [lat0 + 0.01, 174.715],
  ]), // crossing street
  way(13, 'footway', [
    [lat0, 174.69],
    [lat0, 174.74],
  ]), // ignored
];

void main() {
  lookupTests();
  test('distance goes to the road being driven, not nearby ones', () {
    final samples = drive(174.700, 174.730, stopAt: [174.7097]);
    final r = matchRoads(samples, area());
    final total = computeTripStats(samples).distanceKm;
    expect(r.roadKm.values.fold(0.0, (a, b) => a + b), closeTo(total, 0.001));
    expect(r.roadKm[RoadClass.main], closeTo(total, 0.001));
    expect(r.roadKm.containsKey(RoadClass.local), isFalse);
  });

  test('traffic lights passed, stopped at and waited for', () {
    final r = matchRoads(drive(174.700, 174.730, stopAt: [174.7097]), area());
    expect(r.lightsPassed, 2); // nodes 1+2 are one intersection; node 4 is off route
    expect(r.stoppedAtLights, 1);
    expect(r.lights.firstWhere((l) => l.stopped).lon, closeTo(174.71, 0.001));
    expect(r.waitAtLights.inSeconds, inInclusiveRange(28, 32));
  });

  test('off the mapped roads counts as other', () {
    final samples = drive(174.745, 174.755);
    final r = matchRoads(samples, area());
    expect(r.roadKm.keys, [RoadClass.other]);
  });

  test('stored and read back', () {
    final r = matchRoads(drive(174.700, 174.730, stopAt: [174.7097]), area());
    final back = RoadStats.fromJson(jsonDecode(jsonEncode(r.toJson())) as Map<String, Object?>);
    expect(back.lightsPassed, r.lightsPassed);
    expect(back.stoppedAtLights, 1);
    expect(back.waitAtLights, r.waitAtLights);
    expect(back.roadKm[RoadClass.main], closeTo(r.roadKm[RoadClass.main]!, 0.001));
  });

  test('query leaves off the ends, simplifies and splits long routes', () {
    final samples = drive(174.700, 174.730);
    final lines = queryLines(samples);
    expect(lines, hasLength(1));
    expect(lines.single, hasLength(2)); // a straight line needs only its ends
    expect(lines.single.first.lon, greaterThan(174.7030)); // ~300 m in
    expect(lines.single.last.lon, lessThan(174.7270));
    expect(queryLines(drive(174.700, 174.707)), isEmpty); // too short to send anything

    // A zig-zag keeps its corners and is split into chunks that overlap by a point.
    final zig = [
      for (var i = 0; i < 400; i++)
        GpsSample(DateTime(2026, 1, 1).add(Duration(seconds: i * 10)), lat0 + (i.isEven ? 0 : 0.001), 174.7 + i * 0.001, speedMps: 20),
    ];
    final parts = queryLines(zig, maxPoints: 150);
    expect(parts.length, greaterThan(1));
    expect(parts.every((p) => p.length <= 150), isTrue);
    expect(parts[1].first, parts[0].last);
    expect(overpassQuery(parts.first), allOf(contains('traffic_signals'), contains('around:'), contains('out geom')));
  });
}

void lookupTests() {
  test('lookup stores road stats on the trip', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final v = await repo.ensureVehicle();
    final samples = drive(174.700, 174.730, stopAt: [174.7097]);
    final stats = computeTripStats(samples);
    await repo.saveRecordedTrip(
      TripsCompanion.insert(
        id: 't1',
        vehicleId: v.id,
        name: 'Test',
        startAt: samples.first.at,
        status: const Value('done'),
        statsJson: Value(jsonEncode(stats.toJson())),
      ),
      [
        for (final s in samples)
          TripPointsCompanion.insert(
            tripId: 't1',
            at: s.at,
            lat: s.lat,
            lon: s.lon,
            speedMps: Value(s.speedMps),
            accuracyM: Value(s.accuracyM),
          ),
      ],
      const [],
    );
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      expect(req.bodyFields['data'], contains('traffic_signals'));
      return http.Response(jsonEncode({'elements': _elements}), 200);
    });
    final r = await RoadLookup.analyse(repo, 't1', client: client);
    expect(calls, 1);
    expect(r!.lightsPassed, 2);
    final trip = (await repo.trip('t1'))!;
    expect(RoadLookup.stored(trip.statsJson)!.stoppedAtLights, 1);
    expect(TripStats.fromJson(jsonDecode(trip.statsJson!) as Map<String, Object?>).distanceKm, closeTo(stats.distanceKm, 0.001));
    await db.close();
  });
}
