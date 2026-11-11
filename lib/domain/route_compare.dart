/// Finds stretches of road that several trips share, so the same stretch can
/// be compared over time. Trips don't have to match end to end: any run of at
/// least [minStretchKm] driven the same way counts, with short gaps allowed for
/// GPS drift or a small detour.
library;

import 'dart:math' as math;

import 'places.dart';
import 'road_match.dart' show LightPass;
import 'trip_stats.dart';
import 'trip_weather.dart';

const double minStretchKm = 2;
const double _stepKm = 0.05; // resample every 50 m
const double _cellKm = 0.1; // grid for finding nearby points
const double _matchKm = 0.04; // points within 40 m match
const double _looseMatchKm = 0.09; // near-miss check: within 90 m
const double _maxHeadingDiff = 60; // and heading the same way
const double _maxGapKm = 0.3; // unmatched run that doesn't break a stretch

class TrackPoint {
  final double km, lat, lon, heading;
  final DateTime at;
  const TrackPoint(this.km, this.lat, this.lon, this.heading, this.at);
}

/// A trip's route resampled at even spacing, plus what's needed to work out
/// stats for part of it.
class Track {
  final String id;
  final DateTime start;
  final List<TrackPoint> pts;
  final List<GpsSample> samples;
  final List<LightPass> lights;
  final TripWeather? weather;
  late final Map<(int, int), List<int>> _grid = _buildGrid();
  late final Set<(int, int)> coarse = {for (final p in pts) _cell(p.lat, p.lon, 0.5)};

  Track(this.id, this.start, this.pts, {this.samples = const [], this.lights = const [], this.weather});

  factory Track.from(String id, List<GpsSample> raw, {List<LightPass> lights = const [], TripWeather? weather}) {
    final s = [for (final p in raw) if ((p.accuracyM ?? 0) <= maxAccuracyM) p];
    return Track(id, s.isEmpty ? DateTime(0) : s.first.at, _resample(s), samples: s, lights: lights, weather: weather);
  }

  double get km => pts.isEmpty ? 0 : pts.last.km;

  Map<(int, int), List<int>> _buildGrid() {
    final g = <(int, int), List<int>>{};
    for (var i = 0; i < pts.length; i++) {
      (g[_cell(pts[i].lat, pts[i].lon, _cellKm)] ??= []).add(i);
    }
    return g;
  }

  /// Time at a distance along the track.
  DateTime timeAt(double km) {
    if (pts.isEmpty) return start;
    final i = _indexAt(km);
    if (i >= pts.length - 1) return pts.last.at;
    final a = pts[i], b = pts[i + 1];
    final f = b.km == a.km ? 0.0 : ((km - a.km) / (b.km - a.km)).clamp(0.0, 1.0);
    return a.at.add(Duration(milliseconds: (b.at.difference(a.at).inMilliseconds * f).round()));
  }

  TrackPoint pointAt(double km) => pts[_indexAt(km).clamp(0, pts.length - 1)];

  int _indexAt(double km) {
    var lo = 0, hi = pts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (pts[mid].km <= km) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// The nearest point heading the same way, within 40 m.
  int? nearest(TrackPoint p, {double matchKm = _matchKm}) {
    final (cx, cy) = _cell(p.lat, p.lon, _cellKm);
    int? best;
    var bestKm = matchKm;
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        for (final j in _grid[(cx + dx, cy + dy)] ?? const <int>[]) {
          final q = pts[j];
          if (_angle(p.heading, q.heading) > _maxHeadingDiff) continue;
          final d = haversineKm(p.lat, p.lon, q.lat, q.lon);
          if (d <= bestKm) {
            bestKm = d;
            best = j;
          }
        }
      }
    }
    return best;
  }

  List<TrackPoint> slice(double from, double to) => [for (final p in pts) if (p.km >= from && p.km <= to) p];
}

(int, int) _cell(double lat, double lon, double sizeKm) {
  final y = lat * 111.32;
  final x = lon * 111.32 * math.cos(lat * math.pi / 180);
  return ((x / sizeKm).floor(), (y / sizeKm).floor());
}

double _angle(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

double _bearing(double lat1, double lon1, double lat2, double lon2) {
  final dx = (lon2 - lon1) * math.cos(lat1 * math.pi / 180);
  final dy = lat2 - lat1;
  return (math.atan2(dx, dy) * 180 / math.pi + 360) % 360;
}

List<TrackPoint> _resample(List<GpsSample> s) {
  if (s.length < 2) return const [];
  final raw = <(double, double, double, DateTime)>[]; // km, lat, lon, at
  var done = 0.0, next = 0.0;
  for (var i = 1; i < s.length; i++) {
    final a = s[i - 1], b = s[i];
    final seg = haversineKm(a.lat, a.lon, b.lat, b.lon);
    while (seg > 0 && next <= done + seg) {
      final f = (next - done) / seg;
      raw.add((
        next,
        a.lat + (b.lat - a.lat) * f,
        a.lon + (b.lon - a.lon) * f,
        a.at.add(Duration(milliseconds: (b.at.difference(a.at).inMilliseconds * f).round())),
      ));
      next += _stepKm;
    }
    done += seg;
  }
  if (raw.length < 2) return const [];
  return [
    for (var i = 0; i < raw.length; i++)
      () {
        final a = raw[math.max(0, i - 1)], b = raw[math.min(raw.length - 1, i + 1)];
        return TrackPoint(raw[i].$1, raw[i].$2, raw[i].$3, _bearing(a.$2, a.$3, b.$2, b.$3), raw[i].$4);
      }(),
  ];
}

/// Part of track a that matches part of track b (distances along each).
class Overlap {
  final double a0, a1, b0, b1;
  const Overlap(this.a0, this.a1, this.b0, this.b1);
  double get km => a1 - a0;

  /// Where a distance along a falls on b.
  double mapToB(double a) => a1 == a0 ? b0 : b0 + (a - a0) / (a1 - a0) * (b1 - b0);
}

/// Stretches at least [minKm] long where a and b follow the same road the
/// same way.
List<Overlap> overlaps(Track a, Track b, {double minKm = minStretchKm, double matchKm = _matchKm}) {
  if (a.pts.isEmpty || b.pts.isEmpty) return const [];
  if (a.coarse.intersection(b.coarse).length < 3) return const [];
  final out = <Overlap>[];
  int? startI, lastI, startJ, lastJ;
  void close() {
    final i0 = startI, i1 = lastI, j0 = startJ, j1 = lastJ;
    if (i0 != null && i1 != null && j0 != null && j1 != null && a.pts[i1].km - a.pts[i0].km >= minKm && b.pts[j1].km > b.pts[j0].km) {
      out.add(Overlap(a.pts[i0].km, a.pts[i1].km, b.pts[j0].km, b.pts[j1].km));
    }
    startI = lastI = startJ = lastJ = null;
  }

  for (var i = 0; i < a.pts.length; i++) {
    final j = b.nearest(a.pts[i], matchKm: matchKm);
    if (j == null) {
      if (lastI != null && a.pts[i].km - a.pts[lastI!].km > _maxGapKm) close();
      continue;
    }
    if (lastI != null) {
      final da = a.pts[i].km - a.pts[lastI!].km;
      final db = b.pts[j].km - b.pts[lastJ!].km;
      // Keep going forward along b, at about the same pace as along a.
      if (da > _maxGapKm || db < -0.1 || db > da + _maxGapKm) close();
    }
    startI ??= i;
    startJ ??= j;
    lastI = i;
    lastJ = math.max(j, lastJ ?? j);
  }
  close();
  return out;
}

/// One trip's run over a stretch, as distances along that trip.
class StretchRun {
  final Track track;
  final double from, to;
  const StretchRun(this.track, this.from, this.to);
}

/// A stretch of [base] and every trip that drove (nearly) all of it.
class Stretch {
  final Track base;
  final double from, to;
  final List<StretchRun> runs; // including base's own run, oldest first
  const Stretch(this.base, this.from, this.to, this.runs);
  double get km => to - from;
  LatLon get startAt {
    final p = base.pointAt(from);
    return (lat: p.lat, lon: p.lon);
  }

  LatLon get endAt {
    final p = base.pointAt(to);
    return (lat: p.lat, lon: p.lon);
  }
}

/// The stretches of [t] shared with the most other trips, best first. A
/// trip counts towards a stretch when it covers at least [cover] of it.
List<Stretch> findStretches(Track t, Iterable<Track> others, {int max = 2, double cover = 0.9}) {
  final byTrip = <Track, List<Overlap>>{};
  for (final o in others) {
    if (o.id == t.id) continue;
    final ov = overlaps(t, o);
    if (ov.isNotEmpty) byTrip[o] = ov;
  }
  if (byTrip.isEmpty) return const [];
  final candidates = [for (final l in byTrip.values) ...l];
  final scored = <(double, Stretch)>[];
  for (final c in candidates) {
    final runs = <StretchRun>[StretchRun(t, c.a0, c.a1)];
    for (final e in byTrip.entries) {
      for (final ov in e.value) {
        final shared = math.min(ov.a1, c.a1) - math.max(ov.a0, c.a0);
        if (shared >= cover * c.km) {
          final from = ov.mapToB(math.max(ov.a0, c.a0)), to = ov.mapToB(math.min(ov.a1, c.a1));
          if (to > from) runs.add(StretchRun(e.key, from, to));
          break;
        }
      }
    }
    runs.sort((x, y) => x.track.start.compareTo(y.track.start));
    scored.add(((runs.length - 1) * math.sqrt(c.km), Stretch(t, c.a0, c.a1, runs)));
  }
  scored.sort((x, y) => y.$1.compareTo(x.$1));
  final picked = <Stretch>[];
  for (final (_, s) in scored) {
    final clash = picked.any((p) => math.min(p.to, s.to) - math.max(p.from, s.from) > 0.3 * s.km);
    if (!clash) picked.add(s);
    if (picked.length >= max) break;
  }
  return picked;
}

/// The most-driven stretches across all trips, most-driven first. Each trip
/// appears in at most one stretch as its base.
List<Stretch> commonStretches(List<Track> tracks, {int minTrips = 3}) {
  final sorted = [...tracks]..sort((a, b) => b.start.compareTo(a.start));
  final out = <Stretch>[];
  final covered = <String>{};
  for (final t in sorted) {
    if (covered.contains(t.id)) continue;
    final s = findStretches(t, sorted, max: 1);
    if (s.isEmpty || s.first.runs.length < minTrips) continue;
    out.add(s.first);
    covered.addAll(s.first.runs.map((r) => r.track.id));
  }
  out.sort((a, b) => b.runs.length.compareTo(a.runs.length));
  return out;
}

/// The figures that can be compared for one trip's run over a stretch.
class RunStats {
  final String tripId;
  final DateTime at; // when the stretch started
  final double km;
  final Duration time, moving;
  final int stops;
  final double maxKmh;
  final int? lights, redLights;
  final TripWeather? weather;
  const RunStats({
    required this.tripId,
    required this.at,
    required this.km,
    required this.time,
    required this.moving,
    required this.stops,
    required this.maxKmh,
    this.lights,
    this.redLights,
    this.weather,
  });
  double get avgKmh => time.inSeconds == 0 ? 0 : km / (time.inSeconds / 3600);
  double get movingKmh => moving.inSeconds == 0 ? 0 : km / (moving.inSeconds / 3600);
  bool get rainy {
    final c = weather?.code ?? 0;
    return (weather?.rainMm ?? 0) >= 0.2 || (c >= 51 && c <= 67) || (c >= 80 && c <= 82) || c >= 95;
  }
}

RunStats runStats(StretchRun r) {
  final t = r.track;
  final t0 = t.timeAt(r.from), t1 = t.timeAt(r.to);
  final sub = [for (final s in t.samples) if (!s.at.isBefore(t0) && !s.at.isAfter(t1)) s];
  final st = sub.length >= 2 ? computeTripStats(sub) : null;
  final time = t1.difference(t0);
  int? lights, red;
  if (t.lights.isNotEmpty) {
    final path = t.slice(r.from, r.to);
    final on = [
      for (final l in t.lights)
        if (path.any((p) => haversineKm(p.lat, p.lon, l.lat, l.lon) <= 0.03)) l,
    ];
    lights = on.length;
    red = on.where((l) => l.stopped).length;
  }
  return RunStats(
    tripId: t.id,
    at: t0,
    km: r.to - r.from,
    time: time,
    moving: st == null ? time : (st.moving > time ? time : st.moving),
    stops: st == null ? 0 : st.shortStops + st.stops.length,
    maxKmh: st?.maxKmh ?? 0,
    lights: lights,
    redLights: red,
    weather: t.weather,
  );
}

/// Groups for "what makes it slower": weekday peaks, other times, weekends,
/// and rain.
enum RunGroup { morningPeak, eveningPeak, offPeak, weekend, rain, dry }

String runGroupLabel(RunGroup g) => switch (g) {
      RunGroup.morningPeak => 'Weekday mornings (7–9:30)',
      RunGroup.eveningPeak => 'Weekday evenings (4–6:30)',
      RunGroup.offPeak => 'Other weekday times',
      RunGroup.weekend => 'Weekends',
      RunGroup.rain => 'In the rain',
      RunGroup.dry => 'Dry',
    };

RunGroup timeGroup(DateTime local) {
  if (local.weekday >= DateTime.saturday) return RunGroup.weekend;
  final m = local.hour * 60 + local.minute;
  if (m >= 7 * 60 && m < 9 * 60 + 30) return RunGroup.morningPeak;
  if (m >= 16 * 60 && m < 18 * 60 + 30) return RunGroup.eveningPeak;
  return RunGroup.offPeak;
}

T median<T extends num>(List<T> v) {
  final s = [...v]..sort();
  return s[s.length ~/ 2];
}

/// Median of [value] per group, for groups with at least two runs.
Map<RunGroup, double> groupMedians(List<RunStats> runs, double Function(RunStats) value) {
  final g = <RunGroup, List<double>>{};
  for (final r in runs) {
    (g[timeGroup(r.at.toLocal())] ??= []).add(value(r));
    if (r.weather != null) (g[r.rainy ? RunGroup.rain : RunGroup.dry] ??= []).add(value(r));
  }
  return {
    for (final k in RunGroup.values)
      if ((g[k]?.length ?? 0) >= 2) k: median(g[k]!),
  };
}

/// "Home → Work"-style name for a stretch, from places within 1 km of its ends.
String stretchName(Stretch s, List<Place> places) {
  Place? near(LatLon p) {
    Place? best;
    var bestKm = 1.0;
    for (final pl in places) {
      final d = haversineKm(p.lat, p.lon, pl.lat, pl.lon);
      if (d <= bestKm) {
        bestKm = d;
        best = pl;
      }
    }
    return best;
  }

  final a = near(s.startAt), b = near(s.endAt);
  final title = placeTitle(a, b);
  final km = '${s.km.toStringAsFixed(1)} km';
  return title == null ? '$km stretch' : '$title ($km)';
}

/// Where a trip set off on a stretch, by half hour of the day.
class TimeSlot {
  final int minute; // minutes after midnight the slot starts
  final List<RunStats> runs;
  const TimeSlot(this.minute, this.runs);
}

/// Runs grouped by the half hour they reached the stretch, weekdays and
/// weekends kept apart because traffic differs. Slots without runs are left out.
List<TimeSlot> timeSlots(List<RunStats> runs, {required bool weekend, int slotMin = 30}) {
  final g = <int, List<RunStats>>{};
  for (final r in runs) {
    final l = r.at.toLocal();
    if ((l.weekday >= DateTime.saturday) != weekend) continue;
    final m = (l.hour * 60 + l.minute) ~/ slotMin * slotMin;
    (g[m] ??= []).add(r);
  }
  final keys = g.keys.toList()..sort();
  return [for (final k in keys) TimeSlot(k, g[k]!)];
}

/// Why another trip isn't (quite) counted as driving the same road.
enum NearReason {
  /// Shares the stretch, but less than 90% of it.
  partCover,
  /// Shares road the same way, but under 2 km in one go.
  tooShort,
  /// Would match if GPS points within 90 m counted (40 m is the rule).
  drift,
  /// Same road, driven the other way.
  opposite,
}

/// A trip that nearly matched this one, with a 0–1 score of how close it came
/// (1 would count).
class NearMatch {
  final String tripId;
  final DateTime start;
  final double score;
  final NearReason reason;
  final double sharedKm; // same way, within 40 m (or other-way / 90 m km for those reasons)
  final int pieces;
  final int? stretch; // index into the stretches shown, for partCover
  final double? cover; // share of that stretch driven
  const NearMatch(this.tripId, this.start, this.score, this.reason, this.sharedKm, {this.pieces = 1, this.stretch, this.cover});
}

double _sum(List<Overlap> o) => o.fold(0.0, (a, x) => a + x.km);

/// Trips that came close to matching [t] but don't count on [shown], best
/// first. Trips already on a shown stretch are left out.
List<NearMatch> nearMatches(Track t, Iterable<Track> others, List<Stretch> shown, {int max = 6, double cover = 0.9}) {
  final counted = {for (final s in shown) for (final r in s.runs) r.track.id};
  final out = <NearMatch>[];
  for (final o in others) {
    if (o.id == t.id || counted.contains(o.id) || o.pts.isEmpty) continue;
    if (t.coarse.intersection(o.coarse).length < 3) continue;
    final same = overlaps(t, o, minKm: 0.3);
    final sameKm = _sum(same);
    if (same.any((x) => x.km >= minStretchKm)) {
      // It shares a full stretch, just not enough of the one shown.
      var best = 0.0;
      int? bestI;
      for (final (i, s) in shown.indexed) {
        final got = same.fold(0.0, (a, x) => a + math.max(0.0, math.min(x.a1, s.to) - math.max(x.a0, s.from))) / s.km;
        if (got > best) {
          best = got;
          bestI = i;
        }
      }
      if (bestI != null && best > 0.3) {
        out.add(NearMatch(o.id, o.start, math.min(0.99, best / cover), NearReason.partCover, sameKm, stretch: bestI, cover: best));
      }
      continue;
    }
    if (sameKm >= 0.5) {
      out.add(NearMatch(o.id, o.start, math.min(0.99, same.map((x) => x.km).reduce(math.max) / minStretchKm), NearReason.tooShort, sameKm, pieces: same.length));
      continue;
    }
    final loose = overlaps(t, o, minKm: 0.5, matchKm: _looseMatchKm);
    final looseKm = _sum(loose);
    if (looseKm >= 0.5) {
      out.add(NearMatch(o.id, o.start, math.min(0.9, 0.9 * loose.map((x) => x.km).reduce(math.max) / minStretchKm), NearReason.drift, looseKm, pieces: loose.length));
      continue;
    }
    final back = overlaps(t, Track.from(o.id, o.samples.reversed.toList()), minKm: 0.5);
    final backKm = _sum(back);
    if (backKm >= 0.5) {
      // Never counts, so it scores low; still worth knowing.
      out.add(NearMatch(o.id, o.start, 0.1 * math.min(1.0, backKm / minStretchKm), NearReason.opposite, backKm, pieces: back.length));
    }
  }
  out.sort((a, b) => b.score.compareTo(a.score));
  return out.take(max).toList();
}
