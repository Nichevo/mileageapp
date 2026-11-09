/// Speed and elevation along a trip, for the coloured route and the charts.
library;

import 'trip_stats.dart';

/// Speed bands used to colour the route, in km/h (upper bounds).
const speedColourBands = [10.0, 30.0, 50.0, 80.0];

/// Index into the colour scale for a speed: 0 slow/stopped .. 4 fast.
int speedBand(double? kmh) {
  if (kmh == null) return 2;
  for (var i = 0; i < speedColourBands.length; i++) {
    if (kmh < speedColourBands[i]) return i;
  }
  return speedColourBands.length;
}

String speedBandLabel(int i) => switch (i) {
      0 => 'under 10',
      1 => '10–30',
      2 => '30–50',
      3 => '50–80',
      _ => '80+',
    };

/// Speed at each sample in km/h: the GPS speed when there is one,
/// otherwise worked out from the neighbouring points.
List<double?> pointSpeedsKmh(List<GpsSample> s) => [
      for (var i = 0; i < s.length; i++)
        s[i].speedMps != null
            ? s[i].speedMps! * 3.6
            : () {
                final a = s[i == 0 ? 0 : i - 1], b = s[i == s.length - 1 ? i : i + 1];
                final h = b.at.difference(a.at).inMilliseconds / 3600000;
                return h > 0 ? haversineKm(a.lat, a.lon, b.lat, b.lon) / h : null;
              }(),
    ];

class ProfilePoint {
  final double minutes; // since the start
  final double km; // along the route
  final double? kmh;
  final double? altitudeM;
  const ProfilePoint(this.minutes, this.km, this.kmh, this.altitudeM);
}

/// The trip as at most [maxPoints] evenly spaced (in time) points, each the
/// average of the samples it covers. Inaccurate fixes are skipped.
List<ProfilePoint> tripProfile(List<GpsSample> raw, {int maxPoints = 240}) {
  final s = raw.where((p) => (p.accuracyM ?? 0) <= maxAccuracyM).toList();
  if (s.length < 2) return const [];
  final speeds = pointSpeedsKmh(s);
  final t0 = s.first.at;
  final totalMin = s.last.at.difference(t0).inMilliseconds / 60000;
  if (totalMin <= 0) return const [];
  final buckets = maxPoints.clamp(2, s.length);
  final step = totalMin / buckets;
  final out = <ProfilePoint>[];
  var km = 0.0;
  var i = 0;
  for (var b = 0; b < buckets; b++) {
    final end = (b + 1) * step;
    var n = 0, vSum = 0.0, vN = 0, aSum = 0.0, aN = 0;
    double? mid;
    while (i < s.length && (s[i].at.difference(t0).inMilliseconds / 60000 <= end || b == buckets - 1)) {
      if (i > 0) km += haversineKm(s[i - 1].lat, s[i - 1].lon, s[i].lat, s[i].lon);
      mid ??= s[i].at.difference(t0).inMilliseconds / 60000;
      if (speeds[i] != null) {
        vSum += speeds[i]!;
        vN++;
      }
      if (s[i].altitudeM != null) {
        aSum += s[i].altitudeM!;
        aN++;
      }
      n++;
      i++;
    }
    if (n == 0) continue;
    out.add(ProfilePoint(mid!, km, vN == 0 ? null : vSum / vN, aN == 0 ? null : aSum / aN));
  }
  return out;
}
