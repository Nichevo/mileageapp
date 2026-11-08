import 'dart:convert';
import 'dart:math' as math;

/// One GPS sample as written by the native recorder.
class GpsSample {
  final DateTime at;
  final double lat, lon;
  final double? speedMps, accuracyM, altitudeM;
  const GpsSample(this.at, this.lat, this.lon, {this.speedMps, this.accuracyM, this.altitudeM});

  /// Line format: epochMillis,lat,lon,speed,accuracy,altitude (blank = unknown).
  static GpsSample? parse(String line) {
    final p = line.trim().split(',');
    if (p.length < 3) return null;
    final ms = int.tryParse(p[0]);
    final lat = double.tryParse(p[1]);
    final lon = double.tryParse(p[2]);
    if (ms == null || lat == null || lon == null) return null;
    double? opt(int i) => p.length > i ? double.tryParse(p[i]) : null;
    return GpsSample(DateTime.fromMillisecondsSinceEpoch(ms), lat, lon,
        speedMps: opt(3), accuracyM: opt(4), altitudeM: opt(5));
  }

  static List<GpsSample> parseAll(String text) =>
      const LineSplitter().convert(text).map(parse).whereType<GpsSample>().toList();
}

/// A place where the car stood still for a while.
class StopSpan {
  final DateTime arrive, depart;
  final double lat, lon;
  const StopSpan(this.arrive, this.depart, this.lat, this.lon);
  Duration get duration => depart.difference(arrive);
}

/// Speed bands used for the motorway / open road / urban split.
enum SpeedBand { urban, openRoad, motorway }

String bandLabel(SpeedBand b) => switch (b) {
      SpeedBand.urban => 'Urban',
      SpeedBand.openRoad => 'Open road',
      SpeedBand.motorway => 'Motorway',
    };

class TripStats {
  final double distanceKm;
  final Duration total, moving, stopped;
  final double maxKmh;
  final int shortStops;
  final List<StopSpan> stops;
  /// Where the short stops were. Not stored in the summary JSON.
  final List<StopSpan> shortStopSpans;
  final Map<SpeedBand, double> bandKm;
  final Map<SpeedBand, Duration> bandTime;
  final double elevationGainM;
  final int harshBrakes, harshAccels;

  const TripStats({
    required this.distanceKm,
    required this.total,
    required this.moving,
    required this.stopped,
    required this.maxKmh,
    required this.shortStops,
    required this.stops,
    this.shortStopSpans = const [],
    required this.bandKm,
    required this.bandTime,
    required this.elevationGainM,
    required this.harshBrakes,
    required this.harshAccels,
  });

  double? get avgKmh => total.inSeconds < 30 ? null : distanceKm / (total.inSeconds / 3600);
  double? get movingAvgKmh => moving.inSeconds < 30 ? null : distanceKm / (moving.inSeconds / 3600);

  static const empty = TripStats(
    distanceKm: 0,
    total: Duration.zero,
    moving: Duration.zero,
    stopped: Duration.zero,
    maxKmh: 0,
    shortStops: 0,
    stops: [],
    bandKm: {},
    bandTime: {},
    elevationGainM: 0,
    harshBrakes: 0,
    harshAccels: 0,
  );

  Map<String, Object?> toJson() => {
        'distanceKm': distanceKm,
        'totalS': total.inSeconds,
        'movingS': moving.inSeconds,
        'stoppedS': stopped.inSeconds,
        'maxKmh': maxKmh,
        'shortStops': shortStops,
        'longStops': stops.length,
        'bandKm': {for (final e in bandKm.entries) e.key.name: e.value},
        'bandS': {for (final e in bandTime.entries) e.key.name: e.value.inSeconds},
        'elevGainM': elevationGainM,
        'harshBrakes': harshBrakes,
        'harshAccels': harshAccels,
      };

  /// Summary stored on the trip row so the list does not reload every point.
  static TripStats fromJson(Map<String, Object?> j) {
    double d(String k) => (j[k] as num?)?.toDouble() ?? 0;
    int i(String k) => (j[k] as num?)?.toInt() ?? 0;
    Map<SpeedBand, T> bands<T>(String k, T Function(num) f) {
      final m = (j[k] as Map?) ?? const {};
      return {
        for (final b in SpeedBand.values)
          if (m[b.name] is num) b: f(m[b.name] as num),
      };
    }

    return TripStats(
      distanceKm: d('distanceKm'),
      total: Duration(seconds: i('totalS')),
      moving: Duration(seconds: i('movingS')),
      stopped: Duration(seconds: i('stoppedS')),
      maxKmh: d('maxKmh'),
      shortStops: i('shortStops'),
      stops: const [],
      bandKm: bands('bandKm', (v) => v.toDouble()),
      bandTime: bands('bandS', (v) => Duration(seconds: v.toInt())),
      elevationGainM: d('elevGainM'),
      harshBrakes: i('harshBrakes'),
      harshAccels: i('harshAccels'),
    );
  }
}

// Thresholds. Kept together so they are easy to tune after real drives.
const double stillKmh = 3; // below this the car counts as stopped
const Duration shortStopMin = Duration(seconds: 5); // traffic lights, give-ways
const Duration shortStopMax = Duration(seconds: 120);
const double maxAccuracyM = 50; // samples worse than this are ignored
const double urbanMaxKmh = 60;
const double openRoadMaxKmh = 90;
const double harshMps2 = 3.0; // about 0.3 g

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0088;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

SpeedBand bandFor(double kmh) =>
    kmh < urbanMaxKmh ? SpeedBand.urban : (kmh < openRoadMaxKmh ? SpeedBand.openRoad : SpeedBand.motorway);

/// Works out distance, moving/stopped time, stops and the rest from raw samples.
TripStats computeTripStats(List<GpsSample> raw) {
  final pts = raw.where((s) => (s.accuracyM ?? 0) <= maxAccuracyM).toList()
    ..sort((a, b) => a.at.compareTo(b.at));
  if (pts.length < 2) {
    return pts.isEmpty
        ? TripStats.empty
        : TripStats(
            distanceKm: 0,
            total: Duration.zero,
            moving: Duration.zero,
            stopped: Duration.zero,
            maxKmh: 0,
            shortStops: 0,
            stops: const [],
            bandKm: const {},
            bandTime: const {},
            elevationGainM: 0,
            harshBrakes: 0,
            harshAccels: 0,
          );
  }

  var distance = 0.0, maxKmh = 0.0, elev = 0.0;
  var moving = Duration.zero, stopped = Duration.zero;
  final bandKm = <SpeedBand, double>{};
  final bandTime = <SpeedBand, Duration>{};
  var shortStops = 0, brakes = 0, accels = 0;
  final stops = <StopSpan>[];
  final shortSpans = <StopSpan>[];

  DateTime? stillSince;
  GpsSample? stillAt;
  double? lastAlt;
  double? prevKmh;
  DateTime? prevKmhAt;

  void closeStill(DateTime until) {
    if (stillSince == null) return;
    final d = until.difference(stillSince!);
    if (d >= shortStopMin && d <= shortStopMax) {
      shortStops++;
      shortSpans.add(StopSpan(stillSince!, until, stillAt!.lat, stillAt!.lon));
    } else if (d > shortStopMax) {
      stops.add(StopSpan(stillSince!, until, stillAt!.lat, stillAt!.lon));
    }
    stillSince = null;
    stillAt = null;
  }

  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    final dt = b.at.difference(a.at);
    if (dt <= Duration.zero) continue;
    final segKm = haversineKm(a.lat, a.lon, b.lat, b.lon);
    final hours = dt.inMilliseconds / 3600000;
    // Prefer the receiver's Doppler speed; fall back to distance over time.
    final kmh = b.speedMps != null ? b.speedMps! * 3.6 : segKm / hours;
    // Ignore jumps that imply an impossible speed (GPS glitch).
    if (segKm / hours > 250) continue;

    if (kmh < stillKmh) {
      stopped += dt;
      if (stillSince == null) {
        stillSince = a.at;
        stillAt = a;
      }
    } else {
      closeStill(a.at);
      moving += dt;
      distance += segKm;
      final band = bandFor(kmh);
      bandKm[band] = (bandKm[band] ?? 0) + segKm;
      bandTime[band] = (bandTime[band] ?? Duration.zero) + dt;
    }
    if (kmh > maxKmh && kmh < 250) maxKmh = kmh;

    if (prevKmh != null && prevKmhAt != null) {
      final sdt = b.at.difference(prevKmhAt).inMilliseconds / 1000;
      if (sdt > 0 && sdt <= 4) {
        final acc = (kmh - prevKmh) / 3.6 / sdt;
        if (acc <= -harshMps2) brakes++;
        if (acc >= harshMps2) accels++;
      }
    }
    prevKmh = kmh;
    prevKmhAt = b.at;

    // Elevation: only count climbs over 3 m to filter GPS altitude noise.
    final alt = b.altitudeM;
    if (alt != null) {
      if (lastAlt == null) {
        lastAlt = alt;
      } else if ((alt - lastAlt).abs() >= 3) {
        if (alt > lastAlt) elev += alt - lastAlt;
        lastAlt = alt;
      }
    }
  }
  closeStill(pts.last.at);

  return TripStats(
    distanceKm: distance,
    total: pts.last.at.difference(pts.first.at),
    moving: moving,
    stopped: stopped,
    maxKmh: maxKmh,
    shortStops: shortStops,
    stops: stops,
    shortStopSpans: shortSpans,
    bandKm: bandKm,
    bandTime: bandTime,
    elevationGainM: elev,
    harshBrakes: brakes,
    harshAccels: accels,
  );
}

/// Straight distance along all samples, used for the live readout.
double liveDistanceKm(List<GpsSample> pts) {
  var d = 0.0;
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    if ((b.accuracyM ?? 0) > maxAccuracyM) continue;
    final speed = b.speedMps ?? 99;
    if (speed * 3.6 < stillKmh) continue;
    d += haversineKm(a.lat, a.lon, b.lat, b.lon);
  }
  return d;
}
