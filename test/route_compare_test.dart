import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/places.dart';
import 'package:mileagelog/domain/road_match.dart' show LightPass;
import 'package:mileagelog/domain/route_compare.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/domain/trip_weather.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/trip_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive, lat0;

/// Same samples moved in time and slightly sideways (GPS drift).
List<GpsSample> moved(List<GpsSample> s, Duration by, {double dLat = 0}) =>
    [for (final p in s) GpsSample(p.at.add(by), p.lat + dLat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM)];

/// Same times, route driven the other way.
List<GpsSample> reversed(List<GpsSample> s) {
  final r = s.reversed.toList();
  return [for (var i = 0; i < s.length; i++) GpsSample(s[i].at, r[i].lat, r[i].lon, speedMps: s[i].speedMps, accuracyM: s[i].accuracyM)];
}

void main() {
  final a = drive(174.70, 174.76); // about 5 km east
  final b = moved(drive(174.72, 174.80, stopAt: [174.74], stopFor: const Duration(seconds: 60)), const Duration(days: 2), dLat: 0.0001);
  final c = moved(reversed(a), const Duration(days: 3)); // same road, other way
  final d = moved(a, const Duration(days: 4), dLat: 0.01); // a parallel road 1 km away
  final e = moved(a, const Duration(days: 7, hours: 9)); // same as a, evening

  test('overlaps find shared stretches driven the same way, with drift', () {
    final ta = Track.from('a', a), tb = Track.from('b', b);
    expect(ta.km, closeTo(5.0, 0.2));
    final o = overlaps(ta, tb);
    expect(o, hasLength(1));
    expect(o.single.a0, closeTo(1.67, 0.15)); // b joins at 174.72
    expect(o.single.a1, closeTo(ta.km, 0.1));
    expect(o.single.b0, closeTo(0, 0.1));
    expect(overlaps(ta, Track.from('c', c)), isEmpty);
    expect(overlaps(ta, Track.from('d', d)), isEmpty);
    expect(overlaps(ta, Track.from('short', drive(174.70, 174.715))), isEmpty); // under 2 km
  });

  test('stretches of a trip, run stats and groups', () {
    final tracks = [
      Track.from('a', a, lights: const [LightPass(lat0, 174.745, true), LightPass(lat0, 174.71, false)]),
      Track.from('b', b),
      Track.from('c', c),
      Track.from('d', d),
      Track.from('e', e, weather: const TripWeather(tempC: 12, rainMm: 2, code: 63, windKmh: 10, windFromDeg: 0)),
    ];
    final s = findStretches(tracks.first, tracks);
    expect(s, isNotEmpty);
    final best = s.first;
    // b covers only the eastern part, so the best stretch is the one a, b and e share.
    expect(best.runs.map((r) => r.track.id), ['a', 'b', 'e']);
    expect(best.km, closeTo(3.3, 0.2));
    final stats = [for (final r in best.runs) runStats(r)];
    final ra = stats[0], rb = stats[1], re = stats[2];
    expect(ra.avgKmh, closeTo(50, 2));
    expect(rb.time - ra.time, greaterThan(const Duration(seconds: 50))); // the minute stopped
    expect(rb.stops, 1);
    expect(ra.lights, 1); // only the light on the shared stretch
    expect(ra.redLights, 1);
    expect(rb.lights, isNull); // no road lookup
    expect(re.rainy, isTrue);
    expect(timeGroup(DateTime(2026, 11, 9, 8)), RunGroup.morningPeak); // Monday
    expect(timeGroup(DateTime(2026, 11, 8, 8)), RunGroup.weekend);
    final g = groupMedians([ra, rb, re, ra], (r) => r.time.inSeconds.toDouble());
    expect(g.containsKey(RunGroup.rain), isFalse); // only one rainy run
    expect(commonStretches(tracks), hasLength(1));
    expect(commonStretches(tracks).single.runs, hasLength(3));
    const home = Place('h', 'Home', lat0, 174.72);
    expect(stretchName(best, [home]), startsWith('From Home'));
    expect(stretchName(best, const []), '3.3 km stretch');
  });

  test('near matches are scored with the reason they do not count', () {
    final short = moved(drive(174.70, 174.715), const Duration(days: 5)); // about 1.3 km
    final drift = moved(a, const Duration(days: 6), dLat: 0.0006); // about 67 m off
    final part = moved(drive(174.70, 174.745), const Duration(days: 8));
    final far = moved(a, const Duration(days: 9), dLat: 0.05);
    final tracks = [
      Track.from('a', a),
      Track.from('b', b),
      Track.from('c', c),
      Track.from('e', e),
      Track.from('short', short),
      Track.from('drift', drift),
      Track.from('part', part),
      Track.from('far', far),
    ];
    final shown = findStretches(tracks.first, tracks);
    final near = nearMatches(tracks.first, tracks, shown);
    final why = {for (final n in near) n.tripId: n.reason};
    final counted = {for (final s in shown) for (final r in s.runs) r.track.id};
    expect(counted, containsAll(['a', 'e']));
    expect(why.keys.toSet().intersection(counted), isEmpty);
    expect(why['short'], NearReason.tooShort);
    expect(why['drift'], NearReason.drift);
    expect(why['c'], NearReason.opposite);
    expect(why.containsKey('far'), isFalse);
    // Whichever of b and part didn't make the shown stretch covers only part of it.
    expect([why['b'], why['part']].where((r) => r == NearReason.partCover), hasLength(1));
    final byId = {for (final n in near) n.tripId: n};
    expect(byId['short']!.score, closeTo(0.63, 0.08));
    expect(byId['drift']!.score, closeTo(0.9, 0.01));
    expect(byId['c']!.score, lessThan(0.11));
    expect(near.first.score >= near.last.score, isTrue);
  });

  test('runs by half hour, weekdays and weekends apart', () {
    RunStats run(DateTime at, int min) => RunStats(tripId: '$at', at: at, km: 3, time: Duration(minutes: min), moving: Duration(minutes: min), stops: 0, maxKmh: 50);
    final runs = [
      run(DateTime(2026, 11, 9, 7, 10), 10), // Monday
      run(DateTime(2026, 11, 10, 7, 25), 12),
      run(DateTime(2026, 11, 11, 8, 5), 15),
      run(DateTime(2026, 11, 14, 7, 15), 8), // Saturday
    ];
    final wk = timeSlots(runs, weekend: false);
    expect(wk.map((s) => s.minute), [7 * 60, 8 * 60]);
    expect(wk.first.runs, hasLength(2));
    expect(timeSlots(runs, weekend: true).single.runs.single.time, const Duration(minutes: 8));
  });

  testWidgets('trip page compares a stretch with other trips', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false, 'weatherLookup': false});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    for (final (id, s) in [('a', a), ('b', b), ('c', c), ('e', e)]) {
      await repo.saveRecordedTrip(
        TripsCompanion.insert(
            id: id, vehicleId: v.id, name: 'Trip $id', startAt: s.first.at, endAt: Value(s.last.at), status: const Value('done'), statsJson: Value(jsonEncode(computeTripStats(s).toJson()))),
        [for (final p in s) TripPointsCompanion.insert(tripId: id, at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM))],
        const [],
      );
    }
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripDetailPage(tripId: 'e'))));
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Compared with other trips'), findsOneWidget);
    expect(find.textContaining('driven 3 times'), findsOneWidget);
    expect(find.textContaining('quickest of 3'), findsOneWidget);
    expect(find.text('1 trip nearly matched'), findsOneWidget);
    await tester.tap(find.text('1 trip nearly matched'));
    await tester.pumpAndSettle();
    expect(find.textContaining('the other way'), findsOneWidget); // trip c
    await tester.tap(find.textContaining('driven 3 times'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Driven 3 times'), findsOneWidget);
    expect(find.textContaining('(this trip)'), findsOneWidget);
    await tester.tap(find.text('Stops'));
    await tester.pump();
    expect(find.text('Each time, best first'), findsOneWidget);
    await tester.tap(find.text('By time of day'));
    await tester.pumpAndSettle();
    expect(find.text('Weekdays, by time you reached it'), findsOneWidget);
    expect(find.text('Weekends, by time you reached it'), findsOneWidget);
    expect(find.textContaining('Orange: weekend.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
