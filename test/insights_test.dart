import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/insights_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('insights renders weekly, monthly and yearly views', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final now = DateTime.now();
    for (var i = 0; i < 30; i++) {
      await repo.upsertEvent(
        EnergyEventsCompanion.insert(
          id: 'e$i',
          vehicleId: v.id,
          at: DateTime(now.year, now.month, now.day - 600 + i * 20),
          odometerKm: 100000 + i * 450.0,
          quantity: 40,
          cost: 110 + i.toDouble(),
          isFull: const Value(true),
        ),
        enqueue: false,
      );
    }

    await tester.pumpWidget(AppScope(
      repo: repo,
      settings: settings,
      child: const MaterialApp(home: InsightsPage()),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.textContaining('DISTANCE PER MONTH'), findsOneWidget);

    await tester.tap(find.text('Weekly'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.textContaining('DISTANCE PER WEEK'), findsOneWidget);

    await tester.tap(find.text('Yearly'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.textContaining('DISTANCE PER YEAR'), findsOneWidget);

    await tester.tap(find.text('All'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.tap(find.text('6 mo'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.textContaining('DISTANCE PER MONTH'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Unmount, let drift close its query streams, then close the database
    // outside the fake clock (closing waits on real timers).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
