import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/domain/trip_stats.dart';

/// Builds a synthetic drive heading north from a made-up origin.
/// Each leg is (seconds, km/h); samples every [step] seconds.
List<GpsSample> drive(List<(int, double)> legs, {int step = 2}) {
  final out = <GpsSample>[];
  var t = DateTime(2026, 1, 1, 9);
  var lat = -40.0;
  const lon = 175.0;
  out.add(GpsSample(t, lat, lon, speedMps: 0, accuracyM: 5));
  for (final (secs, kmh) in legs) {
    for (var s = 0; s < secs; s += step) {
      t = t.add(Duration(seconds: step));
      lat += (kmh * step / 3600) / 111.2; // ~111.2 km per degree of latitude
      out.add(GpsSample(t, lat, lon, speedMps: kmh / 3.6, accuracyM: 5));
    }
  }
  return out;
}

void main() {
  test('parses recorder lines and skips junk', () {
    final pts = GpsSample.parseAll('1767225600000,-40.1,175.2,13.4,6,120\nbad line\n1767225602000,-40.1001,175.2,,,\n');
    expect(pts.length, 2);
    expect(pts.first.speedMps, closeTo(13.4, 1e-9));
    expect(pts.last.speedMps, isNull);
  });

  test('distance, moving time and average speeds', () {
    final s = computeTripStats(drive([(600, 50), (60, 0), (600, 100)]));
    expect(s.distanceKm, closeTo(8.33 + 16.67, 0.3));
    expect(s.moving.inSeconds, closeTo(1200, 4));
    expect(s.stopped.inSeconds, closeTo(60, 4));
    expect(s.movingAvgKmh!, closeTo(75, 1.5));
    expect(s.avgKmh!, lessThan(s.movingAvgKmh!));
    expect(s.maxKmh, closeTo(100, 0.5));
  });

  test('short stops versus long stops', () {
    final s = computeTripStats(drive([(120, 50), (30, 0), (120, 50), (40, 0), (120, 50), (600, 0), (60, 50)]));
    expect(s.shortStops, 2);
    expect(s.stops.length, 1);
    expect(s.stops.first.duration.inSeconds, closeTo(600, 4));
  });

  test('speed bands split distance', () {
    final s = computeTripStats(drive([(600, 45), (600, 80), (600, 100)]));
    expect(s.bandKm[SpeedBand.urban]!, closeTo(7.5, 0.3));
    expect(s.bandKm[SpeedBand.openRoad]!, closeTo(13.3, 0.3));
    expect(s.bandKm[SpeedBand.motorway]!, closeTo(16.7, 0.3));
  });

  test('harsh braking is counted', () {
    final s = computeTripStats(drive([(60, 60), (2, 30), (2, 0)]));
    expect(s.harshBrakes, greaterThanOrEqualTo(1));
  });

  test('inaccurate samples and glitches are ignored', () {
    final pts = drive([(120, 50)]);
    pts.insert(10, GpsSample(pts[9].at.add(const Duration(milliseconds: 500)), -39.0, 175.0, speedMps: 14, accuracyM: 500));
    final s = computeTripStats(pts);
    expect(s.distanceKm, closeTo(1.67, 0.1));
  });

  test('stats survive the json summary', () {
    final s = computeTripStats(drive([(600, 50), (600, 100)]));
    final back = TripStats.fromJson(s.toJson());
    expect(back.distanceKm, closeTo(s.distanceKm, 1e-9));
    expect(back.moving, s.moving);
    expect(back.bandKm[SpeedBand.motorway], s.bandKm[SpeedBand.motorway]);
  });
}
