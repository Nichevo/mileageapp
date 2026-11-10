import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/loan.dart';
import 'package:mileagelog/platform/home_sync.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/loan_car_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loan details round trip, and the hand-back summary', () {
    final l = LoanDetails(
      kind: 'rental',
      collectedAt: DateTime(2026, 11, 1, 9),
      from: 'Test Rentals',
      plate: 'ZZ1234',
      collectedKm: 20000,
      collectedFuel: 8,
      bookingRef: 'B-77',
      dueBackAt: DateTime(2026, 11, 4, 17),
      totalCost: 240,
      kmAllowance: 300,
      fuelPolicy: 'full_to_full',
    );
    final back = LoanDetails.decode(l.encode())!;
    expect(back.isRental, isTrue);
    expect(back.bookingRef, 'B-77');
    expect(back.dueBackAt, DateTime(2026, 11, 4, 17));
    expect(back.returned, isFalse);
    final r = back.handBack(at: DateTime(2026, 11, 4, 16), km: 20412, fuel: 6);
    expect(r.returned, isTrue);
    expect(r.odoKm, 412);
    expect(r.fuelDiff, -2);
    final s = summariseLoan(r, trips: 5, tripKm: 405, fuelLitres: 30, fuelCost: 81);
    final lines = s.lines(r, (v) => '\$${v.toStringAsFixed(2)}');
    expect(lines.first, '412 km, 5 trips recorded');
    expect(lines, contains('Returned with 2/8 tank less than collected'));
    expect(lines, contains('112 km over the 300 km allowance'));
    expect(lines, contains('Rental cost \$240.00'));
    expect(fuelLabel(4), '1/2');
  });

  test('a loan car stays out of Sheets, reminds you to return it, and archives on hand-back', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final own = await repo.ensureVehicle(name: 'My car');
    await repo.upsertPolicy(InsurancePoliciesCompanion.insert(
        id: 'p1', vehicleId: own.id, insurer: 'Test Insurer', startAt: DateTime(2025, 12, 1), renewAt: Value(DateTime(2026, 12, 1))));
    final loan = await repo.saveLoanCar(
      name: 'Rental Corolla',
      kind: 'petrol',
      make: 'Toyota',
      model: 'Corolla',
      loan: LoanDetails(kind: 'rental', collectedAt: DateTime(2026, 11, 8, 9), dueBackAt: DateTime(2026, 11, 12, 17), collectedKm: 1000, collectedFuel: 8),
    );
    await settings.setActiveVehicleId(loan.id);
    expect(loan.ownership, 'rental');
    await repo.upsertEvent(EnergyEventsCompanion.insert(id: 'e1', vehicleId: loan.id, at: DateTime(2026, 11, 10), odometerKm: 1200, quantity: 20, cost: 55));
    expect(await repo.pendingSync(), isEmpty); // not queued for Google Sheets
    await repo.upsertEvent(EnergyEventsCompanion.insert(id: 'e2', vehicleId: own.id, at: DateTime(2026, 11, 1), odometerKm: 5000, quantity: 30, cost: 80));
    expect((await repo.pendingSync()).length, 1);

    final now = DateTime(2026, 11, 9, 8);
    final r = await HomeSync.build(repo, settings, now: now);
    expect(r.reminders.any((x) => x.title == 'Return Rental Corolla'), isTrue);
    // Your own car's insurance still reminds you while driving the rental.
    final all = await HomeSync.allReminders(repo, settings, r.reminders, now: now);
    expect(all.any((x) => x.title == 'My car: Insurance renewal'), isTrue);

    final l = LoanDetails.decode((await repo.vehicle(loan.id))!.loanJson)!;
    final returned = l.handBack(at: DateTime(2026, 11, 12, 16), km: 1350, fuel: 8);
    final s = await repo.loanSummary(loan.id, returned);
    expect(s.km, 350);
    expect(s.fuelLitres, 20);
    await repo.handBack(loan.id, returned);
    expect((await repo.liveVehicles()).map((v) => v.id), [own.id]);
    expect(LoanDetails.decode((await repo.vehicle(loan.id))!.loanJson)!.returned, isTrue);
    final r2 = await HomeSync.build(repo, settings, now: now, vehicleId: own.id);
    expect(r2.reminders.any((x) => x.title.startsWith('Return')), isFalse);
    await db.close();
  });

  testWidgets('add a rental, then hand it back to switch to your own car', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final own = (await tester.runAsync(() => repo.ensureVehicle(name: 'My car')))!;
    await settings.setActiveVehicleId(own.id);
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> io() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.pumpWidget(AppScope(
      repo: repo,
      settings: settings,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoanCarPage())), child: const Text('add')),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('add'));
    await tester.pumpAndSettle();
    await io();
    await tester.tap(find.text('Rental'));
    await tester.pump();
    expect(find.text('Booking reference'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Make'), 'Toyota');
    await tester.enterText(find.widgetWithText(TextField, 'Model'), 'Corolla');
    await tester.enterText(find.widgetWithText(TextField, 'Odometer at pick-up (km)'), '1000');
    await tester.enterText(find.widgetWithText(TextField, 'Booking reference'), 'B-1');
    await tester.ensureVisible(find.text('Start using this car'));
    await tester.tap(find.text('Start using this car'));
    await io();
    await tester.pumpAndSettle();
    final rental = (await tester.runAsync(() => repo.liveVehicles()))!.firstWhere((v) => v.id != own.id);
    expect(rental.name, 'Rental Toyota Corolla');
    expect(rental.ownership, 'rental');
    expect(LoanDetails.decode(rental.loanJson)!.bookingRef, 'B-1');
    expect(settings.activeVehicleId, rental.id);

    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: MaterialApp(home: HandBackPage(vehicle: rental))));
    await tester.pumpAndSettle();
    expect(find.text('It was 1,000 km at pick-up'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Odometer now (km)'), '1180');
    await tester.tap(find.widgetWithText(FilledButton, 'Hand back'));
    await io();
    await tester.pumpAndSettle();
    expect(find.textContaining('180 km, 0 trips recorded'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Hand back').last);
    await io();
    expect(settings.activeVehicleId, own.id);
    expect((await tester.runAsync(() => repo.vehicle(rental.id)))!.archivedAt, isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
