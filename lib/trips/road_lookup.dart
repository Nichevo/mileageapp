import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/repository.dart';
import '../domain/road_match.dart';
import '../domain/trip_stats.dart';

/// Fetches roads and traffic signals along a trip from the Overpass API
/// (OpenStreetMap) and stores the matched [RoadStats] in the trip's stats.
class RoadLookup {
  static const endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  static Future<OsmArea> fetch(List<GpsSample> samples, {http.Client? client}) async {
    final c = client ?? http.Client();
    try {
      var area = OsmArea.empty;
      for (final line in queryLines(samples)) {
        area = area.merge(await _query(c, overpassQuery(line)));
      }
      return area;
    } finally {
      if (client == null) c.close();
    }
  }

  static Future<OsmArea> _query(http.Client c, String q) async {
    Object? lastError;
    for (final url in endpoints) {
      try {
        final r = await c
            .post(Uri.parse(url), headers: {'User-Agent': 'MileageLog (nz.mileagelog.app)'}, body: {'data': q})
            .timeout(const Duration(seconds: 75));
        if (r.statusCode == 200) return OsmArea.fromOverpass(jsonDecode(r.body) as Map<String, Object?>);
        lastError = 'OpenStreetMap lookup failed (${r.statusCode})';
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError ?? 'OpenStreetMap lookup failed');
  }

  /// Road stats already stored for a trip, if any.
  static RoadStats? stored(String? statsJson) {
    if (statsJson == null) return null;
    final road = (jsonDecode(statsJson) as Map<String, Object?>)['road'];
    return road is Map ? RoadStats.fromJson(road.cast<String, Object?>()) : null;
  }

  /// Looks up and saves road stats for one trip. Returns null when the
  /// trip is too short to look up.
  static Future<RoadStats?> analyse(Repository repo, String tripId, {http.Client? client}) async {
    final trip = await repo.trip(tripId);
    if (trip == null) return null;
    final pts = await repo.tripPoints(tripId);
    final samples = [
      for (final p in pts) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM, altitudeM: p.altitudeM),
    ];
    if (queryLines(samples).isEmpty) return null;
    final osm = await fetch(samples, client: client);
    final road = matchRoads(samples, osm);
    // Re-read: the weather lookup may have saved in the meantime.
    final fresh = await repo.trip(tripId);
    final stats = fresh?.statsJson == null ? computeTripStats(samples).toJson() : (jsonDecode(fresh!.statsJson!) as Map<String, Object?>);
    stats['road'] = road.toJson();
    await repo.setTripStatsJson(tripId, jsonEncode(stats));
    return road;
  }

  /// Counts red phases at each light for trips analysed before that was
  /// added, from the stored light positions and the trip's own points, with
  /// no network. Also re-counts when [force] (after merging trips).
  static Future<int> countLightCycles(Repository repo, {String? tripId, bool force = false}) async {
    final trips = tripId == null ? await repo.db.select(repo.db.trips).get() : [?(await repo.trip(tripId))];
    var n = 0;
    for (final t in trips) {
      final road = stored(t.statsJson);
      if (road == null || road.lights.isEmpty || (road.cyclesCounted && !force)) continue;
      final pts = await repo.tripPoints(t.id);
      if (pts.length < 2) continue; // nothing to measure against
      final samples = [for (final p in pts) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM)];
      final lights = lightWaits(samples, [for (final l in road.lights) (lat: l.lat, lon: l.lon)]);
      final updated = RoadStats(
        roadKm: road.roadKm,
        lights: lights,
        waitAtLights: Duration(seconds: lights.fold(0, (a, l) => a + (l.waitS ?? 0))),
        tolls: road.tolls,
      );
      final fresh = await repo.trip(t.id);
      final stats = jsonDecode(fresh!.statsJson!) as Map<String, Object?>;
      stats['road'] = updated.toJson();
      await repo.setTripStatsJson(t.id, jsonEncode(stats));
      n++;
    }
    return n;
  }

  /// Looks up recent finished trips that don't have road stats yet. Quiet:
  /// failures are left for next time (or the trip page).
  static bool _busy = false;
  static Future<void> analyseRecent(Repository repo, String vehicleId, {int max = 3}) async {
    if (_busy) return;
    _busy = true;
    try {
      await _analyseRecent(repo, vehicleId, max);
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  static Future<void> _analyseRecent(Repository repo, String vehicleId, int max) async {
    final since = DateTime.now().subtract(const Duration(days: 14));
    final trips = (await repo.db.select(repo.db.trips).get())
        .where((t) => t.vehicleId == vehicleId && t.status == 'done' && t.startAt.isAfter(since) && stored(t.statsJson) == null)
        .toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    for (final t in trips.take(max)) {
      try {
        await analyse(repo, t.id);
      } catch (_) {
        return; // offline or the service is busy; try again later
      }
    }
  }
}
