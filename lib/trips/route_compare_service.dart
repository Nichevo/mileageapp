import 'dart:convert';
import 'dart:isolate';

import '../data/repository.dart';
import '../domain/places.dart';
import '../domain/road_match.dart' show LightPass;
import '../domain/route_compare.dart';
import '../domain/trip_stats.dart';
import '../domain/trip_weather.dart';
import 'road_lookup.dart';

/// A shared stretch ready to show: where it is and each trip's figures on it.
class StretchResult {
  final String name;
  final String baseTripId;
  final double km;
  final List<LatLon> path;
  final List<RunStats> runs; // oldest first
  const StretchResult(this.name, this.baseTripId, this.km, this.path, this.runs);

  RunStats? runOf(String tripId) => runs.where((r) => r.tripId == tripId).firstOrNull;
}

/// What [RouteCompare.compareTrip] found for one trip.
class TripComparison {
  final List<StretchResult> stretches;
  final List<({NearMatch match, String name, String? stretch})> near;
  const TripComparison(this.stretches, this.near);
}

typedef _TripData = ({String id, String name, List<GpsSample> samples, List<LightPass> lights, TripWeather? weather});

/// Loads a vehicle's trips and matches routes off the main thread.
class RouteCompare {
  static String? _commonKey;
  static List<StretchResult>? _common;

  static Future<(String, List<_TripData>)> _load(Repository repo, String vehicleId) async {
    final trips = await repo.doneTrips(vehicleId);
    final key = '$vehicleId:${trips.map((t) => '${t.id}/${t.statsJson?.length}').join(',')}';
    final pts = await repo.allTripPoints(vehicleId);
    final data = <_TripData>[
      for (final t in trips)
        if ((pts[t.id]?.length ?? 0) > 1)
          (
            id: t.id,
            name: t.name,
            samples: [for (final p in pts[t.id]!) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM)],
            lights: RoadLookup.stored(t.statsJson)?.lights ?? const <LightPass>[],
            weather: t.statsJson == null ? null : TripWeather.fromJson((jsonDecode(t.statsJson!) as Map<String, Object?>)['weather']),
          ),
    ];
    return (key, data);
  }

  static List<Track> _tracks(List<_TripData> data) => [for (final d in data) Track.from(d.id, d.samples, lights: d.lights, weather: d.weather)];

  static StretchResult _result(Stretch s, List<Place> places) => StretchResult(
        stretchName(s, places),
        s.base.id,
        s.km,
        [for (final p in s.base.slice(s.from, s.to)) (lat: p.lat, lon: p.lon)],
        [for (final r in s.runs) runStats(r)],
      );

  /// Stretches of one trip that other trips also drove, best first.
  static Future<List<StretchResult>> forTrip(Repository repo, String vehicleId, String tripId, List<Place> places) async =>
      (await compareTrip(repo, vehicleId, tripId, places)).stretches;

  /// Stretches shared with other trips, and trips that nearly matched.
  static Future<TripComparison> compareTrip(Repository repo, String vehicleId, String tripId, List<Place> places) async {
    final (_, data) = await _load(repo, vehicleId);
    if (data.every((d) => d.id != tripId)) return const TripComparison([], []);
    final names = {for (final d in data) d.id: d.name};
    return Isolate.run(() {
      final tracks = _tracks(data);
      final t = tracks.firstWhere((x) => x.id == tripId);
      final found = findStretches(t, tracks);
      final shown = [for (final s in found) _result(s, places)];
      return TripComparison(shown, [
        for (final n in nearMatches(t, tracks, found)) (match: n, name: names[n.tripId] ?? 'Trip', stretch: n.stretch == null ? null : shown[n.stretch!].name),
      ]);
    });
  }

  /// The most-driven stretches across all of a vehicle's trips.
  static Future<List<StretchResult>> common(Repository repo, String vehicleId, List<Place> places) async {
    final (key, data) = await _load(repo, vehicleId);
    final fullKey = '$key|${places.map((p) => '${p.id}${p.name}').join(',')}';
    if (fullKey == _commonKey && _common != null) return _common!;
    final out = await Isolate.run(() => [for (final s in commonStretches(_tracks(data))) _result(s, places)]);
    _commonKey = fullKey;
    _common = out;
    return out;
  }
}
