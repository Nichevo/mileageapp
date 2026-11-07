import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Schema. Every table carries a text UUID `id` so rows can be matched across
// the phone, Google Sheets and JSON backups. Timestamps are stored as UTC
// ISO-8601 strings via drift's DateTime columns.
//
// Migration rule: never rename or drop a column in an existing version. Add
// columns with defaults, bump `schemaVersion`, and add a step in `migration`.
// That is what lets a new APK install over the old one and keep the data.
// ---------------------------------------------------------------------------

@DataClassName('Vehicle')
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  /// 'petrol', 'diesel', 'ev', 'hybrid'
  TextColumn get kind => text().withDefault(const Constant('petrol'))();
  TextColumn get make => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get year => integer().nullable()();
  /// Litres for fuel cars, kWh for EVs.
  RealColumn get tankSize => real().nullable()();
  /// L/100 km or kWh/100 km, the maker's figure.
  RealColumn get ratedEconomy => real().nullable()();
  IntColumn get startOdometerKm => integer().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Station')
class Stations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// A petrol fill-up or an EV charge. `quantity` is litres or kWh.
@DataClassName('EnergyEvent')
class EnergyEvents extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  /// 'fuel' or 'charge'
  TextColumn get kind => text().withDefault(const Constant('fuel'))();
  DateTimeColumn get at => dateTime()();
  RealColumn get odometerKm => real()();
  /// Distance since the previous event as recorded by the source (sheet or
  /// old app). The app recomputes from odometer where it can.
  RealColumn get tripKm => real().nullable()();
  RealColumn get quantity => real()();
  RealColumn get cost => real()();
  BoolColumn get isFull => boolean().withDefault(const Constant(true))();
  TextColumn get stationId => text().nullable().references(Stations, #id)();
  TextColumn get stationName => text().nullable()();
  TextColumn get fuelType => text().nullable()();
  TextColumn get chargerType => text().nullable()();
  RealColumn get batteryPctStart => real().nullable()();
  RealColumn get batteryPctEnd => real().nullable()();
  TextColumn get paymentNote => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  /// 'app', 'sheet_import', 'roadtrip_import', 'json_restore'
  TextColumn get source => text().withDefault(const Constant('app'))();
  TextColumn get sourceRef => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  DateTimeColumn get at => dateTime()();
  RealColumn get odometerKm => real().nullable()();
  /// 'insurance', 'rego', 'wof', 'service', 'tyres', 'other'
  TextColumn get kind => text()();
  TextColumn get description => text()();
  RealColumn get cost => real()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get reminderMonths => integer().nullable()();
  IntColumn get reminderKm => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('app'))();
  TextColumn get sourceRef => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Trip')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get name => text()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();
  RealColumn get startOdometerKm => real().nullable()();
  RealColumn get endOdometerKm => real().nullable()();
  RealColumn get gpsDistanceKm => real().nullable()();
  /// 'recording', 'done', 'report' (odometer-only range imported from the old app)
  TextColumn get status => text().withDefault(const Constant('done'))();
  TextColumn get notes => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('app'))();
  TextColumn get sourceRef => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TripPoint')
class TripPoints extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get tripId => text().references(Trips, #id)();
  DateTimeColumn get at => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  RealColumn get speedMps => real().nullable()();
  RealColumn get accuracyM => real().nullable()();
  RealColumn get altitudeM => real().nullable()();
}

@DataClassName('TripStop')
class TripStops extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  DateTimeColumn get arriveAt => dateTime()();
  DateTimeColumn get departAt => dateTime().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get energyEventId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TyreSet')
class TyreSets extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get name => text()();
  DateTimeColumn get fittedAt => dateTime().nullable()();
  RealColumn get fittedOdometerKm => real().nullable()();
  TextColumn get size => text().nullable()();
  RealColumn get cost => real().nullable()();
  RealColumn get recommendedFrontKpa => real().nullable()();
  RealColumn get recommendedRearKpa => real().nullable()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// One pressure check: the pressure found in each tyre and, if air was
/// added, the pressure left. `left*` is null when nothing changed.
@DataClassName('TyreCheck')
class TyreChecks extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get tyreSetId => text().nullable()();
  DateTimeColumn get at => dateTime()();
  RealColumn get odometerKm => real().nullable()();
  RealColumn get foundFlKpa => real().nullable()();
  RealColumn get foundFrKpa => real().nullable()();
  RealColumn get foundRlKpa => real().nullable()();
  RealColumn get foundRrKpa => real().nullable()();
  RealColumn get foundSpareKpa => real().nullable()();
  RealColumn get leftFlKpa => real().nullable()();
  RealColumn get leftFrKpa => real().nullable()();
  RealColumn get leftRlKpa => real().nullable()();
  RealColumn get leftRrKpa => real().nullable()();
  RealColumn get leftSpareKpa => real().nullable()();
  BoolColumn get airAdded => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Pending exports to Google Sheets (and later Dropbox).
@DataClassName('SyncItem')
class SyncQueue extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get rowId => text()();
  /// 'upsert' or 'delete'
  TextColumn get action => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Vehicles,
  Stations,
  EnergyEvents,
  Expenses,
  Trips,
  TripPoints,
  TripStops,
  TyreSets,
  TyreChecks,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Bump this and add a migration step whenever the schema changes.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Example for a future change:
          // if (from < 2) await m.addColumn(vehicles, vehicles.colour);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    // The database file name is part of the app's identity on the phone:
    // keep it as is so updates find the existing data.
    return driftDatabase(name: 'mileagelog');
  }
}
