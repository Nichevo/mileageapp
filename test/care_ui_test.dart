import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/backup/backup.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/care_page.dart';
import 'package:mileagelog/ui/insurance_page.dart';
import 'package:mileagelog/ui/service_page.dart';
import 'package:mileagelog/ui/tyres_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<void> closeDb(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(() => db.close());
}

Future<(AppDatabase, Repository, Settings, String)> seed() async {
  SharedPreferences.setMockInitialValues({});
  final db = AppDatabase(NativeDatabase.memory());
  final repo = Repository(db);
  final settings = await Settings.load();
  final v = await repo.ensureVehicle();
  await settings.setActiveVehicleId(v.id);
  final now = DateTime.now();
  for (var i = 0; i < 6; i++) {
    await repo.upsertEvent(
      EnergyEventsCompanion.insert(id: 'f$i', vehicleId: v.id, at: now.subtract(Duration(days: 100 - i * 18)), odometerKm: 140000 + i * 700.0, quantity: 40, cost: 120),
      enqueue: false,
    );
  }
  // An old WOF record, as the Road Trip import would create.
  await repo.upsertExpense(ExpensesCompanion.insert(id: 'x1', vehicleId: v.id, at: DateTime(now.year - 1, now.month, now.day + 10), kind: 'wof', description: 'WOF', cost: 60));
  return (db, repo, settings, v.id);
}

Widget host(Repository repo, Settings settings, Widget child) =>
    AppScope(repo: repo, settings: settings, child: MaterialApp(home: child));

void main() {
  testWidgets('recommended schedule is added and seeded from history', (tester) async {
    final (db, repo, settings, vid) = await seed();
    await tester.pumpWidget(host(repo, settings, const ServicePage()));
    await settle(tester);
    await tester.tap(find.text('Add recommended schedule'));
    await settle(tester);
    expect(find.text('Warrant of Fitness'), findsOneWidget);
    await tester.tap(find.textContaining(RegExp(r'^Add \d+ items$')));
    await settle(tester);
    final items = await db.select(db.serviceItems).get();
    expect(items.length, 12); // all but timing belt
    final wof = items.firstWhere((i) => i.kind == 'wof');
    expect(wof.lastDoneAt, isNotNull);
    expect(find.text('Warrant of Fitness'), findsOneWidget);
    expect(find.textContaining('in 10 days'), findsWidgets); // WOF due soon

    // Logging a WOF moves it forward.
    await repo.logService(vehicleId: vid, at: DateTime.now(), odometerKm: 143600, kind: 'wof', description: 'WOF', cost: 65, itemIds: [wof.id]);
    final after = (await db.select(db.serviceItems).get()).firstWhere((i) => i.id == wof.id);
    expect(after.lastDoneKm, 143600);
    await closeDb(tester, db);
  });

  testWidgets('coming up card shows due items and insurance renewal', (tester) async {
    final (db, repo, settings, vid) = await seed();
    final now = DateTime.now();
    await repo.upsertServiceItem(ServiceItemsCompanion.insert(id: 's1', vehicleId: vid, name: 'Oil and filter change', intervalKm: const Value(10000), lastDoneKm: const Value(133000)));
    await repo.upsertPolicy(InsurancePoliciesCompanion.insert(id: 'p1', vehicleId: vid, insurer: 'Test Insurer', startAt: DateTime(now.year - 1, now.month, now.day + 20), renewAt: Value(DateTime(now.year, now.month, now.day + 20)), insuredValue: const Value(12000)));
    await tester.pumpWidget(host(repo, settings, const Scaffold(body: ComingUpCard())));
    await settle(tester);
    expect(find.text('Oil and filter change'), findsOneWidget);
    expect(find.textContaining('km over'), findsOneWidget);
    expect(find.text('Insurance renewal'), findsOneWidget);
    await closeDb(tester, db);
  });

  testWidgets('insurance and tyre pages render and save', (tester) async {
    final (db, repo, settings, vid) = await seed();
    await tester.pumpWidget(host(repo, settings, const InsurancePage()));
    await settle(tester);
    await tester.tap(find.text('Add policy'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Insurer'), 'Test Insurer');
    await tester.enterText(find.widgetWithText(TextField, 'Insured value \$'), '15000');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect((await db.select(db.insurancePolicies).get()).single.insuredValue, 15000);
    expect(find.text('Test Insurer'), findsOneWidget);

    await tester.pumpWidget(host(repo, settings, const TyresPage()));
    await settle(tester);
    await tester.tap(find.text('Check tyres'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Found psi').first, '28');
    await tester.tap(find.text('Same for all'));
    await tester.tap(find.text('Added air'));
    await settle(tester);
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    final check = (await db.select(db.tyreChecks).get()).single;
    expect(check.foundRrKpa, closeTo(193, 1)); // 28 psi
    expect(check.airAdded, isTrue);
    expect(find.textContaining('found → left'), findsOneWidget);

    await tester.pumpWidget(host(repo, settings, const CarCarePage()));
    await settle(tester);
    expect(find.text('Service schedule'), findsOneWidget);
    await closeDb(tester, db);
  });

  test('backup round trip keeps every trip point and the new tables', () async {
    SharedPreferences.setMockInitialValues({});
    final a = AppDatabase(NativeDatabase.memory());
    final repo = Repository(a);
    final v = await repo.ensureVehicle();
    await repo.saveRecordedTrip(
      TripsCompanion.insert(id: 't1', vehicleId: v.id, name: 'Test', startAt: DateTime(2026, 1, 1)),
      [for (var i = 0; i < 5; i++) TripPointsCompanion.insert(tripId: 't1', at: DateTime(2026, 1, 1, 9, 0, i), lat: -40, lon: 175 + i / 1000)],
      const [],
    );
    await repo.upsertServiceItem(ServiceItemsCompanion.insert(id: 's1', vehicleId: v.id, name: 'Oil'));
    await repo.upsertPolicy(InsurancePoliciesCompanion.insert(id: 'p1', vehicleId: v.id, insurer: 'X', startAt: DateTime(2026, 1, 1)));
    final json = await exportBackupJson(a);
    await a.close();

    final b = AppDatabase(NativeDatabase.memory());
    await restoreBackupJson(b, json);
    expect((await Repository(b).tripPoints('t1')).length, 5);
    expect((await b.select(b.serviceItems).get()).length, 1);
    expect((await b.select(b.insurancePolicies).get()).length, 1);
    await b.close();
  });
}
