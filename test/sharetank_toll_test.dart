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
import 'package:mileagelog/domain/reminders.dart';
import 'package:mileagelog/domain/road_match.dart';
import 'package:mileagelog/domain/sharetank.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/fillup_form.dart';
import 'package:mileagelog/ui/trip_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive, lat0, way;

Future<void> settle(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  test('Sharetank litres are used oldest first', () {
    final l = ShareLedger.run(
      [ShareLot(DateTime(2026, 1, 1), 50, 120), ShareLot(DateTime(2026, 2, 1), 30, 78)], // $2.40 and $2.60
      [ShareDraw('a', DateTime(2026, 1, 10), 40), ShareDraw('b', DateTime(2026, 2, 10), 20)],
    );
    expect(l.drawCost['a'], closeTo(96, 1e-9));
    expect(l.drawCost['b'], closeTo(10 * 2.4 + 10 * 2.6, 1e-9));
    expect(l.balance, closeTo(20, 1e-9));
    expect(l.averagePrice, closeTo(2.6, 1e-9));
    final next = l.costOf(25);
    expect(next.cost, closeTo(52, 1e-9));
    expect(next.short, closeTo(5, 1e-9));

    // A fill before any purchase isn't covered.
    final early = ShareLedger.run([ShareLot(DateTime(2026, 3, 1), 50, 120)], [ShareDraw('x', DateTime(2026, 2, 1), 10)]);
    expect(early.uncovered, 10);
    expect(early.balance, 50);
    expect(sharetankFillCost(litres: 45, shareLitres: 40, shareCost: 96, pumpPrice: 2.8), closeTo(110, 1e-9));
  });

  test('fill-ups are costed again when a purchase is added later', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final v = await repo.ensureVehicle();
    await repo.upsertEvent(
      EnergyEventsCompanion.insert(
        id: 'f1',
        vehicleId: v.id,
        at: DateTime(2026, 5, 1),
        odometerKm: 1000,
        quantity: 40,
        cost: 0,
        fuelType: const Value('91'),
        paymentNote: const Value('Sharetank'),
        sharetankLitres: const Value(40),
        listCost: const Value(112),
      ),
      enqueue: false,
    );
    await repo.upsertFuelCredit(FuelCreditsCompanion.insert(id: 'c1', at: DateTime(2026, 4, 1), fuelType: const Value('91'), litres: 100, cost: 240));
    expect(await repo.recostSharetank(), 1);
    final f = (await repo.events(v.id)).single;
    expect(f.cost, 96);
    final l = await repo.sharetankLedger(fuelType: '91');
    expect(l.balance, closeTo(60, 1e-9));
    await db.close();
  });

  testWidgets('a Sharetank fill-up is costed at the locked price', (tester) async {
    SharedPreferences.setMockInitialValues({'useGps': false});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    await settings.setLastFuelType('91');
    await repo.upsertFuelCredit(FuelCreditsCompanion.insert(id: 'c1', at: DateTime(2026, 1, 1), fuelType: const Value('91'), litres: 50, cost: 120));
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: FillUpForm())));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Odometer (km)'), '12000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Litres'), '40');
    await tester.pump();
    await tester.tap(find.text('Sharetank'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, r'Pump price $/L'), '2.80');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '96.00'), findsOneWidget);
    expect(find.textContaining(r'Saved $16.00'), findsOneWidget);
    await tester.tap(find.text('Save fill-up'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    final saved = (await tester.runAsync(() => repo.events(v.id)))!.single;
    expect(saved.cost, 96);
    expect(saved.sharetankLitres, 40);
    expect(saved.listCost, closeTo(112, 1e-9));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });

  test('toll roads on the route are found', () {
    final samples = drive(174.700, 174.730);
    final toll = way(20, 'motorway', [
      [lat0, 174.71],
      [lat0, 174.725],
    ]);
    (toll['tags'] as Map)['toll'] = 'yes';
    (toll['tags'] as Map)['name'] = 'Test Toll Road';
    final osm = OsmArea.fromOverpass({
      'elements': [
        way(10, 'primary', [
          [lat0, 174.69],
          [lat0, 174.71],
        ]),
        toll,
        way(11, 'primary', [
          [lat0, 174.725],
          [lat0, 174.74],
        ]),
      ],
    });
    final r = matchRoads(samples, osm);
    expect(r.tolls.single.name, 'Test Toll Road');
    expect(r.tolls.single.km, closeTo(1.25, 0.1));
    final back = RoadStats.fromJson(jsonDecode(jsonEncode(r.toJson())) as Map<String, Object?>);
    expect(back.tolls.single.name, 'Test Toll Road');
  });

  test('toll reminders after the trip and before the deadline', () {
    final trip = DateTime(2026, 11, 7, 14); // Saturday
    expect(tollPayBy(trip), DateTime(2026, 11, 12));
    final r = planTollReminders([(tripId: 't', road: 'Northern Gateway', at: trip)], now: DateTime(2026, 11, 7, 16));
    expect(r.map((x) => x.at), [DateTime(2026, 11, 8, 9), DateTime(2026, 11, 11, 9)]);
    expect(r.first.body, contains('Pay by Thu 12/11'));
    expect(planTollReminders([(tripId: 't', road: 'X', at: trip)], now: DateTime(2026, 11, 14)), isEmpty);
    final late = planTollReminders([(tripId: 't', road: 'X', at: trip)], now: DateTime(2026, 11, 12, 10));
    expect(late.single.title, 'Toll due today');
  });

  testWidgets('trip page asks to pay a toll and logs it', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false});
    // The map's tile cache asks for a folder.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final samples = drive(174.700, 174.730);
    final json = computeTripStats(samples).toJson()
      ..['road'] = const RoadStats(roadKm: {RoadClass.motorway: 2.5}, lights: [], waitAtLights: Duration.zero, tolls: [TollUse('Test Toll Road', 1.5)]).toJson();
    await repo.saveRecordedTrip(
      TripsCompanion.insert(id: 't1', vehicleId: v.id, name: 'Up north', startAt: samples.first.at, status: const Value('done'), statsJson: Value(jsonEncode(json))),
      [for (final s in samples) TripPointsCompanion.insert(tripId: 't1', at: s.at, lat: s.lat, lon: s.lon, speedMps: Value(s.speedMps), accuracyM: Value(s.accuracyM))],
      const [],
    );
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripDetailPage(tripId: 't1'))));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Log toll paid'), 200);
    expect(find.text('Toll road: Test Toll Road'), findsOneWidget);
    expect(find.textContaining('Pay by'), findsOneWidget);
    await tester.tap(find.text('Log toll paid'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, r'Cost $'), '2.90');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    expect(find.text('Toll logged for this trip.'), findsOneWidget);
    final x = (await tester.runAsync(() => repo.expenses(v.id)))!.single;
    expect(x.kind, 'toll');
    expect(x.tripId, 't1');
    expect(x.cost, 2.9);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
