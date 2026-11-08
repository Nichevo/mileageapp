import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/data/database.dart';

/// An app update must open the previous version's database and keep its rows.
void main() {
  test('schema v1 database upgrades to v2 without losing data', () async {
    final dir = await Directory.systemTemp.createTemp('mileagelog_migration');
    final file = File('${dir.path}/db.sqlite');

    // Create a database and data, then turn it back into a v1 file.
    var db = AppDatabase(NativeDatabase(file));
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(id: 'v1', name: 'Test car'));
    await db.into(db.trips).insert(TripsCompanion.insert(
          id: 't1',
          vehicleId: 'v1',
          name: 'Old trip',
          startAt: DateTime(2020, 1, 1),
          startOdometerKm: const Value(1000),
          endOdometerKm: const Value(1100),
          status: const Value('report'),
        ));
    await db.close();

    db = AppDatabase(NativeDatabase(file, setup: (raw) {
      if (raw.userVersion == 2) {
        raw.execute('DROP INDEX IF EXISTS trip_points_trip');
        raw.execute('ALTER TABLE trips DROP COLUMN started_by');
        raw.execute('ALTER TABLE trips DROP COLUMN stats_json');
        raw.userVersion = 1;
      }
    }));
    final trips = await db.select(db.trips).get();
    expect(trips.single.name, 'Old trip');
    expect(trips.single.endOdometerKm, 1100);
    expect(trips.single.startedBy, isNull);

    await (db.update(db.trips)..where((t) => t.id.equals('t1'))).write(const TripsCompanion(statsJson: Value('{}')));
    expect((await db.select(db.trips).getSingle()).statsJson, '{}');
    expect((await db.select(db.vehicles).get()).single.name, 'Test car');
    await db.close();
    await dir.delete(recursive: true);
  });
}
