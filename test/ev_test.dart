import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/energy.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/charge_form.dart';
import 'package:mileagelog/ui/history_page.dart';
import 'package:mileagelog/ui/insights_page.dart';
import 'package:mileagelog/ui/vehicle_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle(WidgetTester tester, [int n = 5]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<void> closeDb(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(() => db.close());
}

EnergyEventsCompanion ev(String id, String vid, String kind, DateTime at, double odo, double qty, double cost, {String? place}) =>
    EnergyEventsCompanion.insert(
      id: id,
      vehicleId: vid,
      kind: Value(kind),
      at: at,
      odometerKm: odo,
      quantity: qty,
      cost: cost,
      isFull: const Value(true),
      chargerType: Value(place),
    );

void main() {
  test('charge kWh from the meter or the battery %', () {
    expect(chargeKwh(meterKwh: 32.5), 32.5);
    expect(chargeKwh(meterKwh: null, pctStart: 20, pctEnd: 80, batteryKwh: 60), closeTo(36, 1e-9));
    expect(chargeKwh(meterKwh: null, pctStart: 20, pctEnd: 80), 0); // battery size unknown
    expect(chargeKwh(meterKwh: null, pctStart: 80, pctEnd: 20, batteryKwh: 60), 0);
    expect(Energy.primaryFor('ev').per100, 'kWh/100 km');
    expect(Energy.primaryFor('phev').per100, 'L/100 km');
    expect(usesFuel('phev') && usesCharging('phev'), isTrue);
    expect(usesFuel('ev'), isFalse);
    expect(Energy.charge.price(0.3), r'$0.30/kWh');
  });

  test('fill-ups and charges are kept apart for economy', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final v = await repo.addVehicle('Plug-in', 'phev');
    expect(v.kind, 'phev');
    final d = DateTime(2026, 10, 1);
    await repo.upsertEvent(ev('f1', v.id, 'fuel', d, 1000, 30, 80), enqueue: false);
    await repo.upsertEvent(ev('c1', v.id, 'charge', d.add(const Duration(days: 1)), 1050, 10, 3, place: 'home'), enqueue: false);
    await repo.upsertEvent(ev('f2', v.id, 'fuel', d.add(const Duration(days: 5)), 1500, 25, 70), enqueue: false);
    final events = await repo.watchEvents(v.id, kind: null).first;
    expect(Repository.toFuelRows(events).length, 2);
    expect(Repository.toFuelRows(events, kind: 'charge').length, 1);
    expect(Repository.toFuelRows(events, kind: null).length, 3);
    expect((await repo.latestEvent(v.id, kind: 'charge'))!.id, 'c1');
    expect((await repo.vehicles()).length, 1);
    await db.close();
  });

  testWidgets('home charge is costed from the power rate and saved', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.addVehicle('Leaf', 'ev');
    await settings.setActiveVehicleId(v.id);
    await settings.setHomeRateCents(25);
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: ChargeForm())));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Odometer (km)'), '20500');
    await tester.enterText(find.widgetWithText(TextFormField, 'kWh'), '40');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '10.00'), findsOneWidget); // 40 kWh at 25c
    await tester.tap(find.text('Save charge'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    final saved = await tester.runAsync(() => repo.latestEvent(v.id, kind: 'charge'));
    expect(saved!.quantity, 40);
    expect(saved.cost, 10);
    expect(saved.chargerType, 'home');
    expect(tester.takeException(), isNull);
    await closeDb(tester, db);
  });

  testWidgets('history and insights show charges for an EV', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.addVehicle('Leaf', 'ev');
    await settings.setActiveVehicleId(v.id);
    final now = DateTime.now();
    for (var i = 0; i < 12; i++) {
      await repo.upsertEvent(
        ev('c$i', v.id, 'charge', DateTime(now.year, now.month, now.day - 200 + i * 15), 20000 + i * 250.0, 40, i.isEven ? 10 : 24,
            place: i.isEven ? 'home' : 'dc'),
        enqueue: false,
      );
    }
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: HistoryPage())));
    await settle(tester);
    expect(find.textContaining('kWh'), findsWidgets);
    expect(find.textContaining('Fast DC'), findsWidgets);
    expect(find.byIcon(Icons.ev_station), findsWidgets);

    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: InsightsPage())));
    await settle(tester);
    expect(find.textContaining(RegExp('charging spend', caseSensitive: false)), findsOneWidget);
    expect(find.textContaining(RegExp('kwh/100 km', caseSensitive: false)), findsWidgets);
    expect(find.text('Fuel'), findsNothing); // no fuel/charging switch for a pure EV
    expect(find.text('WHERE YOU CHARGE'), findsOneWidget);
    expect(find.textContaining('Fast DC 50%'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeDb(tester, db);
  });

  testWidgets('a second vehicle can be added and becomes the current one', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: VehiclePage())));
    await settle(tester);
    expect(find.text('Add another vehicle'), findsOneWidget);
    await tester.tap(find.text('Add another vehicle'));
    await settle(tester);
    expect(find.text('Add a vehicle'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Leaf');
    await tester.tap(find.text('Electric'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    final all = (await tester.runAsync(() => repo.vehicles()))!;
    expect(all.length, 2);
    final leaf = all.firstWhere((x) => x.name == 'Leaf');
    expect(leaf.kind, 'ev');
    expect(settings.activeVehicleId, leaf.id);
    await closeDb(tester, db);
  });
}
