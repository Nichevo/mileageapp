/// Rough weather and ground elevation for a trip, from the free Open-Meteo
/// service (no account). Pure parsing and maths; the requests are in
/// lib/trips/weather_lookup.dart.
library;

import 'dart:math' as math;

import 'trip_stats.dart';

class TripWeather {
  final double tempC;
  final double rainMm; // in the hour
  final int code; // WMO weather code
  final double windKmh;
  final double windFromDeg;
  const TripWeather({required this.tempC, required this.rainMm, required this.code, required this.windKmh, required this.windFromDeg});

  Map<String, Object?> toJson() => {'t': tempC, 'rain': rainMm, 'code': code, 'wind': windKmh, 'dir': windFromDeg};

  static TripWeather? fromJson(Object? j) {
    if (j is! Map) return null;
    double d(String k) => (j[k] as num?)?.toDouble() ?? 0;
    return TripWeather(tempC: d('t'), rainMm: d('rain'), code: (j['code'] as num?)?.toInt() ?? 0, windKmh: d('wind'), windFromDeg: d('dir'));
  }

  /// "14°C, light rain, 22 km/h headwind".
  String describe({double? headingDeg}) {
    final parts = ['${tempC.round()}°C', weatherLabel(code, rainMm)];
    if (windKmh >= 10) {
      final rel = headingDeg == null ? null : windRelative(windFromDeg, headingDeg);
      parts.add('${windKmh.round()} km/h ${rel ?? 'wind'}');
    }
    return parts.join(', ');
  }
}

/// WMO weather code in words, with rain amount to tell light from heavy.
String weatherLabel(int code, double rainMm) {
  if (code >= 95) return 'thunderstorms';
  if (code >= 71 && code <= 77 || code == 85 || code == 86) return 'snow';
  if (code >= 51 && code <= 67 || code >= 80 && code <= 82) {
    if (rainMm >= 4) return 'heavy rain';
    if (rainMm >= 1) return 'rain';
    return code <= 57 ? 'drizzle' : 'light rain';
  }
  if (code == 45 || code == 48) return 'fog';
  if (code == 3) return 'overcast';
  if (code == 1 || code == 2) return 'some cloud';
  return 'clear';
}

/// Wind relative to the direction of travel.
String windRelative(double windFromDeg, double headingDeg) {
  // Wind *from* the heading direction blows in your face.
  var diff = (windFromDeg - headingDeg).abs() % 360;
  if (diff > 180) diff = 360 - diff;
  if (diff <= 45) return 'headwind';
  if (diff >= 135) return 'tailwind';
  return 'crosswind';
}

/// Compass bearing from the start of a route to its end, in degrees.
double? overallHeading(List<GpsSample> s) {
  if (s.length < 2) return null;
  final a = s.first, b = s.last;
  if (haversineKm(a.lat, a.lon, b.lat, b.lon) < 1) return null; // round trip: no single heading
  final la1 = a.lat * math.pi / 180, la2 = b.lat * math.pi / 180, dl = (b.lon - a.lon) * math.pi / 180;
  final y = math.sin(dl) * math.cos(la2);
  final x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dl);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// The hour of an Open-Meteo hourly reply (requested with timezone=GMT)
/// nearest to [at].
TripWeather? weatherAt(Map<String, Object?> json, DateTime at) {
  final h = json['hourly'];
  if (h is! Map) return null;
  final times = (h['time'] as List?)?.cast<String>() ?? const [];
  if (times.isEmpty) return null;
  final utc = at.toUtc();
  var best = -1;
  var bestD = 1 << 30;
  for (var i = 0; i < times.length; i++) {
    final t = DateTime.tryParse('${times[i]}Z');
    if (t == null) continue;
    final d = t.difference(utc).inMinutes.abs();
    if (d < bestD) {
      bestD = d;
      best = i;
    }
  }
  if (best < 0 || bestD > 90) return null;
  double? v(String k) => ((h[k] as List?)?[best] as num?)?.toDouble();
  final temp = v('temperature_2m');
  if (temp == null) return null;
  return TripWeather(
    tempC: temp,
    rainMm: v('precipitation') ?? 0,
    code: (v('weather_code') ?? 0).round(),
    windKmh: v('wind_speed_10m') ?? 0,
    windFromDeg: v('wind_direction_10m') ?? 0,
  );
}

/// Points about every [stepKm] along the route (start and end included),
/// at most [maxPoints], with their distance along the route.
List<({double km, double lat, double lon})> elevationPoints(List<GpsSample> raw, {double stepKm = 0.2, int maxPoints = 300}) {
  final s = raw.where((p) => (p.accuracyM ?? 0) <= maxAccuracyM).toList();
  if (s.length < 2) return const [];
  var total = 0.0;
  for (var i = 1; i < s.length; i++) {
    total += haversineKm(s[i - 1].lat, s[i - 1].lon, s[i].lat, s[i].lon);
  }
  final step = math.max(stepKm, total / (maxPoints - 1));
  final out = [(km: 0.0, lat: s.first.lat, lon: s.first.lon)];
  var km = 0.0, next = step;
  for (var i = 1; i < s.length; i++) {
    km += haversineKm(s[i - 1].lat, s[i - 1].lon, s[i].lat, s[i].lon);
    if (km >= next) {
      out.add((km: km, lat: s[i].lat, lon: s[i].lon));
      next = km + step;
    }
  }
  if (out.last.km < km) out.add((km: km, lat: s.last.lat, lon: s.last.lon));
  return out;
}

class TripElevation {
  final double gainM, lossM, minM, maxM;
  final List<({double km, double m})> profile;
  const TripElevation(this.gainM, this.lossM, this.minM, this.maxM, this.profile);

  /// Ground heights are smooth, so only a small 1 m deadband is needed.
  static TripElevation fromHeights(List<double> km, List<double> m) {
    var gain = 0.0, loss = 0.0;
    var last = m.first;
    for (final h in m.skip(1)) {
      if ((h - last).abs() >= 1) {
        if (h > last) {
          gain += h - last;
        } else {
          loss += last - h;
        }
        last = h;
      }
    }
    return TripElevation(gain, loss, m.reduce(math.min), m.reduce(math.max), [for (var i = 0; i < m.length; i++) (km: km[i], m: m[i])]);
  }

  Map<String, Object?> toJson() => {
        'gain': gainM.round(),
        'loss': lossM.round(),
        'min': minM.round(),
        'max': maxM.round(),
        'pts': [for (final p in profile) [double.parse(p.km.toStringAsFixed(2)), p.m.round()]],
      };

  static TripElevation? fromJson(Object? j) {
    if (j is! Map) return null;
    final pts = [
      for (final p in (j['pts'] as List? ?? const []))
        if (p is List && p.length >= 2) (km: (p[0] as num).toDouble(), m: (p[1] as num).toDouble()),
    ];
    if (pts.isEmpty) return null;
    double d(String k) => (j[k] as num?)?.toDouble() ?? 0;
    return TripElevation(d('gain'), d('loss'), d('min'), d('max'), pts);
  }
}
