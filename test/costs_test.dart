import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/ownership_cost.dart';
import 'package:mileagelog/domain/stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/costs_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('value curve: straight between known values, rule of thumb after, none after a sale', () {
    final c = ValueCurve([ValuePoint(DateTime(2020, 1, 1), 20000, 'purchase'), ValuePoint(DateTime(2022, 1, 1), 16000, 'estimate')]);
    expect(c.valueAt(DateTime(2019, 6, 1)), isNull);
    expect(c.valueAt(DateTime(2021, 1, 1)), closeTo(18000, 30));
    // Fitted rate from 20k to 16k over two years, about 10.6% a year.
    expect(c.rate, closeTo(0.106, 0.002));
    expect(c.valueAt(DateTime(2023, 1, 1)), closeTo(16000 * (1 - c.rate), 50));
    expect(c.estimatedAt(DateTime(2023, 1, 1)), isTrue);
    expect(c.lostBetween(DateTime(2019, 1, 1), DateTime(2022, 1, 1)), closeTo(4000, 1));

    final one = ValueCurve([ValuePoint(DateTime(2020, 1, 1), 10000, 'purchase')]);
    expect(one.rate, defaultDepreciationRate);
    expect(one.valueAt(DateTime(2021, 1, 1)), closeTo(8500, 10));

    final sold = ValueCurve([ValuePoint(DateTime(2020, 1, 1), 10000, 'purchase'), ValuePoint(DateTime(2021, 1, 1), 7000, 'sold')]);
    expect(sold.valueAt(DateTime(2024, 1, 1)), 7000);
    expect(sold.lostBetween(DateTime(2020, 1, 1), DateTime(2025, 1, 1)), closeTo(3000, 1));
  });

  test('cost periods by category, with depreciation and km, and the trend', () {
    final items = [
      CostItem(DateTime(2024, 3, 1), CostCategory.fuel, 100),
      CostItem(DateTime(2024, 9, 1), CostCategory.insurance, 600),
      CostItem(DateTime(2025, 3, 1), CostCategory.fuel, 150),
      CostItem(DateTime(2025, 9, 1), CostCategory.insurance, 700),
      CostItem(DateTime(2025, 10, 1), CostCategory.servicing, 400),
    ];
    final curve = ValueCurve([ValuePoint(DateTime(2024, 1, 1), 12000, 'purchase'), ValuePoint(DateTime(2025, 1, 1), 10000, 'estimate')]);
    final odo = [
      FuelRow(at: DateTime(2024, 1, 1), odometerKm: 50000, quantity: 0, cost: 0),
      FuelRow(at: DateTime(2025, 1, 1), odometerKm: 60000, quantity: 0, cost: 0),
    ];
    final now = DateTime(2025, 12, 31);
    final ys = costPeriods(items, curve, periodTotals(odo, Period.year), Period.year, now: now);
    expect(ys.map((p) => p.start.year), [2024, 2025]);
    expect(ys[0].cost[CostCategory.fuel], 100);
    expect(ys[0].cost[CostCategory.depreciation], closeTo(2000, 10));
    expect(ys[0].km, closeTo(10000, 30));
    expect(ys[0].perKm, closeTo(2700 / 10000, 0.01));
    expect(ys[1].running, 1250);
    expect(ys[1].cost[CostCategory.depreciation], greaterThan(1000)); // rule of thumb after the last value

    final ms = costPeriods(items, curve, periodTotals(odo, Period.month), Period.month, now: now);
    final tr = costTrend(ms, now);
    expect(tr.recent[CostCategory.insurance], 700);
    expect(tr.before[CostCategory.insurance], 600);
    expect(tr.recent[CostCategory.servicing], 400);
    expect(tr.change, greaterThan(0));
    expect(categoryForExpense('wof'), CostCategory.servicing);
    expect(categoryForExpense('parking'), CostCategory.tollsParking);
    expect(slope([1, 2, 3, 4]), closeTo(1, 1e-9));
    expect(slope([1, 2]), isNull);
    final merged = mergeCostPeriods([ys, ys]);
    expect(merged[0].cost[CostCategory.fuel], 200);
  });

  Future<void> io(WidgetTester tester, [int n = 10]) async {
    for (var i = 0; i < n; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('running costs page: totals, trend, values and every vehicle', (tester) async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final car = (await tester.runAsync(() => repo.ensureVehicle()))!;
    final ute = (await tester.runAsync(() => repo.addVehicle('Work ute', 'diesel')))!;
    await settings.setActiveVehicleId(car.id);
    final now = DateTime.now();
    await tester.runAsync(() async {
      for (var i = 0; i < 30; i++) {
        await repo.upsertEvent(
            EnergyEventsCompanion.insert(id: 'f$i', vehicleId: car.id, at: DateTime(now.year - 2, now.month, 1 + i * 25), odometerKm: 100000 + i * 600.0, quantity: 40, cost: 100 + i * 2.0),
            enqueue: false);
      }
      await repo.upsertExpense(ExpensesCompanion.insert(id: 'x1', vehicleId: car.id, at: DateTime(now.year - 1, now.month - 2, 1), kind: 'insurance', description: 'Insurance', cost: 600));
      await repo.upsertExpense(ExpensesCompanion.insert(id: 'x2', vehicleId: car.id, at: DateTime(now.year, now.month - 1, 1), kind: 'insurance', description: 'Insurance', cost: 720));
      await repo.upsertExpense(ExpensesCompanion.insert(id: 'x3', vehicleId: ute.id, at: DateTime(now.year, now.month - 1, 1), kind: 'rego', description: 'Rego', cost: 300));
      await (db.update(db.vehicles)..where((v) => v.id.equals(car.id))).write(VehiclesCompanion(purchaseDate: Value(DateTime(now.year - 3, 1, 1))));
      await repo.upsertPolicy(InsurancePoliciesCompanion.insert(id: 'p', vehicleId: car.id, insurer: 'Test Insurer', startAt: DateTime(now.year - 1, 1, 1), insuredValue: const Value(9000)));
    });
    tester.view.physicalSize = const Size(380, 7000); // phone width
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: CostsPage())));
    await io(tester);
    expect(find.text('IS IT GOING UP?'), findsOneWidget);
    expect(find.textContaining('COST PER YEAR BY TYPE'), findsOneWidget);
    expect(find.text('Insured value \$9,000'), findsOneWidget);

    await tester.tap(find.text('What you paid'));
    await io(tester, 3);
    await tester.enterText(find.widgetWithText(TextField, 'Value \$'), '15000');
    await tester.tap(find.text('Save'));
    await io(tester);
    expect(find.text('Bought for \$15,000'), findsOneWidget);
    expect(find.textContaining('Lost '), findsOneWidget);
    expect(find.textContaining('depreciation'), findsWidgets);

    await tester.tap(find.text('Monthly'));
    await io(tester, 3);
    expect(find.textContaining('COST PER MONTH BY TYPE'), findsOneWidget);

    settings.viewAll.value = true;
    await io(tester);
    expect(find.text('EACH VEHICLE'), findsOneWidget);
    expect(find.text('Work ute'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
