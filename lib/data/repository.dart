import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/stats.dart';
import '../import/roadtrip_csv.dart';
import '../import/sheet_csv.dart';
import 'database.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

class ImportSummary {
  int fuelAdded = 0, fuelUpdated = 0, expensesAdded = 0, tripsAdded = 0, tyreSetsAdded = 0;
  final List<String> warnings = [];
  String? vehicleId;
  @override
  String toString() =>
      '$fuelAdded fills added, $fuelUpdated updated, $expensesAdded expenses, $tripsAdded trips, $tyreSetsAdded tyre sets'
      '${warnings.isEmpty ? '' : ', ${warnings.length} warnings'}';
}

class Repository {
  final AppDatabase db;
  Repository(this.db);

  // ---- vehicles ----------------------------------------------------------

  Stream<List<Vehicle>> watchVehicles() =>
      (db.select(db.vehicles)..orderBy([(v) => OrderingTerm.asc(v.createdAt)])).watch();

  Future<List<Vehicle>> vehicles() => db.select(db.vehicles).get();

  Future<Vehicle?> vehicle(String id) =>
      (db.select(db.vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();

  Future<Vehicle> ensureVehicle({String name = 'My car'}) async {
    final existing = await vehicles();
    if (existing.isNotEmpty) return existing.first;
    final id = newId();
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(id: id, name: name));
    return (await vehicle(id))!;
  }

  Future<void> saveVehicle(VehiclesCompanion v) => db.into(db.vehicles).insertOnConflictUpdate(v);

  // ---- stations ----------------------------------------------------------

  Stream<List<Station>> watchStations() =>
      (db.select(db.stations)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();

  Future<Station> stationByName(String name, {double? lat, double? lon}) async {
    final n = name.trim();
    final found = await (db.select(db.stations)..where((s) => s.name.equals(n))).getSingleOrNull();
    if (found != null) return found;
    final id = newId();
    await db.into(db.stations).insert(StationsCompanion.insert(
      id: id,
      name: n,
      brand: Value(n.split(' ').first),
      lat: Value(lat),
      lon: Value(lon),
    ));
    return (await (db.select(db.stations)..where((s) => s.id.equals(id))).getSingle());
  }

  // ---- fuel / charge events ---------------------------------------------

  Stream<List<EnergyEvent>> watchEvents(String vehicleId, {String kind = 'fuel'}) =>
      (db.select(db.energyEvents)
            ..where((e) => e.vehicleId.equals(vehicleId) & e.kind.equals(kind))
            ..orderBy([(e) => OrderingTerm.desc(e.odometerKm)]))
          .watch();

  Future<List<EnergyEvent>> events(String vehicleId, {String kind = 'fuel'}) =>
      (db.select(db.energyEvents)
            ..where((e) => e.vehicleId.equals(vehicleId) & e.kind.equals(kind))
            ..orderBy([(e) => OrderingTerm.asc(e.odometerKm)]))
          .get();

  Future<EnergyEvent?> latestEvent(String vehicleId, {String kind = 'fuel'}) =>
      (db.select(db.energyEvents)
            ..where((e) => e.vehicleId.equals(vehicleId) & e.kind.equals(kind))
            ..orderBy([(e) => OrderingTerm.desc(e.odometerKm)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertEvent(EnergyEventsCompanion e, {bool enqueue = true}) async {
    await db.into(db.energyEvents).insertOnConflictUpdate(e);
    if (enqueue && e.id.present) await _enqueue('energy_events', e.id.value);
  }

  Future<void> deleteEvent(String id) async {
    await (db.delete(db.energyEvents)..where((e) => e.id.equals(id))).go();
    await _enqueue('energy_events', id, action: 'delete');
  }

  static List<FuelRow> toFuelRows(List<EnergyEvent> events) => events
      .map((e) => FuelRow(
            at: e.at,
            odometerKm: e.odometerKm,
            quantity: e.quantity,
            cost: e.cost,
            isFull: e.isFull,
            tripKm: e.tripKm,
          ))
      .toList();

  // ---- expenses ----------------------------------------------------------

  Stream<List<Expense>> watchExpenses(String vehicleId) =>
      (db.select(db.expenses)
            ..where((e) => e.vehicleId.equals(vehicleId))
            ..orderBy([(e) => OrderingTerm.desc(e.at)]))
          .watch();

  Future<List<Expense>> expenses(String vehicleId) => (db.select(db.expenses)
        ..where((e) => e.vehicleId.equals(vehicleId))
        ..orderBy([(e) => OrderingTerm.desc(e.at)]))
      .get();

  Future<void> upsertExpense(ExpensesCompanion e) => db.into(db.expenses).insertOnConflictUpdate(e);

  Future<void> deleteExpense(String id) => (db.delete(db.expenses)..where((e) => e.id.equals(id))).go();

  // ---- car care ----------------------------------------------------------

  Stream<List<ServiceItem>> watchServiceItems(String vehicleId) =>
      (db.select(db.serviceItems)
            ..where((s) => s.vehicleId.equals(vehicleId) & s.active.equals(true))
            ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
          .watch();

  Future<void> upsertServiceItem(ServiceItemsCompanion s) => db.into(db.serviceItems).insertOnConflictUpdate(s);

  Future<void> deleteServiceItem(String id) => db.transaction(() async {
        await (db.update(db.expenses)..where((e) => e.serviceItemId.equals(id)))
            .write(const ExpensesCompanion(serviceItemId: Value(null)));
        await (db.delete(db.serviceItems)..where((s) => s.id.equals(id))).go();
      });

  /// Records a service as an expense and marks the given schedule items done.
  Future<void> logService({
    required String vehicleId,
    required DateTime at,
    required double? odometerKm,
    required String kind,
    required String description,
    required double cost,
    String? location,
    String? notes,
    List<String> itemIds = const [],
  }) =>
      db.transaction(() async {
        await db.into(db.expenses).insert(ExpensesCompanion.insert(
              id: newId(),
              vehicleId: vehicleId,
              at: at,
              odometerKm: Value(odometerKm),
              kind: kind,
              description: description,
              cost: cost,
              location: Value(location),
              notes: Value(notes),
              serviceItemId: Value(itemIds.isEmpty ? null : itemIds.first),
            ));
        for (final id in itemIds) {
          final item = await (db.select(db.serviceItems)..where((s) => s.id.equals(id))).getSingleOrNull();
          if (item == null) continue;
          // Only move "last done" forward, so logging an old record doesn't
          // pull the schedule back.
          if (item.lastDoneAt == null || !at.isBefore(item.lastDoneAt!)) {
            await (db.update(db.serviceItems)..where((s) => s.id.equals(id)))
                .write(ServiceItemsCompanion(lastDoneAt: Value(at), lastDoneKm: Value(odometerKm)));
          }
        }
      });

  Stream<List<InsurancePolicy>> watchPolicies(String vehicleId) =>
      (db.select(db.insurancePolicies)
            ..where((p) => p.vehicleId.equals(vehicleId))
            ..orderBy([(p) => OrderingTerm.desc(p.startAt)]))
          .watch();

  Future<void> upsertPolicy(InsurancePoliciesCompanion p) => db.into(db.insurancePolicies).insertOnConflictUpdate(p);

  Future<void> deletePolicy(String id) => (db.delete(db.insurancePolicies)..where((p) => p.id.equals(id))).go();

  Stream<List<TyreSet>> watchTyreSets(String vehicleId) =>
      (db.select(db.tyreSets)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([(t) => OrderingTerm.desc(t.fittedAt)]))
          .watch();

  Future<void> upsertTyreSet(TyreSetsCompanion t) => db.into(db.tyreSets).insertOnConflictUpdate(t);

  Stream<List<TyreCheck>> watchTyreChecks(String vehicleId) =>
      (db.select(db.tyreChecks)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([(t) => OrderingTerm.desc(t.at)]))
          .watch();

  Future<void> upsertTyreCheck(TyreChecksCompanion t) => db.into(db.tyreChecks).insertOnConflictUpdate(t);

  Future<void> deleteTyreCheck(String id) => (db.delete(db.tyreChecks)..where((t) => t.id.equals(id))).go();

  // ---- trips -------------------------------------------------------------

  Stream<List<Trip>> watchTrips(String vehicleId) =>
      (db.select(db.trips)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([(t) => OrderingTerm.desc(t.startAt)]))
          .watch();

  Future<Trip?> trip(String id) => (db.select(db.trips)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Trip?> watchTrip(String id) =>
      (db.select(db.trips)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<TripPoint>> tripPoints(String tripId) => (db.select(db.tripPoints)
        ..where((p) => p.tripId.equals(tripId))
        ..orderBy([(p) => OrderingTerm.asc(p.at)]))
      .get();

  Future<List<TripStop>> tripStops(String tripId) => (db.select(db.tripStops)
        ..where((s) => s.tripId.equals(tripId))
        ..orderBy([(s) => OrderingTerm.asc(s.arriveAt)]))
      .get();

  Future<void> upsertTrip(TripsCompanion t) => db.into(db.trips).insertOnConflictUpdate(t);

  Future<void> renameTrip(String id, String name, {String? notes}) =>
      (db.update(db.trips)..where((t) => t.id.equals(id))).write(TripsCompanion(name: Value(name), notes: Value(notes)));

  Future<void> deleteTrip(String id) => db.transaction(() async {
        await (db.delete(db.tripPoints)..where((p) => p.tripId.equals(id))).go();
        await (db.delete(db.tripStops)..where((s) => s.tripId.equals(id))).go();
        await (db.delete(db.trips)..where((t) => t.id.equals(id))).go();
      });

  /// Replaces a trip's points and stops in one go (used when a recording ends).
  Future<void> saveRecordedTrip(TripsCompanion trip, List<TripPointsCompanion> points, List<TripStopsCompanion> stops) =>
      db.transaction(() async {
        final id = trip.id.value;
        await db.into(db.trips).insertOnConflictUpdate(trip);
        await (db.delete(db.tripPoints)..where((p) => p.tripId.equals(id))).go();
        await (db.delete(db.tripStops)..where((s) => s.tripId.equals(id))).go();
        await db.batch((b) {
          b.insertAll(db.tripPoints, points);
          b.insertAll(db.tripStops, stops);
        });
      });

  // ---- sync queue --------------------------------------------------------

  Future<void> _enqueue(String table, String rowId, {String action = 'upsert'}) =>
      db.into(db.syncQueue).insert(SyncQueueCompanion.insert(targetTable: table, rowId: rowId, action: action));

  Future<List<SyncItem>> pendingSync() =>
      (db.select(db.syncQueue)..orderBy([(s) => OrderingTerm.asc(s.seq)])).get();

  Stream<int> watchPendingSyncCount() =>
      db.select(db.syncQueue).watch().map((rows) => rows.length);

  Future<void> markSynced(int seq) => (db.delete(db.syncQueue)..where((s) => s.seq.equals(seq))).go();

  Future<void> markSyncFailed(int seq, String error) => (db.update(db.syncQueue)..where((s) => s.seq.equals(seq)))
      .write(SyncQueueCompanion(attempts: const Value(1), lastError: Value(error)));

  Future<void> enqueueAll(String vehicleId) async {
    final all = await events(vehicleId);
    for (final e in all) {
      await _enqueue('energy_events', e.id);
    }
  }

  // ---- imports -----------------------------------------------------------

  Future<ImportSummary> importRoadTrip(RoadTripExport export, {String? vehicleId}) async {
    final summary = ImportSummary()..warnings.addAll(export.warnings);
    await db.transaction(() async {
      Vehicle v;
      if (vehicleId != null) {
        v = (await vehicle(vehicleId))!;
      } else {
        v = await ensureVehicle(name: 'My car');
      }
      // Fill in tank size from the export if the vehicle has none.
      if (v.tankSize == null && export.vehicle?.tankCapacity != null) {
        await (db.update(db.vehicles)..where((x) => x.id.equals(v.id)))
            .write(VehiclesCompanion(tankSize: Value(export.vehicle!.tankCapacity)));
      }
      summary.vehicleId = v.id;

      for (final f in export.fuel) {
        final ref = 'roadtrip:${f.id}';
        final existing = await (db.select(db.energyEvents)
              ..where((e) => e.sourceRef.equals(ref) & e.vehicleId.equals(v.id)))
            .getSingleOrNull();
        Station? station;
        if (f.location != null) station = await stationByName(f.location!, lat: f.lat, lon: f.lon);
        final c = EnergyEventsCompanion(
          id: Value(existing?.id ?? newId()),
          vehicleId: Value(v.id),
          kind: const Value('fuel'),
          at: Value(f.at),
          odometerKm: Value(f.odometerKm),
          tripKm: Value(f.tripKm),
          quantity: Value(f.quantity),
          cost: Value(f.cost),
          isFull: Value(!f.partial),
          stationId: Value(station?.id),
          stationName: Value(f.location),
          fuelType: Value(normaliseOctane(f.octane)),
          paymentNote: Value(f.payment),
          notes: Value(f.note),
          lat: Value(f.lat),
          lon: Value(f.lon),
          source: const Value('roadtrip_import'),
          sourceRef: Value(ref),
          updatedAt: Value(DateTime.now()),
        );
        await db.into(db.energyEvents).insertOnConflictUpdate(c);
        existing == null ? summary.fuelAdded++ : summary.fuelUpdated++;
      }

      for (final m in export.maintenance) {
        final ref = 'roadtrip:${m.id}';
        final existing = await (db.select(db.expenses)..where((e) => e.sourceRef.equals(ref))).getSingleOrNull();
        if (existing != null) continue;
        await db.into(db.expenses).insert(ExpensesCompanion.insert(
          id: newId(),
          vehicleId: v.id,
          at: m.at,
          odometerKm: Value(m.odometerKm),
          kind: expenseKindFor(m.description, m.type),
          description: m.description,
          cost: m.cost,
          location: Value(m.location),
          notes: Value(m.note),
          reminderMonths: Value(reminderMonths(m.reminderInterval)),
          source: const Value('roadtrip_import'),
          sourceRef: Value(ref),
        ));
        summary.expensesAdded++;
      }

      for (final t in export.trips) {
        final ref = 'roadtrip:${t.id}';
        final existing = await (db.select(db.trips)..where((e) => e.sourceRef.equals(ref))).getSingleOrNull();
        if (existing != null) continue;
        await db.into(db.trips).insert(TripsCompanion.insert(
          id: newId(),
          vehicleId: v.id,
          name: t.name,
          startAt: t.startAt,
          endAt: Value(t.endAt),
          startOdometerKm: Value(t.startOdometerKm),
          endOdometerKm: Value(t.endOdometerKm),
          gpsDistanceKm: Value(t.distanceKm),
          status: const Value('report'),
          source: const Value('roadtrip_import'),
          sourceRef: Value(ref),
        ));
        summary.tripsAdded++;
      }

      for (final ts in export.tyreSets) {
        final existing = await (db.select(db.tyreSets)
              ..where((e) => e.vehicleId.equals(v.id) & e.name.equals(ts.name)))
            .getSingleOrNull();
        if (existing != null) continue;
        await db.into(db.tyreSets).insert(TyreSetsCompanion.insert(
          id: newId(),
          vehicleId: v.id,
          name: ts.name,
          fittedAt: Value(ts.startAt),
          fittedOdometerKm: Value(ts.startOdometerKm),
          size: Value(ts.size),
        ));
        summary.tyreSetsAdded++;
      }
    });
    return summary;
  }

  Future<ImportSummary> importSheet(SheetImportResult result, {required String vehicleId}) async {
    final summary = ImportSummary()
      ..warnings.addAll(result.warnings)
      ..vehicleId = vehicleId;
    await db.transaction(() async {
      for (final f in result.fills) {
        final ref = 'sheet:${f.rowNumber}';
        final existing = await (db.select(db.energyEvents)
              ..where((e) => e.sourceRef.equals(ref) & e.vehicleId.equals(vehicleId)))
            .getSingleOrNull();
        final stationName = stationNameFromSheet(f.location);
        final station = f.location == null ? null : await stationByName(stationName);
        final split = splitSheetComment(f.comments);
        final c = EnergyEventsCompanion(
          id: Value(existing?.id ?? newId()),
          vehicleId: Value(vehicleId),
          kind: const Value('fuel'),
          at: Value(f.at),
          odometerKm: Value(f.odometerKm),
          tripKm: Value(f.tripKm),
          quantity: Value(f.litres),
          cost: Value(f.cost),
          isFull: const Value(true),
          stationId: Value(station?.id),
          stationName: Value(station?.name),
          paymentNote: Value(split.payment),
          notes: Value(split.note),
          source: const Value('sheet_import'),
          sourceRef: Value(ref),
          updatedAt: Value(DateTime.now()),
        );
        await db.into(db.energyEvents).insertOnConflictUpdate(c);
        existing == null ? summary.fuelAdded++ : summary.fuelUpdated++;
      }
    });
    return summary;
  }
}

String expenseKindFor(String description, String type) {
  final d = description.toLowerCase();
  if (d.contains('insur')) return 'insurance';
  if (d.contains('rego') || d.contains('registration') || d.contains('licen')) return 'rego';
  if (d.contains('wof') || d.contains('warrant')) return 'wof';
  if (d.contains('tire') || d.contains('tyre')) return 'tyres';
  if (d.contains('service') || type.toLowerCase() == 'service') return 'service';
  return 'other';
}
