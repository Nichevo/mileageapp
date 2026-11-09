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
import 'package:mileagelog/domain/trip_filter.dart';
import 'package:mileagelog/domain/trip_profile.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/trip_detail_page.dart';
import 'package:mileagelog/ui/trips_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive;

Future<void> settle(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Moves a drive so it starts at [start].
List<GpsSample> shifted(List<GpsSample> s, DateTime start) {
  final d = start.difference(s.first.at);
  return [for (final p in s) GpsSample(p.at.add(d), p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM, altitudeM: p.altitudeM)];
}

Future<void> saveTrip(Repository repo, String vid, String id, String name, List<GpsSample> s) => repo.saveRecordedTrip(
      TripsCompanion.insert(
        id: id,
        vehicleId: vid,
        name: name,
        startAt: s.first.at,
        endAt: Value(s.last.at),
        status: const Value('done'),
        gpsDistanceKm: Value(computeTripStats(s).distanceKm),
        statsJson: Value(jsonEncode({
          ...computeTripStats(s).toJson(),
          'battery': {'start': 90, 'end': 88, 'charging': false},
        })),
      ),
      [for (final p in s) TripPointsCompanion.insert(tripId: id, at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM))],
      const [],
    );

void main() {
  final now = DateTime(2026, 11, 9, 12);
  final rows = [
    TripRow(id: 'a', start: DateTime(2026, 11, 8, 8), end: DateTime(2026, 11, 8, 8, 20), km: 12, duration: const Duration(minutes: 20), avgKmh: 40, to: (lat: -41.2, lon: 174.7)),
    TripRow(id: 'b', start: DateTime(2026, 11, 8, 8, 35), end: DateTime(2026, 11, 8, 9), km: 3, duration: const Duration(minutes: 25), avgKmh: 20, from: (lat: -41.2005, lon: 174.7005)),
    TripRow(id: 'c', start: DateTime(2026, 6, 1, 9), end: DateTime(2026, 6, 1, 12), km: 230, duration: const Duration(hours: 3), avgKmh: 85),
    TripRow(id: 'd', start: DateTime(2025, 12, 1, 9), km: null),
  ];

  test('trips sort and filter by time and size', () {
    expect(filterTrips(rows, now: now).map((r) => r.id), ['b', 'a', 'c', 'd']);
    expect(filterTrips(rows, sort: TripSort.oldest, now: now).first.id, 'd');
    expect(filterTrips(rows, sort: TripSort.longest, now: now).map((r) => r.id), ['c', 'a', 'b', 'd']);
    expect(filterTrips(rows, sort: TripSort.longestTime, now: now).first.id, 'c');
    expect(filterTrips(rows, sort: TripSort.fastest, now: now).first.id, 'c');
    expect(filterTrips(rows, period: TripPeriod.week, now: now).map((r) => r.id), ['b', 'a']);
    expect(filterTrips(rows, period: TripPeriod.year, now: now).length, 3);
    expect(filterTrips(rows, size: TripSize.short, now: now).map((r) => r.id), ['b']);
    expect(filterTrips(rows, size: TripSize.medium, now: now).map((r) => r.id), ['a']);
    expect(filterTrips(rows, size: TripSize.long, now: now).map((r) => r.id), ['c']);
  });

  test('a trip that carries on from the last one is suggested for merging', () {
    expect(mergeSuggestions(rows), [('a', 'b')]);
    final far = [rows[0], TripRow(id: 'b', start: rows[1].start, end: rows[1].end, from: (lat: -41.3, lon: 174.7))];
    expect(mergeSuggestions(far), isEmpty);
    expect(mergeSuggestions(rows, gap: const Duration(minutes: 10)), isEmpty);
  });

  test('speed colours and the trip profile', () {
    expect([5.0, 20.0, 40.0, 60.0, 100.0].map(speedBand), [0, 1, 2, 3, 4]);
    final s = drive(174.70, 174.73);
    final p = tripProfile(s, maxPoints: 20);
    expect(p.length, inInclusiveRange(15, 20));
    expect(p.last.km, closeTo(computeTripStats(s).distanceKm, 0.1));
    expect(p.every((x) => (x.kmh! - 50).abs() < 1), isTrue);
    final derived = pointSpeedsKmh([for (final x in s) GpsSample(x.at, x.lat, x.lon)]);
    expect(derived[5], closeTo(50, 2));
  });

  test('merging joins points, keeps the first trip and moves tolls', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final v = await repo.ensureVehicle();
    final first = shifted(drive(174.70, 174.71), DateTime(2026, 11, 8, 8));
    final second = shifted(drive(174.71, 174.72), first.last.at.add(const Duration(minutes: 10)));
    await saveTrip(repo, v.id, 't1', 'To the shops', first);
    await saveTrip(repo, v.id, 't2', 'Trip 2', second);
    await repo.upsertExpense(ExpensesCompanion.insert(id: 'x', vehicleId: v.id, at: second.first.at, kind: 'parking', description: 'Parking', cost: 4, tripId: const Value('t2')));
    final ends = await repo.tripEnds('t2');
    expect(ends!.from.lon, closeTo(174.71, 0.001));

    expect(await repo.mergeTrips(['t2', 't1']), 't1');
    final trips = await db.select(db.trips).get();
    expect(trips.single.name, 'To the shops');
    expect(trips.single.endAt, second.last.at);
    expect((await repo.tripPoints('t1')).length, first.length + second.length);
    final stats = TripStats.fromJson(jsonDecode(trips.single.statsJson!) as Map<String, Object?>);
    expect(stats.distanceKm, closeTo(computeTripStats([...first, ...second]).distanceKm, 0.01));
    expect((jsonDecode(trips.single.statsJson!) as Map)['longStops'], 1); // the 10 minutes between them
    expect(stats.stopped, greaterThanOrEqualTo(const Duration(minutes: 10)));
    expect((await repo.tripStops('t1')).length, 1);
    expect((await repo.expenses(v.id)).single.tripId, 't1');
    await db.close();
  });

  testWidgets('trips list sorts, filters and merges selected trips', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final today = DateTime.now();
    final short = shifted(drive(174.70, 174.71), DateTime(today.year, today.month, today.day - 1, 8));
    final long = shifted(drive(174.70, 174.80), DateTime(today.year, today.month, today.day - 3, 8));
    await saveTrip(repo, v.id, 's', 'Short hop', short);
    await saveTrip(repo, v.id, 'l', 'Long run', long);
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripsPage())));
    await settle(tester);
    double y(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(y('Short hop') < y('Long run'), isTrue); // newest first

    await tester.tap(find.text('Newest'));
    await settle(tester);
    await tester.tap(find.text('Longest distance').last);
    await settle(tester);
    expect(y('Long run') < y('Short hop'), isTrue);

    await tester.tap(find.text('Any length'));
    await settle(tester);
    await tester.tap(find.text('Under 5 km').last);
    await settle(tester);
    expect(find.text('Long run'), findsNothing);
    expect(find.text('Short hop'), findsOneWidget);
    await tester.tap(find.text('Under 5 km'));
    await settle(tester);
    await tester.tap(find.text('Any length').last);
    await settle(tester);

    await tester.longPress(find.text('Short hop'));
    await settle(tester);
    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.text('Long run'));
    await settle(tester);
    await tester.tap(find.text('Merge'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Merge'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await settle(tester);
    final left = (await tester.runAsync(() => db.select(db.trips).get()))!;
    expect(left.single.name, 'Long run');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });

  testWidgets('trip page shows speed and elevation charts and a speed legend', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final s = [
      for (final (i, p) in drive(174.70, 174.73).indexed) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM, altitudeM: 20.0 + i * 0.5),
    ];
    await repo.saveRecordedTrip(
      TripsCompanion.insert(id: 't', vehicleId: v.id, name: 'Hill', startAt: s.first.at, endAt: Value(s.last.at), status: const Value('done'), statsJson: Value(jsonEncode(computeTripStats(s).toJson()))),
      [for (final p in s) TripPointsCompanion.insert(tripId: 't', at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM), altitudeM: Value(p.altitudeM))],
      const [],
    );
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripDetailPage(tripId: 't'))));
    await settle(tester);
    expect(find.text('Speed · km/h'), findsOneWidget);
    expect(find.text('Elevation · m (phone GPS)'), findsOneWidget);
    expect(find.text(' 50–80  '), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
