/// Whole-database JSON backup and restore. The file is the safety net for
/// app updates and phone changes: Settings > Backup writes it, and Restore
/// upserts every row by id, so restoring over an existing database merges
/// rather than duplicates.
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../data/database.dart';

const backupFormatVersion = 1;

/// [attachmentsDir], when given, adds the photo and PDF files themselves
/// (base64), so a restore on a new phone brings them back.
Future<String> exportBackupJson(AppDatabase db, {Directory? attachmentsDir}) async {
  Future<List<Map<String, dynamic>>> dump(TableInfo table) async {
    final rows = await db.select(table).get();
    return rows.map((r) => (r as DataClass).toJson()).toList();
  }

  final data = <String, dynamic>{
    'app': 'MileageLog',
    'format': backupFormatVersion,
    'schema': db.schemaVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'vehicles': await dump(db.vehicles),
    'stations': await dump(db.stations),
    'energy_events': await dump(db.energyEvents),
    'expenses': await dump(db.expenses),
    'trips': await dump(db.trips),
    'trip_points': await dump(db.tripPoints),
    'trip_stops': await dump(db.tripStops),
    'tyre_sets': await dump(db.tyreSets),
    'tyre_checks': await dump(db.tyreChecks),
    'service_items': await dump(db.serviceItems),
    'insurance_policies': await dump(db.insurancePolicies),
    'fuel_credits': await dump(db.fuelCredits),
    'attachments': await dump(db.attachments),
    'vehicle_values': await dump(db.vehicleValues),
    'car_notes': await dump(db.carNotes),
  };
  if (attachmentsDir != null) {
    final files = <String, String>{};
    for (final a in await db.select(db.attachments).get()) {
      final f = File('${attachmentsDir.path}/${a.fileName}');
      if (await f.exists()) files[a.fileName] = base64Encode(await f.readAsBytes());
    }
    data['attachment_files'] = files;
  }
  return const JsonEncoder.withIndent('  ').convert(data);
}

class RestoreSummary {
  final Map<String, int> rows = {};
  @override
  String toString() => rows.entries.map((e) => '${e.value} ${e.key}').join(', ');
}

Future<RestoreSummary> restoreBackupJson(AppDatabase db, String json, {Directory? attachmentsDir}) async {
  final data = jsonDecode(json) as Map<String, dynamic>;
  if (data['app'] != 'MileageLog') {
    throw const FormatException('Not a MileageLog backup file');
  }
  final summary = RestoreSummary();

  Future<void> load<T extends Table, D extends DataClass>(
    String key,
    TableInfo<T, D> table,
    D Function(Map<String, dynamic>) fromJson,
  ) async {
    final list = (data[key] as List?) ?? const [];
    var n = 0;
    for (final item in list) {
      final row = fromJson(item as Map<String, dynamic>);
      await db.into(table).insertOnConflictUpdate(row as Insertable<D>);
      n++;
    }
    summary.rows[key] = n;
  }

  await db.transaction(() async {
    await load('vehicles', db.vehicles, Vehicle.fromJson);
    await load('stations', db.stations, Station.fromJson);
    await load('energy_events', db.energyEvents, EnergyEvent.fromJson);
    await load('expenses', db.expenses, Expense.fromJson);
    await load('trips', db.trips, Trip.fromJson);
    await load('trip_stops', db.tripStops, TripStop.fromJson);
    await load('tyre_sets', db.tyreSets, TyreSet.fromJson);
    await load('tyre_checks', db.tyreChecks, TyreCheck.fromJson);
    await load('service_items', db.serviceItems, ServiceItem.fromJson);
    await load('insurance_policies', db.insurancePolicies, InsurancePolicy.fromJson);
    await load('fuel_credits', db.fuelCredits, FuelCredit.fromJson);
    await load('attachments', db.attachments, Attachment.fromJson);
    await load('vehicle_values', db.vehicleValues, VehicleValue.fromJson);
    await load('car_notes', db.carNotes, CarNote.fromJson);
    // Trip points use an autoincrement key, so they can't be merged by id.
    // Restore a trip's points only when the phone has none for that trip.
    final points = (data['trip_points'] as List?) ?? const [];
    final hadPoints = <String, bool>{};
    var n = 0;
    for (final item in points) {
      final p = TripPoint.fromJson(item as Map<String, dynamic>);
      final skip = hadPoints[p.tripId] ??= (await (db.select(db.tripPoints)
                ..where((x) => x.tripId.equals(p.tripId))
                ..limit(1))
              .get())
          .isNotEmpty;
      if (skip) continue;
      await db.into(db.tripPoints).insert(p.toCompanion(true).copyWith(seq: const Value.absent()));
      n++;
    }
    summary.rows['trip_points'] = n;
  });
  final files = data['attachment_files'];
  if (attachmentsDir != null && files is Map) {
    await attachmentsDir.create(recursive: true);
    var n = 0;
    for (final e in files.entries) {
      final name = e.key as String;
      if (name.contains('/') || name.contains('\\') || name.startsWith('.')) continue; // file names only
      final f = File('${attachmentsDir.path}/$name');
      if (await f.exists()) continue;
      await f.writeAsBytes(base64Decode(e.value as String));
      n++;
    }
    summary.rows['document files'] = n;
  }
  return summary;
}
