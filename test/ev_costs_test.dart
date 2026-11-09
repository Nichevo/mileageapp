import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/ev_costs.dart';
import 'package:mileagelog/domain/stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/ev_compare_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('last year of driving from fill-ups', () {
    final now = DateTime(2026, 11, 9);
    final rows = [
      for (var i = 0; i <= 26; i++)
        FuelRow(at: now.subtract(Duration(days: 390 - i * 15)), odometerKm: 10000 + i * 500.0, quantity: 40, cost: 100),
    ];
    final d = recentDriving(rows, now: now)!;
    expect(d.days, 365);
    // The last reading before the window is fill 1 (375 days ago); the latest is fill 26.
    expect(d.km, 25 * 500);
    expect(d.cost, 25 * 100);
    expect(recentDriving(rows.take(1).toList(), now: now), isNull);
  });

  test('EV estimate, charging split and RUC due date', () {
    final e = evEstimate(km: 10000, kwhPer100: 17, homeShare: 0.8, homePerKwh: 0.30, publicPerKwh: 0.80);
    // 1,700 kWh: 1,360 at 30c plus 340 at 80c.
    expect(e.energyCost, closeTo(408 + 272, 1e-9));
    expect(e.ruc, closeTo(760, 1e-9));
    expect(e.total, closeTo(1440, 1e-9));

    final split = chargeSplit([
      (place: 'home', kwh: 30, cost: 9),
      (place: 'dc', kwh: 20, cost: 16),
      (place: null, kwh: 10, cost: 3),
    ]);
    expect(split.map((s) => s.place), ['home', 'dc']);
    expect(split.first.kwh, 40);
    expect(split.first.pricePerKwh, closeTo(0.3, 1e-9));
    expect(split.last.pricePerKwh, closeTo(0.8, 1e-9));

    final due = rucDueOn(rucUntilKm: 21000, currentKm: 20000, kmPerDay: 40, now: DateTime(2026, 11, 9));
    expect(due, DateTime(2026, 12, 4));
    expect(paysRuc('ev') && paysRuc('diesel') && !paysRuc('petrol'), isTrue);
  });

  testWidgets('EV comparison page uses your driving', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final now = DateTime.now();
    for (var i = 0; i <= 26; i++) {
      await repo.upsertEvent(
        EnergyEventsCompanion.insert(
          id: 'f$i',
          vehicleId: v.id,
          at: now.subtract(Duration(days: 390 - i * 15)),
          odometerKm: 10000 + i * 500.0,
          quantity: 40,
          cost: 100,
          isFull: const Value(true),
        ),
        enqueue: false,
      );
    }
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: EvComparePage())));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.textContaining('12,500 km a year'), findsOneWidget);
    expect(find.textContaining('An EV would save about'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '10000');
    await tester.pump();
    expect(find.textContaining('Pays back in about'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
