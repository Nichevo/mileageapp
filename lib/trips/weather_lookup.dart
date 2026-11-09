import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../data/repository.dart';
import '../domain/trip_stats.dart';
import '../domain/trip_weather.dart';

/// Looks up the weather at the middle of a trip and the ground height along
/// it from Open-Meteo (free, no account), and stores them in the trip's
/// stats as 'weather' and 'elev'. Only a location rounded to about 1 km and
/// the date go out for the weather; the elevation request sends points about
/// every 200 m, leaving out the first and last 300 m like the road lookup.
class WeatherLookup {
  static const forecastUrl = 'https://api.open-meteo.com/v1/forecast';
  static const archiveUrl = 'https://archive-api.open-meteo.com/v1/archive';
  static const elevationUrl = 'https://api.open-meteo.com/v1/elevation';
  static const _headers = {'User-Agent': 'MileageLog (nz.mileagelog.app)'};

  static Future<TripWeather?> weather(http.Client c, double lat, double lon, DateTime at) async {
    final day = DateFormat('yyyy-MM-dd').format(at.toUtc());
    // The forecast service keeps about three months; older dates use the archive.
    final old = DateTime.now().difference(at).inDays > 80;
    final uri = Uri.parse(old ? archiveUrl : forecastUrl).replace(queryParameters: {
      'latitude': lat.toStringAsFixed(2),
      'longitude': lon.toStringAsFixed(2),
      'hourly': 'temperature_2m,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
      'start_date': day,
      'end_date': day,
      'timezone': 'GMT',
    });
    final r = await c.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
    if (r.statusCode != 200) throw Exception('Weather lookup failed (${r.statusCode})');
    return weatherAt(jsonDecode(r.body) as Map<String, Object?>, at);
  }

  static Future<TripElevation?> elevation(http.Client c, List<GpsSample> samples) async {
    final pts = elevationPoints(samples);
    // Leave the ends off, as the road lookup does.
    final total = pts.isEmpty ? 0.0 : pts.last.km;
    final inner = pts.where((p) => p.km >= 0.3 && p.km <= total - 0.3).toList();
    if (inner.length < 3) return null;
    final heights = <double>[];
    for (var i = 0; i < inner.length; i += 100) {
      final chunk = inner.sublist(i, (i + 100).clamp(0, inner.length));
      final uri = Uri.parse(elevationUrl).replace(queryParameters: {
        'latitude': chunk.map((p) => p.lat.toStringAsFixed(5)).join(','),
        'longitude': chunk.map((p) => p.lon.toStringAsFixed(5)).join(','),
      });
      final r = await c.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
      if (r.statusCode != 200) throw Exception('Elevation lookup failed (${r.statusCode})');
      final list = (jsonDecode(r.body) as Map<String, Object?>)['elevation'] as List?;
      if (list == null || list.length != chunk.length) throw Exception('Unexpected elevation reply');
      heights.addAll(list.map((e) => (e as num).toDouble()));
    }
    return TripElevation.fromHeights([for (final p in inner) p.km], heights);
  }

  /// Looks up and saves weather and elevation for one trip.
  static Future<({TripWeather? weather, TripElevation? elev})?> analyse(Repository repo, String tripId, {http.Client? client}) async {
    final trip = await repo.trip(tripId);
    if (trip == null) return null;
    final pts = await repo.tripPoints(tripId);
    final samples = [
      for (final p in pts) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM, altitudeM: p.altitudeM),
    ];
    if (samples.length < 2) return null;
    final c = client ?? http.Client();
    try {
      final mid = samples[samples.length ~/ 2];
      final w = await weather(c, mid.lat, mid.lon, mid.at);
      final e = await elevation(c, samples);
      // Re-read: the road lookup may have saved in the meantime.
      final fresh = await repo.trip(tripId);
      final stats = fresh?.statsJson == null ? computeTripStats(samples).toJson() : (jsonDecode(fresh!.statsJson!) as Map<String, Object?>);
      stats['weather'] = w?.toJson() ?? false; // false: looked up, nothing found
      stats['elev'] = e?.toJson() ?? false;
      await repo.setTripStatsJson(tripId, jsonEncode(stats));
      return (weather: w, elev: e);
    } finally {
      if (client == null) c.close();
    }
  }

  static bool done(String? statsJson) => statsJson != null && (jsonDecode(statsJson) as Map<String, Object?>).containsKey('weather');

  static bool _busy = false;

  /// Looks up recent finished trips that don't have weather yet. Quiet:
  /// failures are left for next time (or the trip page).
  static Future<void> analyseRecent(Repository repo, String vehicleId, {int max = 3}) async {
    if (_busy) return;
    _busy = true;
    try {
      final since = DateTime.now().subtract(const Duration(days: 14));
      final trips = (await repo.db.select(repo.db.trips).get())
          .where((t) => t.vehicleId == vehicleId && t.status == 'done' && t.startAt.isAfter(since) && !done(t.statsJson))
          .toList()
        ..sort((a, b) => b.startAt.compareTo(a.startAt));
      for (final t in trips.take(max)) {
        await analyse(repo, t.id);
      }
    } catch (_) {
      // offline; try again later
    } finally {
      _busy = false;
    }
  }
}
