/// Trip figures over time for the Insights page: trips, distance, speeds,
/// road types, traffic lights, stops and weather per week, month or year,
/// plus when you drive and how long trips are.
library;

import 'dart:convert';

import 'road_match.dart';
import 'stats.dart';
import 'trip_stats.dart';
import 'trip_weather.dart';

/// What the Insights charts need from one finished trip.
class TripFacts {
  final DateTime start;
  final TripStats stats;
  final RoadStats? road;
  final TripWeather? weather;
  const TripFacts(this.start, this.stats, {this.road, this.weather});

  static TripFacts? fromJson(DateTime start, String? statsJson) {
    if (statsJson == null) return null;
    final j = jsonDecode(statsJson) as Map<String, Object?>;
    final road = j['road'];
    return TripFacts(
      start,
      TripStats.fromJson(j),
      road: road is Map ? RoadStats.fromJson(road.cast<String, Object?>()) : null,
      weather: TripWeather.fromJson(j['weather']),
    );
  }

  bool get rainy {
    final w = weather;
    if (w == null) return false;
    final c = w.code;
    return w.rainMm >= 0.2 || (c >= 51 && c <= 67) || (c >= 80 && c <= 82) || c >= 95;
  }
}

/// Everything summed for one week, month or year.
class DrivingPeriod {
  final DateTime start;
  int trips = 0;
  double km = 0;
  Duration total = Duration.zero, moving = Duration.zero;
  final roadKm = <RoadClass, double>{};
  final bandKm = <SpeedBand, double>{};
  int lights = 0, red = 0, phases = 0, multi = 0, cycleLights = 0;
  Duration lightWait = Duration.zero;
  int shortStops = 0, harsh = 0;
  int weatherTrips = 0, rainTrips = 0;
  double tempSum = 0;
  double climbM = 0;
  DrivingPeriod(this.start);

  double? get avgKmh => total.inSeconds < 60 ? null : km / (total.inSeconds / 3600);
  double? get movingKmh => moving.inSeconds < 60 ? null : km / (moving.inSeconds / 3600);
  double? get kmPerTrip => trips == 0 ? null : km / trips;
  double? get redShare => lights == 0 ? null : red / lights;
  /// Red phases per stop at a light, on trips where cycles were counted.
  double? get phasesPerRed => cycleLights == 0 || red == 0 ? null : phases / red;
  double? get stopsPer10km => km < 1 ? null : shortStops / km * 10;
  double? get rainShare => weatherTrips == 0 ? null : rainTrips / weatherTrips;
  double? get avgTempC => weatherTrips == 0 ? null : tempSum / weatherTrips;
  double get roadTotal => roadKm.values.fold(0.0, (a, b) => a + b);
}

/// Per period from the first trip (or [from]) to [now], empty ones included.
List<DrivingPeriod> drivingPeriods(List<TripFacts> trips, Period p, {DateTime? from, required DateTime now}) {
  if (trips.isEmpty) return const [];
  final sorted = [...trips]..sort((a, b) => a.start.compareTo(b.start));
  final first = from != null && from.isAfter(sorted.first.start) ? from : sorted.first.start;
  final buckets = <DateTime, DrivingPeriod>{};
  var cur = periodStart(first, p);
  final last = periodStart(now, p);
  final out = <DrivingPeriod>[];
  while (!cur.isAfter(last)) {
    out.add(buckets[cur] = DrivingPeriod(cur));
    cur = nextPeriod(cur, p);
  }
  for (final t in sorted) {
    final b = buckets[periodStart(t.start, p)];
    if (b == null) continue;
    final s = t.stats;
    b.trips++;
    b.km += s.distanceKm;
    b.total += s.total;
    b.moving += s.moving;
    for (final e in s.bandKm.entries) {
      b.bandKm[e.key] = (b.bandKm[e.key] ?? 0) + e.value;
    }
    b.shortStops += s.shortStops;
    b.harsh += s.harshBrakes + s.harshAccels;
    b.climbM += s.elevationGainM;
    final r = t.road;
    if (r != null) {
      for (final e in r.roadKm.entries) {
        b.roadKm[e.key] = (b.roadKm[e.key] ?? 0) + e.value;
      }
      b.lights += r.lightsPassed;
      b.red += r.stoppedAtLights;
      b.lightWait += r.waitAtLights;
      if (r.cyclesCounted) {
        b.cycleLights += r.lightsPassed;
        b.phases += r.redPhases;
        b.multi += r.multiPhaseLights;
      }
    }
    if (t.weather != null) {
      b.weatherTrips++;
      if (t.rainy) b.rainTrips++;
      b.tempSum += t.weather!.tempC;
    }
  }
  return out;
}

/// Trips started in each hour of the day (0–23).
List<int> tripsByHour(List<TripFacts> trips) {
  final out = List.filled(24, 0);
  for (final t in trips) {
    out[t.start.toLocal().hour]++;
  }
  return out;
}

const tripLengthBuckets = [2.0, 5.0, 10.0, 20.0, 50.0];
const tripLengthLabels = ['<2', '2–5', '5–10', '10–20', '20–50', '50+'];

/// Number of trips in each length bucket ([tripLengthLabels]).
List<int> tripsByLength(List<TripFacts> trips) {
  final out = List.filled(tripLengthBuckets.length + 1, 0);
  for (final t in trips) {
    var i = tripLengthBuckets.indexWhere((b) => t.stats.distanceKm < b);
    if (i < 0) i = tripLengthBuckets.length;
    out[i]++;
  }
  return out;
}

/// Time and distance between consecutive fills, credited to the period of
/// the later fill: average days and km between fills per period.
class FillGap {
  final DateTime at;
  final double days, km;
  const FillGap(this.at, this.days, this.km);
}

List<FillGap> fillGaps(List<FuelRow> rows) {
  final sorted = [...rows]..sort((a, b) => a.at.compareTo(b.at));
  return [
    for (var i = 1; i < sorted.length; i++)
      if (sorted[i].odometerKm >= sorted[i - 1].odometerKm)
        FillGap(sorted[i].at, sorted[i].at.difference(sorted[i - 1].at).inHours / 24, sorted[i].odometerKm - sorted[i - 1].odometerKm),
  ];
}

/// Average days between fills per period start, for periods with a fill.
Map<DateTime, ({double days, double km, int n})> fillGapsByPeriod(List<FillGap> gaps, Period p) {
  final m = <DateTime, List<FillGap>>{};
  for (final g in gaps) {
    (m[periodStart(g.at, p)] ??= []).add(g);
  }
  return {
    for (final e in m.entries)
      e.key: (
        days: e.value.fold(0.0, (a, g) => a + g.days) / e.value.length,
        km: e.value.fold(0.0, (a, g) => a + g.km) / e.value.length,
        n: e.value.length,
      ),
  };
}

/// One traffic light (intersection) over all trips.
class LightSpot {
  final double lat, lon;
  int passes = 0, stops = 0, phases = 0, multi = 0, counted = 0;
  final waits = <int>[]; // seconds, when stopped
  DateTime last;
  LightSpot(this.lat, this.lon, this.last);
  double get stopRate => passes == 0 ? 0 : stops / passes;
  int get totalWaitS => waits.fold(0, (a, b) => a + b);
  int? get medianWaitS {
    if (waits.isEmpty) return null;
    final s = [...waits]..sort();
    return s[s.length ~/ 2];
  }
}

/// Lights from every trip, merged when within [radiusM] of each other.
List<LightSpot> lightHistory(List<TripFacts> trips, {double radiusM = 45}) {
  final spots = <LightSpot>[];
  for (final t in trips) {
    for (final l in t.road?.lights ?? const <LightPass>[]) {
      var spot = spots.where((s) => haversineKm(s.lat, s.lon, l.lat, l.lon) * 1000 <= radiusM).firstOrNull;
      if (spot == null) spots.add(spot = LightSpot(l.lat, l.lon, t.start));
      spot.passes++;
      if (t.start.isAfter(spot.last)) spot.last = t.start;
      if (l.stopped) {
        spot.stops++;
        if (l.waitS != null) spot.waits.add(l.waitS!);
      }
      if (l.counted) {
        spot.counted++;
        spot.phases += l.phases!;
        if (l.phases! >= 2) spot.multi++;
      }
    }
  }
  return spots;
}
