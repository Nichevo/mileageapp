import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/expense_page.dart';
import 'package:mileagelog/ui/history_page.dart';
import 'package:mileagelog/ui/insights_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Expense x(String id, String kind, DateTime at, String desc, {String? where, String? notes}) =>
    Expense(id: id, vehicleId: 'v', at: at, kind: kind, description: desc, cost: 10, location: where, notes: notes, source: 'app');

void main() {
  test('expense filters: type, year, search and documents', () {
    final items = [
      x('a', 'service', DateTime(2025, 3, 1), 'Oil change', where: 'Test Motors'),
      x('b', 'wof', DateTime(2025, 9, 1), 'WOF'),
      x('c', 'service', DateTime(2026, 2, 1), 'Brake pads', notes: 'front only'),
      x('d', 'parking', DateTime(2026, 5, 1), 'Parking'),
    ];
    expect(filterExpenses(items, kind: 'service').map((e) => e.id), ['a', 'c']);
    expect(filterExpenses(items, year: 2026).map((e) => e.id), ['c', 'd']);
    expect(filterExpenses(items, kind: 'service', year: 2026).map((e) => e.id), ['c']);
    expect(filterExpenses(items, query: 'motors').map((e) => e.id), ['a']);
    expect(filterExpenses(items, query: 'FRONT').map((e) => e.id), ['c']);
    expect(filterExpenses(items, withDocs: {'b'}).map((e) => e.id), ['b']);
    expect(filterExpenses(items).length, 4);
  });

  test('period totals from several vehicles add up, gaps filled', () {
    PeriodTotals t(DateTime d, double km) => PeriodTotals(d)..km = km;
    final m = mergePeriodTotals([
      [t(DateTime(2026, 1), 100), t(DateTime(2026, 2), 50)],
      [t(DateTime(2026, 2), 30), t(DateTime(2026, 4), 10)],
    ], Period.month);
    expect(m.map((p) => p.start), [DateTime(2026, 1), DateTime(2026, 2), DateTime(2026, 3), DateTime(2026, 4)]);
    expect(m.map((p) => p.km), [100, 80, 0, 10]);
  });

  Future<void> io(WidgetTester tester, [int n = 10]) async {
    for (var i = 0; i < n; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('expenses: filter, open the detail, edit, add, and see every vehicle', (tester) async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final own = (await tester.runAsync(() => repo.ensureVehicle()))!;
    final ute = (await tester.runAsync(() => repo.addVehicle('Work ute', 'diesel')))!;
    await settings.setActiveVehicleId(own.id);
    await tester.runAsync(() async {
      await repo.upsertExpense(ExpensesCompanion.insert(id: 'e1', vehicleId: own.id, at: DateTime(2025, 3, 1), kind: 'service', description: 'Oil change', cost: 180, location: const Value('Test Motors')));
      await repo.upsertExpense(ExpensesCompanion.insert(id: 'e2', vehicleId: own.id, at: DateTime(2026, 9, 1), kind: 'wof', description: 'WOF', cost: 65));
      await repo.upsertExpense(ExpensesCompanion.insert(id: 'e3', vehicleId: ute.id, at: DateTime(2026, 1, 5), kind: 'rego', description: 'Ute rego', cost: 120));
      await db.into(db.attachments).insert(AttachmentsCompanion.insert(id: 'a1', vehicleId: own.id, ownerKind: 'expense', ownerId: 'e2', fileName: 'x.jpg', mimeType: 'image/jpeg'));
      await db.into(db.attachments).insert(AttachmentsCompanion.insert(id: 'a2', vehicleId: own.id, ownerKind: 'vehicle', ownerId: own.id, fileName: 'y.pdf', mimeType: 'application/pdf', title: const Value('Invoice scan')));
    });
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: HistoryPage())));
    await io(tester);
    await tester.tap(find.text('Expenses'));
    await io(tester);
    expect(find.text('2 expenses · \$245.00'), findsOneWidget);
    expect(find.text('Ute rego'), findsNothing);
    expect(find.text('Add expense'), findsOneWidget);

    await tester.tap(find.text('With documents'));
    await io(tester, 3);
    expect(find.text('Oil change'), findsNothing);
    expect(find.text('WOF'), findsOneWidget);
    await tester.tap(find.text('With documents'));
    await tester.tap(find.byTooltip('Search'));
    await io(tester, 3);
    await tester.enterText(find.byType(TextField), 'motors');
    await io(tester, 3);
    expect(find.text('Oil change'), findsOneWidget);
    expect(find.text('WOF'), findsNothing);

    // Detail page: link the loose invoice, then edit.
    await tester.tap(find.text('Oil change'));
    await io(tester);
    expect(find.text('Test Motors'), findsOneWidget);
    await tester.tap(find.text('Link a document from Documents'));
    await io(tester);
    await tester.tap(find.text('Invoice scan'));
    await io(tester);
    expect((await tester.runAsync(() => repo.attachmentsOf('expense', 'e1')))!.single.id, 'a2');
    await tester.tap(find.byTooltip('Edit'));
    await io(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Cost \$'), '200');
    await tester.tap(find.text('Save'));
    await io(tester);
    expect(find.text('\$200.00'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await io(tester);

    // Add an expense of another type.
    await tester.tap(find.byTooltip('Search'));
    await io(tester, 3);
    await tester.tap(find.text('Add expense'));
    await io(tester);
    await tester.tap(find.text('Registration'));
    await io(tester);
    expect(find.text('Add an expense'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Cost \$'), '99.50');
    await tester.tap(find.text('Save'));
    await io(tester);
    expect(find.text('3 expenses · \$364.50'), findsOneWidget);

    // Every vehicle.
    settings.viewAll.value = true;
    await io(tester);
    expect(find.text('Ute rego'), findsOneWidget);
    expect(find.textContaining('Work ute · '), findsOneWidget);
    expect(find.text('All vehicles'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });

  testWidgets('insights add up every vehicle', (tester) async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final a = (await tester.runAsync(() => repo.ensureVehicle()))!;
    final b = (await tester.runAsync(() => repo.addVehicle('Work ute', 'diesel')))!;
    await settings.setActiveVehicleId(a.id);
    final now = DateTime.now();
    await tester.runAsync(() async {
      for (var i = 0; i < 6; i++) {
        // Very different odometers: mixing them up would give silly distances.
        await repo.upsertEvent(EnergyEventsCompanion.insert(id: 'a$i', vehicleId: a.id, at: DateTime(now.year, now.month - 5 + i, 3), odometerKm: 1000 + i * 500.0, quantity: 40, cost: 100), enqueue: false);
        await repo.upsertEvent(EnergyEventsCompanion.insert(id: 'b$i', vehicleId: b.id, at: DateTime(now.year, now.month - 5 + i, 10), odometerKm: 200000 + i * 1000.0, quantity: 80, cost: 200), enqueue: false);
      }
    });
    tester.view.physicalSize = const Size(900, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    settings.viewAll.value = true;
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: InsightsPage())));
    await io(tester, 12);
    expect(find.text('All vehicles'), findsOneWidget);
    // About 5 months of 500 + 1000 km, not hundreds of thousands.
    final caption = tester.widget<Text>(find.textContaining('km in this range')).data!;
    final km = int.parse(RegExp(r'^([\d,]+) km').firstMatch(caption)!.group(1)!.replaceAll(',', ''));
    expect(km, inInclusiveRange(5000, 8000));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
