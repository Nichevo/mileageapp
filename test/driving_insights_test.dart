import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/driving_stats.dart';
import 'package:mileagelog/domain/road_match.dart';
import 'package:mileagelog/domain/stats.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/insights_page.dart';
import 'package:mileagelog/ui/lights_page.dart';
import 'package:mileagelog/ui/trips_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'trip_upgrades_test.dart' show saveTrip, settle, shifted;

const lat0 = -36.85;
const mPerLon = 111320 * 0.80038; // cos(36.85°)

/// Drives east from lon 174.7: ('go', metres) at 40 km/h, ('stop', seconds)
/// standing still, ('creep', metres) at 8 km/h. A sample every 2 s.
List<GpsSample> sim(List<(String, double)> legs, {DateTime? start}) {
  var t = start ?? DateTime(2026, 11, 8, 8);
  var x = 0.0;
  final out = <GpsSample>[];
  void add(double mps) {
    out.add(GpsSample(t, lat0, 174.7 + x / mPerLon, speedMps: mps, accuracyM: 5));
    t = t.add(const Duration(seconds: 2));
  }

  for (final (kind, v) in legs) {
    if (kind == 'stop') {
      for (var i = 0; i < v ~/ 2; i++) {
        add(0);
      }
      continue;
    }
    final mps = kind == 'go' ? 40 / 3.6 : 8 / 3.6;
    final end = x + v;
    while (x < end) {
      add(mps);
      x = (x + mps * 2).clamp(0, end).toDouble();
    }
  }
  add(40 / 3.6);
  return out;
}

LL at(double m) => (lat: lat0, lon: 174.7 + m / mPerLon);

void main() {
  group('red phases at a light', () {
    final light = [at(600)];
    test('straight through on green', () {
      final l = lightWaits(sim([('go', 1200)]), light).single;
      expect(l.stopped, isFalse);
      expect(l.phases, 0);
      expect(l.counted, isTrue);
    });

    test('one red: stop near the line, then go', () {
      final l = lightWaits(sim([('go', 580), ('stop', 40), ('go', 600)]), light).single;
      expect(l.stopped, isTrue);
      expect(l.phases, 1);
      expect(l.waitS, inInclusiveRange(36, 46));
    });

    test('missed the first green: creep up the queue and wait again', () {
      final l = lightWaits(sim([('go', 520), ('stop', 40), ('creep', 60), ('stop', 30), ('go', 600)]), light).single;
      expect(l.stopped, isTrue);
      expect(l.phases, 2);
      expect(l.waitS, greaterThan(70));
    });

    test('two long reds in the queue are light waits, not parking', () {
      final trip = sim([('go', 480), ('stop', 150), ('creep', 80), ('stop', 140), ('go', 600)]);
      final l = lightWaits(trip, light).single;
      expect(l.phases, 2);
      final stats = computeTripStats(trip);
      expect(stats.stops.length, 2);
      expect(stats.stops.every((x) => waitingAtLight(x.lat, x.lon, x.duration, [l])), isTrue);
      // A long stop well away from any light is still a stop.
      final far = computeTripStats(sim([('go', 100), ('stop', 200), ('go', 1100)])).stops.single;
      expect(waitingAtLight(far.lat, far.lon, far.duration, [l]), isFalse);
    });

    test('phases survive the JSON round trip; old entries have none', () {
      final r = RoadStats(roadKm: const {RoadClass.local: 1.2}, lights: [LightPass(1, 2, true, waitS: 50, phases: 2), LightPass(3, 4, false, waitS: 0, phases: 0)], waitAtLights: const Duration(seconds: 50));
      final back = RoadStats.fromJson(jsonDecode(jsonEncode(r.toJson())) as Map<String, Object?>);
      expect(back.cyclesCounted, isTrue);
      expect(back.redPhases, 2);
      expect(back.multiPhaseLights, 1);
      final old = RoadStats.fromJson({
        'roadKm': {'local': 1.0},
        'lights': [
          [1.0, 2.0, 1],
        ],
        'waitS': 30,
      });
      expect(old.cyclesCounted, isFalse);
      expect(old.redPhases, 1);
    });
  });

  String statsJson(List<GpsSample> s, {RoadStats? road, Map<String, Object?>? weather}) =>
      jsonEncode({...computeTripStats(s).toJson(), 'road': ?road?.toJson(), 'weather': ?weather});

  test('driving periods sum trips, speeds, roads and lights by month', () {
    final a = sim([('go', 6000)], start: DateTime(2026, 9, 3, 8));
    final b = sim([('go', 2000), ('stop', 40), ('go', 2000)], start: DateTime(2026, 9, 20, 17));
    final c = sim([('go', 3000)], start: DateTime(2026, 11, 2, 8));
    final road = RoadStats(
      roadKm: const {RoadClass.suburban: 3, RoadClass.motorway: 1},
      lights: [LightPass(1, 2, true, waitS: 40, phases: 1), LightPass(3, 4, false, waitS: 0, phases: 0)],
      waitAtLights: const Duration(seconds: 40),
    );
    final facts = [
      TripFacts.fromJson(a.first.at, statsJson(a))!,
      TripFacts.fromJson(b.first.at, statsJson(b, road: road))!,
      TripFacts.fromJson(c.first.at, statsJson(c))!,
    ];
    final ps = drivingPeriods(facts, Period.month, now: DateTime(2026, 11, 10));
    expect(ps.map((p) => p.start), [DateTime(2026, 9), DateTime(2026, 10), DateTime(2026, 11)]);
    expect(ps.map((p) => p.trips), [2, 0, 1]);
    expect(ps[0].km, closeTo(10, 0.1));
    expect(ps[0].movingKmh, closeTo(40, 2));
    expect(ps[0].avgKmh!, lessThan(ps[0].movingKmh!));
    expect(ps[1].avgKmh, isNull);
    expect(ps[0].redShare, 0.5);
    expect(ps[0].phasesPerRed, 1);
    expect(ps[0].roadKm[RoadClass.suburban], 3);
    expect(ps[0].shortStops, 1);
    expect(tripsByHour(facts)[8], 2);
    expect(tripsByHour(facts)[17], 1);
    expect(tripsByLength(facts), [0, 2, 1, 0, 0, 0]);
    // From a later date, only that range.
    expect(drivingPeriods(facts, Period.month, from: DateTime(2026, 10), now: DateTime(2026, 11, 10)).length, 2);
  });

  test('rain from the weather code or rainfall', () {
    final s = sim([('go', 1000)]);
    TripFacts f(Map<String, Object?> w) => TripFacts.fromJson(s.first.at, statsJson(s, weather: w))!;
    expect(f({'t': 12.0, 'code': 61, 'rain': 0.0, 'wind': 10.0, 'dir': 180.0}).rainy, isTrue);
    expect(f({'t': 12.0, 'code': 2, 'rain': 0.0, 'wind': 10.0, 'dir': 180.0}).rainy, isFalse);
  });

  test('time and km between fills', () {
    final rows = [
      FuelRow(at: DateTime(2026, 9, 1), odometerKm: 1000, quantity: 40, cost: 100),
      FuelRow(at: DateTime(2026, 9, 15), odometerKm: 1500, quantity: 40, cost: 100),
      FuelRow(at: DateTime(2026, 9, 25), odometerKm: 1900, quantity: 40, cost: 100),
      FuelRow(at: DateTime(2026, 10, 20), odometerKm: 2700, quantity: 40, cost: 100),
    ];
    final g = fillGaps(rows);
    expect(g.map((x) => x.days), [14, 10, 25]);
    final by = fillGapsByPeriod(g, Period.month);
    expect(by[DateTime(2026, 9)]!.days, 12);
    expect(by[DateTime(2026, 9)]!.km, 450);
    expect(by[DateTime(2026, 10)]!.n, 1);
  });

  test('the same light on different trips is one spot; worst first', () {
    TripFacts trip(DateTime d, List<LightPass> l) => TripFacts(d, computeTripStats(sim([('go', 500)])),
        road: RoadStats(roadKm: const {}, lights: l, waitAtLights: Duration.zero));
    final a = at(300), b = at(2000);
    final trips = [
      trip(DateTime(2026, 11, 1), [LightPass(a.lat, a.lon, true, waitS: 90, phases: 2), LightPass(b.lat, b.lon, false, waitS: 0, phases: 0)]),
      trip(DateTime(2026, 11, 2), [LightPass(a.lat + 0.0001, a.lon, true, waitS: 30, phases: 1), LightPass(b.lat, b.lon, true, waitS: 20, phases: 1)]),
      trip(DateTime(2026, 11, 3), [LightPass(a.lat, a.lon, false, waitS: 0, phases: 0), LightPass(b.lat, b.lon, false, waitS: 0, phases: 0)]),
    ];
    final spots = lightHistory(trips);
    expect(spots.length, 2);
    final first = spots.firstWhere((s) => (s.lon - a.lon).abs() < 1e-6);
    expect(first.passes, 3);
    expect(first.stops, 2);
    expect(first.totalWaitS, 120);
    expect(first.multi, 1);
    expect(first.last, DateTime(2026, 11, 3));
    expect(sortLights(spots, LightSort.timeLost).first, same(first));
    expect(sortLights(spots, LightSort.phases).single, same(first));
    expect(nearPlace(a.lat, a.lon, const []), isNull);
  });

  void mockPaths() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);

  testWidgets('insights show driving over time from recorded trips', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false});
    mockPaths();
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = (await tester.runAsync(() => repo.ensureVehicle()))!;
    await settings.setActiveVehicleId(v.id);
    final now = DateTime.now();
    await tester.runAsync(() async {
      for (var i = 0; i < 6; i++) {
        await repo.upsertEvent(
          EnergyEventsCompanion.insert(id: 'e$i', vehicleId: v.id, at: DateTime(now.year, now.month - 5 + i, 3), odometerKm: 1000 + i * 500.0, quantity: 40, cost: 100),
          enqueue: false,
        );
      }
      for (var i = 0; i < 4; i++) {
        final s = shifted(sim([('go', 3000), ('stop', 30), ('go', 2000)]), DateTime(now.year, now.month - i, 2, 8 + i));
        await saveTrip(repo, v.id, 't$i', 'Trip $i', s);
      }
    });
    tester.view.physicalSize = const Size(900, 12000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: InsightsPage())));
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Driving over time'), findsOneWidget);
    expect(find.text('TRIPS PER MONTH'), findsOneWidget);
    expect(find.text('AVERAGE SPEED PER MONTH · KM/H'), findsOneWidget);
    expect(find.text('SPEED BANDS PER MONTH · SHARE OF KM'), findsOneWidget);
    expect(find.textContaining('DAYS BETWEEN'), findsOneWidget);
    expect(find.text('WHEN YOU SET OFF · TRIPS BY HOUR'), findsOneWidget);
    expect(find.textContaining('4 recorded trips'), findsOneWidget);
    await tester.tap(find.text('Weekly'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('TRIPS PER WEEK'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });

  testWidgets('trips page can show every vehicle, labelled', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false});
    mockPaths();
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final own = (await tester.runAsync(() => repo.ensureVehicle()))!;
    final other = (await tester.runAsync(() => repo.addVehicle('Work ute', 'diesel')))!;
    await settings.setActiveVehicleId(own.id);
    final today = DateTime.now();
    await tester.runAsync(() async {
      await saveTrip(repo, own.id, 'a', 'In my car', shifted(sim([('go', 2000)]), DateTime(today.year, today.month, today.day - 1, 8)));
      await saveTrip(repo, other.id, 'b', 'In the ute', shifted(sim([('go', 3000)]), DateTime(today.year, today.month, today.day - 2, 8)));
    });
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripsPage())));
    await settle(tester);
    expect(find.text('In my car'), findsOneWidget);
    expect(find.text('In the ute'), findsNothing);
    Future<void> io() async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.text('My car'));
    await io();
    await tester.tap(find.text('All vehicles').last);
    await io();
    await settle(tester);
    expect(settings.viewAll.value, isTrue);
    expect(find.text('In my car'), findsOneWidget);
    expect(find.text('In the ute'), findsOneWidget);
    expect(find.textContaining('Work ute · '), findsOneWidget);
    expect(find.textContaining('all vehicles'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
