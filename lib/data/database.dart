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
  /// v6: 'own', 'loan' or 'rental'.
  TextColumn get ownership => text().withDefault(const Constant('own'))();
  /// v6: set when handed back (loan, rental) or sold; hidden from lists.
  DateTimeColumn get archivedAt => dateTime().nullable()();
  /// v6: loan or rental details (LoanDetails as JSON).
  TextColumn get loanJson => text().nullable()();
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
  /// v4: litres drawn from Z Sharetank (fuel bought earlier at a locked
  /// price). `cost` is then what the fuel really cost: those litres at the
  /// price paid for them, plus anything paid at the pump.
  RealColumn get sharetankLitres => real().nullable()();
  /// v4: what the fill would have cost at the pump price, when known.
  RealColumn get listCost => real().nullable()();
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
  /// v3: the service schedule item this record completed, if any.
  TextColumn get serviceItemId => text().nullable()();
  /// v4: the trip a toll or parking charge belongs to, if any.
  TextColumn get tripId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// v3: something that needs doing every so many months and/or kilometres,
/// such as an oil change, WOF or registration.
@DataClassName('ServiceItem')
class ServiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get name => text()();
  /// Expense kind used when it's logged: 'service', 'wof', 'rego', 'tyres', 'other'
  TextColumn get kind => text().withDefault(const Constant('service'))();
  IntColumn get intervalMonths => integer().nullable()();
  IntColumn get intervalKm => integer().nullable()();
  DateTimeColumn get lastDoneAt => dateTime().nullable()();
  RealColumn get lastDoneKm => real().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

/// v3: one insurance policy period. Kept as history so the insured value
/// over the years can be shown.
@DataClassName('InsurancePolicy')
class InsurancePolicies extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get insurer => text()();
  /// 'comprehensive', 'third_party_fire_theft', 'third_party'
  TextColumn get cover => text().withDefault(const Constant('comprehensive'))();
  /// Stays on the phone; never synced to Sheets.
  TextColumn get policyNumber => text().nullable()();
  RealColumn get insuredValue => real().nullable()();
  /// 'agreed' or 'market'
  TextColumn get valueType => text().nullable()();
  RealColumn get premium => real().nullable()();
  /// 'year' or 'month'
  TextColumn get premiumPeriod => text().withDefault(const Constant('year'))();
  RealColumn get excess => real().nullable()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get renewAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
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
  /// v2: 'manual' or 'bluetooth', how the recording started.
  TextColumn get startedBy => text().nullable()();
  /// v2: summary from computeTripStats, so the list needn't load every point.
  TextColumn get statsJson => text().nullable()();
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

/// v4: fuel bought ahead at a locked price (Z Sharetank). Belongs to the
/// person, not a vehicle; fill-ups draw it down first in, first out.
@DataClassName('FuelCredit')
class FuelCredits extends Table {
  TextColumn get id => text()();
  DateTimeColumn get at => dateTime()();
  /// '91', '95' or 'diesel'
  TextColumn get fuelType => text().nullable()();
  RealColumn get litres => real()();
  RealColumn get cost => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

/// v5: a photo or PDF kept with a record: a service or WOF invoice, an
/// insurance document, registration papers. The file itself lives in the
/// app's private storage under `attachments/<fileName>`.
@DataClassName('Attachment')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  /// What it hangs off: 'expense', 'policy', or 'vehicle' (stand-alone).
  TextColumn get ownerKind => text()();
  TextColumn get ownerId => text()();
  /// 'wof', 'service', 'insurance', 'rego', 'tyres', 'other'
  TextColumn get docType => text().withDefault(const Constant('other'))();
  TextColumn get title => text().nullable()();
  /// File name inside the attachments folder.
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  /// The document's own date (invoice date), when known.
  DateTimeColumn get docDate => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

/// v7: what a vehicle was worth: bought for, estimates, sold for. Insured
/// values come from insurance policies.
@DataClassName('VehicleValue')
class VehicleValues extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  DateTimeColumn get at => dateTime()();
  RealColumn get value => real()();
  /// 'purchase', 'estimate' or 'sold'
  TextColumn get source => text().withDefault(const Constant('estimate'))();
  TextColumn get notes => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  VehicleValues,
  Attachments,
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
  ServiceItems,
  InsurancePolicies,
  FuelCredits,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Bump this and add a migration step whenever the schema changes.
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await m.createIndex(Index('trip_points_trip', 'CREATE INDEX IF NOT EXISTS trip_points_trip ON trip_points (trip_id, at)'));
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(trips, trips.startedBy);
            await m.addColumn(trips, trips.statsJson);
            await m.createIndex(Index('trip_points_trip', 'CREATE INDEX IF NOT EXISTS trip_points_trip ON trip_points (trip_id, at)'));
          }
          if (from < 3) {
            await m.addColumn(expenses, expenses.serviceItemId);
            await m.createTable(serviceItems);
            await m.createTable(insurancePolicies);
          }
          if (from < 4) {
            await m.addColumn(energyEvents, energyEvents.sharetankLitres);
            await m.addColumn(energyEvents, energyEvents.listCost);
            await m.addColumn(expenses, expenses.tripId);
            await m.createTable(fuelCredits);
          }
          if (from < 5) {
            await m.createTable(attachments);
          }
          if (from < 6) {
            await m.addColumn(vehicles, vehicles.ownership);
            await m.addColumn(vehicles, vehicles.archivedAt);
            await m.addColumn(vehicles, vehicles.loanJson);
          }
          if (from < 7) {
            await m.createTable(vehicleValues);
          }
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
