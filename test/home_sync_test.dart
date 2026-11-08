import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/platform/home_sync.dart';
import 'package:mileagelog/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('widget text and reminders come from the data', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await repo.saveVehicle(VehiclesCompanion(id: Value(v.id), name: Value(v.name), tankSize: const Value(50)));
    await settings.setActiveVehicleId(v.id);
    final now = DateTime(2026, 11, 8, 14);
    for (var i = 0; i < 6; i++) {
      await repo.upsertEvent(
        EnergyEventsCompanion.insert(id: 'f$i', vehicleId: v.id, at: now.subtract(Duration(days: 60 - i * 10)), odometerKm: 140000 + i * 400.0, quantity: 36, cost: 100),
        enqueue: false,
      );
    }
    await repo.upsertPolicy(InsurancePoliciesCompanion.insert(
        id: 'p1', vehicleId: v.id, insurer: 'Test Insurer', startAt: DateTime(2025, 12, 20), renewAt: Value(DateTime(2026, 12, 20))));

    final r = await HomeSync.build(repo, settings, now: now);
    expect(r.snapshot['fill'], contains('L/100 km'));
    expect(r.snapshot['yearTitle'], '2026 so far');
    expect(r.snapshot['next'], 'Insurance renewal in 42 days');
    final keys = r.reminders.map((x) => x.key).toList();
    expect(keys.where((k) => k.startsWith('p1@')).length, 3); // 30 days, 7 days, on the day
    expect(keys.any((k) => k.startsWith('fuel-')), isTrue);
    expect(r.reminders.every((x) => x.at.isAfter(now)), isTrue);

    await settings.setRemindersEnabled(false);
    expect((await HomeSync.build(repo, settings, now: now)).reminders, isEmpty);
    await db.close();
  });
}
