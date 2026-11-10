// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('petrol'),
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tankSizeMeta = const VerificationMeta(
    'tankSize',
  );
  @override
  late final GeneratedColumn<double> tankSize = GeneratedColumn<double>(
    'tank_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratedEconomyMeta = const VerificationMeta(
    'ratedEconomy',
  );
  @override
  late final GeneratedColumn<double> ratedEconomy = GeneratedColumn<double>(
    'rated_economy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startOdometerKmMeta = const VerificationMeta(
    'startOdometerKm',
  );
  @override
  late final GeneratedColumn<int> startOdometerKm = GeneratedColumn<int>(
    'start_odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _ownershipMeta = const VerificationMeta(
    'ownership',
  );
  @override
  late final GeneratedColumn<String> ownership = GeneratedColumn<String>(
    'ownership',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('own'),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanJsonMeta = const VerificationMeta(
    'loanJson',
  );
  @override
  late final GeneratedColumn<String> loanJson = GeneratedColumn<String>(
    'loan_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    make,
    model,
    year,
    tankSize,
    ratedEconomy,
    startOdometerKm,
    purchaseDate,
    notes,
    createdAt,
    ownership,
    archivedAt,
    loanJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('tank_size')) {
      context.handle(
        _tankSizeMeta,
        tankSize.isAcceptableOrUnknown(data['tank_size']!, _tankSizeMeta),
      );
    }
    if (data.containsKey('rated_economy')) {
      context.handle(
        _ratedEconomyMeta,
        ratedEconomy.isAcceptableOrUnknown(
          data['rated_economy']!,
          _ratedEconomyMeta,
        ),
      );
    }
    if (data.containsKey('start_odometer_km')) {
      context.handle(
        _startOdometerKmMeta,
        startOdometerKm.isAcceptableOrUnknown(
          data['start_odometer_km']!,
          _startOdometerKmMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('ownership')) {
      context.handle(
        _ownershipMeta,
        ownership.isAcceptableOrUnknown(data['ownership']!, _ownershipMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('loan_json')) {
      context.handle(
        _loanJsonMeta,
        loanJson.isAcceptableOrUnknown(data['loan_json']!, _loanJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      tankSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tank_size'],
      ),
      ratedEconomy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rated_economy'],
      ),
      startOdometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_odometer_km'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      ownership: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      loanJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_json'],
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String id;
  final String name;

  /// 'petrol', 'diesel', 'ev', 'hybrid'
  final String kind;
  final String? make;
  final String? model;
  final int? year;

  /// Litres for fuel cars, kWh for EVs.
  final double? tankSize;

  /// L/100 km or kWh/100 km, the maker's figure.
  final double? ratedEconomy;
  final int? startOdometerKm;
  final DateTime? purchaseDate;
  final String? notes;
  final DateTime createdAt;

  /// v6: 'own', 'loan' or 'rental'.
  final String ownership;

  /// v6: set when handed back (loan, rental) or sold; hidden from lists.
  final DateTime? archivedAt;

  /// v6: loan or rental details (LoanDetails as JSON).
  final String? loanJson;
  const Vehicle({
    required this.id,
    required this.name,
    required this.kind,
    this.make,
    this.model,
    this.year,
    this.tankSize,
    this.ratedEconomy,
    this.startOdometerKm,
    this.purchaseDate,
    this.notes,
    required this.createdAt,
    required this.ownership,
    this.archivedAt,
    this.loanJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || make != null) {
      map['make'] = Variable<String>(make);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || tankSize != null) {
      map['tank_size'] = Variable<double>(tankSize);
    }
    if (!nullToAbsent || ratedEconomy != null) {
      map['rated_economy'] = Variable<double>(ratedEconomy);
    }
    if (!nullToAbsent || startOdometerKm != null) {
      map['start_odometer_km'] = Variable<int>(startOdometerKm);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['ownership'] = Variable<String>(ownership);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || loanJson != null) {
      map['loan_json'] = Variable<String>(loanJson);
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      make: make == null && nullToAbsent ? const Value.absent() : Value(make),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      tankSize: tankSize == null && nullToAbsent
          ? const Value.absent()
          : Value(tankSize),
      ratedEconomy: ratedEconomy == null && nullToAbsent
          ? const Value.absent()
          : Value(ratedEconomy),
      startOdometerKm: startOdometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(startOdometerKm),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      ownership: Value(ownership),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      loanJson: loanJson == null && nullToAbsent
          ? const Value.absent()
          : Value(loanJson),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      make: serializer.fromJson<String?>(json['make']),
      model: serializer.fromJson<String?>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      tankSize: serializer.fromJson<double?>(json['tankSize']),
      ratedEconomy: serializer.fromJson<double?>(json['ratedEconomy']),
      startOdometerKm: serializer.fromJson<int?>(json['startOdometerKm']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      ownership: serializer.fromJson<String>(json['ownership']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      loanJson: serializer.fromJson<String?>(json['loanJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'make': serializer.toJson<String?>(make),
      'model': serializer.toJson<String?>(model),
      'year': serializer.toJson<int?>(year),
      'tankSize': serializer.toJson<double?>(tankSize),
      'ratedEconomy': serializer.toJson<double?>(ratedEconomy),
      'startOdometerKm': serializer.toJson<int?>(startOdometerKm),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'ownership': serializer.toJson<String>(ownership),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'loanJson': serializer.toJson<String?>(loanJson),
    };
  }

  Vehicle copyWith({
    String? id,
    String? name,
    String? kind,
    Value<String?> make = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<double?> tankSize = const Value.absent(),
    Value<double?> ratedEconomy = const Value.absent(),
    Value<int?> startOdometerKm = const Value.absent(),
    Value<DateTime?> purchaseDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    String? ownership,
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<String?> loanJson = const Value.absent(),
  }) => Vehicle(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    make: make.present ? make.value : this.make,
    model: model.present ? model.value : this.model,
    year: year.present ? year.value : this.year,
    tankSize: tankSize.present ? tankSize.value : this.tankSize,
    ratedEconomy: ratedEconomy.present ? ratedEconomy.value : this.ratedEconomy,
    startOdometerKm: startOdometerKm.present
        ? startOdometerKm.value
        : this.startOdometerKm,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    ownership: ownership ?? this.ownership,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    loanJson: loanJson.present ? loanJson.value : this.loanJson,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      tankSize: data.tankSize.present ? data.tankSize.value : this.tankSize,
      ratedEconomy: data.ratedEconomy.present
          ? data.ratedEconomy.value
          : this.ratedEconomy,
      startOdometerKm: data.startOdometerKm.present
          ? data.startOdometerKm.value
          : this.startOdometerKm,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ownership: data.ownership.present ? data.ownership.value : this.ownership,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      loanJson: data.loanJson.present ? data.loanJson.value : this.loanJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('tankSize: $tankSize, ')
          ..write('ratedEconomy: $ratedEconomy, ')
          ..write('startOdometerKm: $startOdometerKm, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownership: $ownership, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('loanJson: $loanJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    make,
    model,
    year,
    tankSize,
    ratedEconomy,
    startOdometerKm,
    purchaseDate,
    notes,
    createdAt,
    ownership,
    archivedAt,
    loanJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.tankSize == this.tankSize &&
          other.ratedEconomy == this.ratedEconomy &&
          other.startOdometerKm == this.startOdometerKm &&
          other.purchaseDate == this.purchaseDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.ownership == this.ownership &&
          other.archivedAt == this.archivedAt &&
          other.loanJson == this.loanJson);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> make;
  final Value<String?> model;
  final Value<int?> year;
  final Value<double?> tankSize;
  final Value<double?> ratedEconomy;
  final Value<int?> startOdometerKm;
  final Value<DateTime?> purchaseDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String> ownership;
  final Value<DateTime?> archivedAt;
  final Value<String?> loanJson;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.tankSize = const Value.absent(),
    this.ratedEconomy = const Value.absent(),
    this.startOdometerKm = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownership = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.loanJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String name,
    this.kind = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.tankSize = const Value.absent(),
    this.ratedEconomy = const Value.absent(),
    this.startOdometerKm = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownership = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.loanJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Vehicle> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<double>? tankSize,
    Expression<double>? ratedEconomy,
    Expression<int>? startOdometerKm,
    Expression<DateTime>? purchaseDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? ownership,
    Expression<DateTime>? archivedAt,
    Expression<String>? loanJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (tankSize != null) 'tank_size': tankSize,
      if (ratedEconomy != null) 'rated_economy': ratedEconomy,
      if (startOdometerKm != null) 'start_odometer_km': startOdometerKm,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (ownership != null) 'ownership': ownership,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (loanJson != null) 'loan_json': loanJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? make,
    Value<String?>? model,
    Value<int?>? year,
    Value<double?>? tankSize,
    Value<double?>? ratedEconomy,
    Value<int?>? startOdometerKm,
    Value<DateTime?>? purchaseDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String>? ownership,
    Value<DateTime?>? archivedAt,
    Value<String?>? loanJson,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      tankSize: tankSize ?? this.tankSize,
      ratedEconomy: ratedEconomy ?? this.ratedEconomy,
      startOdometerKm: startOdometerKm ?? this.startOdometerKm,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      ownership: ownership ?? this.ownership,
      archivedAt: archivedAt ?? this.archivedAt,
      loanJson: loanJson ?? this.loanJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (tankSize.present) {
      map['tank_size'] = Variable<double>(tankSize.value);
    }
    if (ratedEconomy.present) {
      map['rated_economy'] = Variable<double>(ratedEconomy.value);
    }
    if (startOdometerKm.present) {
      map['start_odometer_km'] = Variable<int>(startOdometerKm.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (ownership.present) {
      map['ownership'] = Variable<String>(ownership.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (loanJson.present) {
      map['loan_json'] = Variable<String>(loanJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('tankSize: $tankSize, ')
          ..write('ratedEconomy: $ratedEconomy, ')
          ..write('startOdometerKm: $startOdometerKm, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownership: $ownership, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('loanJson: $loanJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _ownerKindMeta = const VerificationMeta(
    'ownerKind',
  );
  @override
  late final GeneratedColumn<String> ownerKind = GeneratedColumn<String>(
    'owner_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _docTypeMeta = const VerificationMeta(
    'docType',
  );
  @override
  late final GeneratedColumn<String> docType = GeneratedColumn<String>(
    'doc_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _docDateMeta = const VerificationMeta(
    'docDate',
  );
  @override
  late final GeneratedColumn<DateTime> docDate = GeneratedColumn<DateTime>(
    'doc_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    ownerKind,
    ownerId,
    docType,
    title,
    fileName,
    mimeType,
    sizeBytes,
    docDate,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('owner_kind')) {
      context.handle(
        _ownerKindMeta,
        ownerKind.isAcceptableOrUnknown(data['owner_kind']!, _ownerKindMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKindMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('doc_type')) {
      context.handle(
        _docTypeMeta,
        docType.isAcceptableOrUnknown(data['doc_type']!, _docTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('doc_date')) {
      context.handle(
        _docDateMeta,
        docDate.isAcceptableOrUnknown(data['doc_date']!, _docDateMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      ownerKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_kind'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      docType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      docDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}doc_date'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String vehicleId;

  /// What it hangs off: 'expense', 'policy', or 'vehicle' (stand-alone).
  final String ownerKind;
  final String ownerId;

  /// 'wof', 'service', 'insurance', 'rego', 'tyres', 'other'
  final String docType;
  final String? title;

  /// File name inside the attachments folder.
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  /// The document's own date (invoice date), when known.
  final DateTime? docDate;
  final DateTime addedAt;
  const Attachment({
    required this.id,
    required this.vehicleId,
    required this.ownerKind,
    required this.ownerId,
    required this.docType,
    this.title,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.docDate,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['owner_kind'] = Variable<String>(ownerKind);
    map['owner_id'] = Variable<String>(ownerId);
    map['doc_type'] = Variable<String>(docType);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || docDate != null) {
      map['doc_date'] = Variable<DateTime>(docDate);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      ownerKind: Value(ownerKind),
      ownerId: Value(ownerId),
      docType: Value(docType),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      docDate: docDate == null && nullToAbsent
          ? const Value.absent()
          : Value(docDate),
      addedAt: Value(addedAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      ownerKind: serializer.fromJson<String>(json['ownerKind']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      docType: serializer.fromJson<String>(json['docType']),
      title: serializer.fromJson<String?>(json['title']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      docDate: serializer.fromJson<DateTime?>(json['docDate']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'ownerKind': serializer.toJson<String>(ownerKind),
      'ownerId': serializer.toJson<String>(ownerId),
      'docType': serializer.toJson<String>(docType),
      'title': serializer.toJson<String?>(title),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'docDate': serializer.toJson<DateTime?>(docDate),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? vehicleId,
    String? ownerKind,
    String? ownerId,
    String? docType,
    Value<String?> title = const Value.absent(),
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Value<DateTime?> docDate = const Value.absent(),
    DateTime? addedAt,
  }) => Attachment(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    ownerKind: ownerKind ?? this.ownerKind,
    ownerId: ownerId ?? this.ownerId,
    docType: docType ?? this.docType,
    title: title.present ? title.value : this.title,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    docDate: docDate.present ? docDate.value : this.docDate,
    addedAt: addedAt ?? this.addedAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      ownerKind: data.ownerKind.present ? data.ownerKind.value : this.ownerKind,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      docType: data.docType.present ? data.docType.value : this.docType,
      title: data.title.present ? data.title.value : this.title,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      docDate: data.docDate.present ? data.docDate.value : this.docDate,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('ownerKind: $ownerKind, ')
          ..write('ownerId: $ownerId, ')
          ..write('docType: $docType, ')
          ..write('title: $title, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('docDate: $docDate, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    ownerKind,
    ownerId,
    docType,
    title,
    fileName,
    mimeType,
    sizeBytes,
    docDate,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.ownerKind == this.ownerKind &&
          other.ownerId == this.ownerId &&
          other.docType == this.docType &&
          other.title == this.title &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.docDate == this.docDate &&
          other.addedAt == this.addedAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> ownerKind;
  final Value<String> ownerId;
  final Value<String> docType;
  final Value<String?> title;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<DateTime?> docDate;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.ownerKind = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.docType = const Value.absent(),
    this.title = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.docDate = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String vehicleId,
    required String ownerKind,
    required String ownerId,
    this.docType = const Value.absent(),
    this.title = const Value.absent(),
    required String fileName,
    required String mimeType,
    this.sizeBytes = const Value.absent(),
    this.docDate = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       ownerKind = Value(ownerKind),
       ownerId = Value(ownerId),
       fileName = Value(fileName),
       mimeType = Value(mimeType);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? ownerKind,
    Expression<String>? ownerId,
    Expression<String>? docType,
    Expression<String>? title,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<DateTime>? docDate,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (ownerKind != null) 'owner_kind': ownerKind,
      if (ownerId != null) 'owner_id': ownerId,
      if (docType != null) 'doc_type': docType,
      if (title != null) 'title': title,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (docDate != null) 'doc_date': docDate,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? ownerKind,
    Value<String>? ownerId,
    Value<String>? docType,
    Value<String?>? title,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<DateTime?>? docDate,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      ownerKind: ownerKind ?? this.ownerKind,
      ownerId: ownerId ?? this.ownerId,
      docType: docType ?? this.docType,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      docDate: docDate ?? this.docDate,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (ownerKind.present) {
      map['owner_kind'] = Variable<String>(ownerKind.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(docType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (docDate.present) {
      map['doc_date'] = Variable<DateTime>(docDate.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('ownerKind: $ownerKind, ')
          ..write('ownerId: $ownerId, ')
          ..write('docType: $docType, ')
          ..write('title: $title, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('docDate: $docDate, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StationsTable extends Stations with TableInfo<$StationsTable, Station> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, brand, lat, lon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Station> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Station map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Station(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
    );
  }

  @override
  $StationsTable createAlias(String alias) {
    return $StationsTable(attachedDatabase, alias);
  }
}

class Station extends DataClass implements Insertable<Station> {
  final String id;
  final String name;
  final String? brand;
  final double? lat;
  final double? lon;
  const Station({
    required this.id,
    required this.name,
    this.brand,
    this.lat,
    this.lon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    return map;
  }

  StationsCompanion toCompanion(bool nullToAbsent) {
    return StationsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
    );
  }

  factory Station.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Station(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
    };
  }

  Station copyWith({
    String? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
  }) => Station(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
  );
  Station copyWithCompanion(StationsCompanion data) {
    return Station(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Station(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, brand, lat, lon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Station &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.lat == this.lat &&
          other.lon == this.lon);
}

class StationsCompanion extends UpdateCompanion<Station> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<int> rowid;
  const StationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StationsCompanion.insert({
    required String id,
    required String name,
    this.brand = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Station> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<int>? rowid,
  }) {
    return StationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnergyEventsTable extends EnergyEvents
    with TableInfo<$EnergyEventsTable, EnergyEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fuel'),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripKmMeta = const VerificationMeta('tripKm');
  @override
  late final GeneratedColumn<double> tripKm = GeneratedColumn<double>(
    'trip_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFullMeta = const VerificationMeta('isFull');
  @override
  late final GeneratedColumn<bool> isFull = GeneratedColumn<bool>(
    'is_full',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _stationIdMeta = const VerificationMeta(
    'stationId',
  );
  @override
  late final GeneratedColumn<String> stationId = GeneratedColumn<String>(
    'station_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stations (id)',
    ),
  );
  static const VerificationMeta _stationNameMeta = const VerificationMeta(
    'stationName',
  );
  @override
  late final GeneratedColumn<String> stationName = GeneratedColumn<String>(
    'station_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargerTypeMeta = const VerificationMeta(
    'chargerType',
  );
  @override
  late final GeneratedColumn<String> chargerType = GeneratedColumn<String>(
    'charger_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryPctStartMeta = const VerificationMeta(
    'batteryPctStart',
  );
  @override
  late final GeneratedColumn<double> batteryPctStart = GeneratedColumn<double>(
    'battery_pct_start',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryPctEndMeta = const VerificationMeta(
    'batteryPctEnd',
  );
  @override
  late final GeneratedColumn<double> batteryPctEnd = GeneratedColumn<double>(
    'battery_pct_end',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentNoteMeta = const VerificationMeta(
    'paymentNote',
  );
  @override
  late final GeneratedColumn<String> paymentNote = GeneratedColumn<String>(
    'payment_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sharetankLitresMeta = const VerificationMeta(
    'sharetankLitres',
  );
  @override
  late final GeneratedColumn<double> sharetankLitres = GeneratedColumn<double>(
    'sharetank_litres',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listCostMeta = const VerificationMeta(
    'listCost',
  );
  @override
  late final GeneratedColumn<double> listCost = GeneratedColumn<double>(
    'list_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app'),
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    kind,
    at,
    odometerKm,
    tripKm,
    quantity,
    cost,
    isFull,
    stationId,
    stationName,
    fuelType,
    chargerType,
    batteryPctStart,
    batteryPctEnd,
    paymentNote,
    notes,
    sharetankLitres,
    listCost,
    lat,
    lon,
    source,
    sourceRef,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnergyEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerKmMeta);
    }
    if (data.containsKey('trip_km')) {
      context.handle(
        _tripKmMeta,
        tripKm.isAcceptableOrUnknown(data['trip_km']!, _tripKmMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('is_full')) {
      context.handle(
        _isFullMeta,
        isFull.isAcceptableOrUnknown(data['is_full']!, _isFullMeta),
      );
    }
    if (data.containsKey('station_id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['station_id']!, _stationIdMeta),
      );
    }
    if (data.containsKey('station_name')) {
      context.handle(
        _stationNameMeta,
        stationName.isAcceptableOrUnknown(
          data['station_name']!,
          _stationNameMeta,
        ),
      );
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    }
    if (data.containsKey('charger_type')) {
      context.handle(
        _chargerTypeMeta,
        chargerType.isAcceptableOrUnknown(
          data['charger_type']!,
          _chargerTypeMeta,
        ),
      );
    }
    if (data.containsKey('battery_pct_start')) {
      context.handle(
        _batteryPctStartMeta,
        batteryPctStart.isAcceptableOrUnknown(
          data['battery_pct_start']!,
          _batteryPctStartMeta,
        ),
      );
    }
    if (data.containsKey('battery_pct_end')) {
      context.handle(
        _batteryPctEndMeta,
        batteryPctEnd.isAcceptableOrUnknown(
          data['battery_pct_end']!,
          _batteryPctEndMeta,
        ),
      );
    }
    if (data.containsKey('payment_note')) {
      context.handle(
        _paymentNoteMeta,
        paymentNote.isAcceptableOrUnknown(
          data['payment_note']!,
          _paymentNoteMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sharetank_litres')) {
      context.handle(
        _sharetankLitresMeta,
        sharetankLitres.isAcceptableOrUnknown(
          data['sharetank_litres']!,
          _sharetankLitresMeta,
        ),
      );
    }
    if (data.containsKey('list_cost')) {
      context.handle(
        _listCostMeta,
        listCost.isAcceptableOrUnknown(data['list_cost']!, _listCostMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      )!,
      tripKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trip_km'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      isFull: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full'],
      )!,
      stationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_id'],
      ),
      stationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_name'],
      ),
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      ),
      chargerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charger_type'],
      ),
      batteryPctStart: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_pct_start'],
      ),
      batteryPctEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_pct_end'],
      ),
      paymentNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_note'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sharetankLitres: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sharetank_litres'],
      ),
      listCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}list_cost'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EnergyEventsTable createAlias(String alias) {
    return $EnergyEventsTable(attachedDatabase, alias);
  }
}

class EnergyEvent extends DataClass implements Insertable<EnergyEvent> {
  final String id;
  final String vehicleId;

  /// 'fuel' or 'charge'
  final String kind;
  final DateTime at;
  final double odometerKm;

  /// Distance since the previous event as recorded by the source (sheet or
  /// old app). The app recomputes from odometer where it can.
  final double? tripKm;
  final double quantity;
  final double cost;
  final bool isFull;
  final String? stationId;
  final String? stationName;
  final String? fuelType;
  final String? chargerType;
  final double? batteryPctStart;
  final double? batteryPctEnd;
  final String? paymentNote;
  final String? notes;

  /// v4: litres drawn from Z Sharetank (fuel bought earlier at a locked
  /// price). `cost` is then what the fuel really cost: those litres at the
  /// price paid for them, plus anything paid at the pump.
  final double? sharetankLitres;

  /// v4: what the fill would have cost at the pump price, when known.
  final double? listCost;
  final double? lat;
  final double? lon;

  /// 'app', 'sheet_import', 'roadtrip_import', 'json_restore'
  final String source;
  final String? sourceRef;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EnergyEvent({
    required this.id,
    required this.vehicleId,
    required this.kind,
    required this.at,
    required this.odometerKm,
    this.tripKm,
    required this.quantity,
    required this.cost,
    required this.isFull,
    this.stationId,
    this.stationName,
    this.fuelType,
    this.chargerType,
    this.batteryPctStart,
    this.batteryPctEnd,
    this.paymentNote,
    this.notes,
    this.sharetankLitres,
    this.listCost,
    this.lat,
    this.lon,
    required this.source,
    this.sourceRef,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['kind'] = Variable<String>(kind);
    map['at'] = Variable<DateTime>(at);
    map['odometer_km'] = Variable<double>(odometerKm);
    if (!nullToAbsent || tripKm != null) {
      map['trip_km'] = Variable<double>(tripKm);
    }
    map['quantity'] = Variable<double>(quantity);
    map['cost'] = Variable<double>(cost);
    map['is_full'] = Variable<bool>(isFull);
    if (!nullToAbsent || stationId != null) {
      map['station_id'] = Variable<String>(stationId);
    }
    if (!nullToAbsent || stationName != null) {
      map['station_name'] = Variable<String>(stationName);
    }
    if (!nullToAbsent || fuelType != null) {
      map['fuel_type'] = Variable<String>(fuelType);
    }
    if (!nullToAbsent || chargerType != null) {
      map['charger_type'] = Variable<String>(chargerType);
    }
    if (!nullToAbsent || batteryPctStart != null) {
      map['battery_pct_start'] = Variable<double>(batteryPctStart);
    }
    if (!nullToAbsent || batteryPctEnd != null) {
      map['battery_pct_end'] = Variable<double>(batteryPctEnd);
    }
    if (!nullToAbsent || paymentNote != null) {
      map['payment_note'] = Variable<String>(paymentNote);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || sharetankLitres != null) {
      map['sharetank_litres'] = Variable<double>(sharetankLitres);
    }
    if (!nullToAbsent || listCost != null) {
      map['list_cost'] = Variable<double>(listCost);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EnergyEventsCompanion toCompanion(bool nullToAbsent) {
    return EnergyEventsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      kind: Value(kind),
      at: Value(at),
      odometerKm: Value(odometerKm),
      tripKm: tripKm == null && nullToAbsent
          ? const Value.absent()
          : Value(tripKm),
      quantity: Value(quantity),
      cost: Value(cost),
      isFull: Value(isFull),
      stationId: stationId == null && nullToAbsent
          ? const Value.absent()
          : Value(stationId),
      stationName: stationName == null && nullToAbsent
          ? const Value.absent()
          : Value(stationName),
      fuelType: fuelType == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelType),
      chargerType: chargerType == null && nullToAbsent
          ? const Value.absent()
          : Value(chargerType),
      batteryPctStart: batteryPctStart == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryPctStart),
      batteryPctEnd: batteryPctEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryPctEnd),
      paymentNote: paymentNote == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentNote),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sharetankLitres: sharetankLitres == null && nullToAbsent
          ? const Value.absent()
          : Value(sharetankLitres),
      listCost: listCost == null && nullToAbsent
          ? const Value.absent()
          : Value(listCost),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EnergyEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyEvent(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      kind: serializer.fromJson<String>(json['kind']),
      at: serializer.fromJson<DateTime>(json['at']),
      odometerKm: serializer.fromJson<double>(json['odometerKm']),
      tripKm: serializer.fromJson<double?>(json['tripKm']),
      quantity: serializer.fromJson<double>(json['quantity']),
      cost: serializer.fromJson<double>(json['cost']),
      isFull: serializer.fromJson<bool>(json['isFull']),
      stationId: serializer.fromJson<String?>(json['stationId']),
      stationName: serializer.fromJson<String?>(json['stationName']),
      fuelType: serializer.fromJson<String?>(json['fuelType']),
      chargerType: serializer.fromJson<String?>(json['chargerType']),
      batteryPctStart: serializer.fromJson<double?>(json['batteryPctStart']),
      batteryPctEnd: serializer.fromJson<double?>(json['batteryPctEnd']),
      paymentNote: serializer.fromJson<String?>(json['paymentNote']),
      notes: serializer.fromJson<String?>(json['notes']),
      sharetankLitres: serializer.fromJson<double?>(json['sharetankLitres']),
      listCost: serializer.fromJson<double?>(json['listCost']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'kind': serializer.toJson<String>(kind),
      'at': serializer.toJson<DateTime>(at),
      'odometerKm': serializer.toJson<double>(odometerKm),
      'tripKm': serializer.toJson<double?>(tripKm),
      'quantity': serializer.toJson<double>(quantity),
      'cost': serializer.toJson<double>(cost),
      'isFull': serializer.toJson<bool>(isFull),
      'stationId': serializer.toJson<String?>(stationId),
      'stationName': serializer.toJson<String?>(stationName),
      'fuelType': serializer.toJson<String?>(fuelType),
      'chargerType': serializer.toJson<String?>(chargerType),
      'batteryPctStart': serializer.toJson<double?>(batteryPctStart),
      'batteryPctEnd': serializer.toJson<double?>(batteryPctEnd),
      'paymentNote': serializer.toJson<String?>(paymentNote),
      'notes': serializer.toJson<String?>(notes),
      'sharetankLitres': serializer.toJson<double?>(sharetankLitres),
      'listCost': serializer.toJson<double?>(listCost),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EnergyEvent copyWith({
    String? id,
    String? vehicleId,
    String? kind,
    DateTime? at,
    double? odometerKm,
    Value<double?> tripKm = const Value.absent(),
    double? quantity,
    double? cost,
    bool? isFull,
    Value<String?> stationId = const Value.absent(),
    Value<String?> stationName = const Value.absent(),
    Value<String?> fuelType = const Value.absent(),
    Value<String?> chargerType = const Value.absent(),
    Value<double?> batteryPctStart = const Value.absent(),
    Value<double?> batteryPctEnd = const Value.absent(),
    Value<String?> paymentNote = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<double?> sharetankLitres = const Value.absent(),
    Value<double?> listCost = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EnergyEvent(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    kind: kind ?? this.kind,
    at: at ?? this.at,
    odometerKm: odometerKm ?? this.odometerKm,
    tripKm: tripKm.present ? tripKm.value : this.tripKm,
    quantity: quantity ?? this.quantity,
    cost: cost ?? this.cost,
    isFull: isFull ?? this.isFull,
    stationId: stationId.present ? stationId.value : this.stationId,
    stationName: stationName.present ? stationName.value : this.stationName,
    fuelType: fuelType.present ? fuelType.value : this.fuelType,
    chargerType: chargerType.present ? chargerType.value : this.chargerType,
    batteryPctStart: batteryPctStart.present
        ? batteryPctStart.value
        : this.batteryPctStart,
    batteryPctEnd: batteryPctEnd.present
        ? batteryPctEnd.value
        : this.batteryPctEnd,
    paymentNote: paymentNote.present ? paymentNote.value : this.paymentNote,
    notes: notes.present ? notes.value : this.notes,
    sharetankLitres: sharetankLitres.present
        ? sharetankLitres.value
        : this.sharetankLitres,
    listCost: listCost.present ? listCost.value : this.listCost,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EnergyEvent copyWithCompanion(EnergyEventsCompanion data) {
    return EnergyEvent(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      at: data.at.present ? data.at.value : this.at,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      tripKm: data.tripKm.present ? data.tripKm.value : this.tripKm,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      cost: data.cost.present ? data.cost.value : this.cost,
      isFull: data.isFull.present ? data.isFull.value : this.isFull,
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      stationName: data.stationName.present
          ? data.stationName.value
          : this.stationName,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      chargerType: data.chargerType.present
          ? data.chargerType.value
          : this.chargerType,
      batteryPctStart: data.batteryPctStart.present
          ? data.batteryPctStart.value
          : this.batteryPctStart,
      batteryPctEnd: data.batteryPctEnd.present
          ? data.batteryPctEnd.value
          : this.batteryPctEnd,
      paymentNote: data.paymentNote.present
          ? data.paymentNote.value
          : this.paymentNote,
      notes: data.notes.present ? data.notes.value : this.notes,
      sharetankLitres: data.sharetankLitres.present
          ? data.sharetankLitres.value
          : this.sharetankLitres,
      listCost: data.listCost.present ? data.listCost.value : this.listCost,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyEvent(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('tripKm: $tripKm, ')
          ..write('quantity: $quantity, ')
          ..write('cost: $cost, ')
          ..write('isFull: $isFull, ')
          ..write('stationId: $stationId, ')
          ..write('stationName: $stationName, ')
          ..write('fuelType: $fuelType, ')
          ..write('chargerType: $chargerType, ')
          ..write('batteryPctStart: $batteryPctStart, ')
          ..write('batteryPctEnd: $batteryPctEnd, ')
          ..write('paymentNote: $paymentNote, ')
          ..write('notes: $notes, ')
          ..write('sharetankLitres: $sharetankLitres, ')
          ..write('listCost: $listCost, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    vehicleId,
    kind,
    at,
    odometerKm,
    tripKm,
    quantity,
    cost,
    isFull,
    stationId,
    stationName,
    fuelType,
    chargerType,
    batteryPctStart,
    batteryPctEnd,
    paymentNote,
    notes,
    sharetankLitres,
    listCost,
    lat,
    lon,
    source,
    sourceRef,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyEvent &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.kind == this.kind &&
          other.at == this.at &&
          other.odometerKm == this.odometerKm &&
          other.tripKm == this.tripKm &&
          other.quantity == this.quantity &&
          other.cost == this.cost &&
          other.isFull == this.isFull &&
          other.stationId == this.stationId &&
          other.stationName == this.stationName &&
          other.fuelType == this.fuelType &&
          other.chargerType == this.chargerType &&
          other.batteryPctStart == this.batteryPctStart &&
          other.batteryPctEnd == this.batteryPctEnd &&
          other.paymentNote == this.paymentNote &&
          other.notes == this.notes &&
          other.sharetankLitres == this.sharetankLitres &&
          other.listCost == this.listCost &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EnergyEventsCompanion extends UpdateCompanion<EnergyEvent> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> kind;
  final Value<DateTime> at;
  final Value<double> odometerKm;
  final Value<double?> tripKm;
  final Value<double> quantity;
  final Value<double> cost;
  final Value<bool> isFull;
  final Value<String?> stationId;
  final Value<String?> stationName;
  final Value<String?> fuelType;
  final Value<String?> chargerType;
  final Value<double?> batteryPctStart;
  final Value<double?> batteryPctEnd;
  final Value<String?> paymentNote;
  final Value<String?> notes;
  final Value<double?> sharetankLitres;
  final Value<double?> listCost;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EnergyEventsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.at = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.tripKm = const Value.absent(),
    this.quantity = const Value.absent(),
    this.cost = const Value.absent(),
    this.isFull = const Value.absent(),
    this.stationId = const Value.absent(),
    this.stationName = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.chargerType = const Value.absent(),
    this.batteryPctStart = const Value.absent(),
    this.batteryPctEnd = const Value.absent(),
    this.paymentNote = const Value.absent(),
    this.notes = const Value.absent(),
    this.sharetankLitres = const Value.absent(),
    this.listCost = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnergyEventsCompanion.insert({
    required String id,
    required String vehicleId,
    this.kind = const Value.absent(),
    required DateTime at,
    required double odometerKm,
    this.tripKm = const Value.absent(),
    required double quantity,
    required double cost,
    this.isFull = const Value.absent(),
    this.stationId = const Value.absent(),
    this.stationName = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.chargerType = const Value.absent(),
    this.batteryPctStart = const Value.absent(),
    this.batteryPctEnd = const Value.absent(),
    this.paymentNote = const Value.absent(),
    this.notes = const Value.absent(),
    this.sharetankLitres = const Value.absent(),
    this.listCost = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       at = Value(at),
       odometerKm = Value(odometerKm),
       quantity = Value(quantity),
       cost = Value(cost);
  static Insertable<EnergyEvent> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? kind,
    Expression<DateTime>? at,
    Expression<double>? odometerKm,
    Expression<double>? tripKm,
    Expression<double>? quantity,
    Expression<double>? cost,
    Expression<bool>? isFull,
    Expression<String>? stationId,
    Expression<String>? stationName,
    Expression<String>? fuelType,
    Expression<String>? chargerType,
    Expression<double>? batteryPctStart,
    Expression<double>? batteryPctEnd,
    Expression<String>? paymentNote,
    Expression<String>? notes,
    Expression<double>? sharetankLitres,
    Expression<double>? listCost,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (kind != null) 'kind': kind,
      if (at != null) 'at': at,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (tripKm != null) 'trip_km': tripKm,
      if (quantity != null) 'quantity': quantity,
      if (cost != null) 'cost': cost,
      if (isFull != null) 'is_full': isFull,
      if (stationId != null) 'station_id': stationId,
      if (stationName != null) 'station_name': stationName,
      if (fuelType != null) 'fuel_type': fuelType,
      if (chargerType != null) 'charger_type': chargerType,
      if (batteryPctStart != null) 'battery_pct_start': batteryPctStart,
      if (batteryPctEnd != null) 'battery_pct_end': batteryPctEnd,
      if (paymentNote != null) 'payment_note': paymentNote,
      if (notes != null) 'notes': notes,
      if (sharetankLitres != null) 'sharetank_litres': sharetankLitres,
      if (listCost != null) 'list_cost': listCost,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnergyEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? kind,
    Value<DateTime>? at,
    Value<double>? odometerKm,
    Value<double?>? tripKm,
    Value<double>? quantity,
    Value<double>? cost,
    Value<bool>? isFull,
    Value<String?>? stationId,
    Value<String?>? stationName,
    Value<String?>? fuelType,
    Value<String?>? chargerType,
    Value<double?>? batteryPctStart,
    Value<double?>? batteryPctEnd,
    Value<String?>? paymentNote,
    Value<String?>? notes,
    Value<double?>? sharetankLitres,
    Value<double?>? listCost,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EnergyEventsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      kind: kind ?? this.kind,
      at: at ?? this.at,
      odometerKm: odometerKm ?? this.odometerKm,
      tripKm: tripKm ?? this.tripKm,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      isFull: isFull ?? this.isFull,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      fuelType: fuelType ?? this.fuelType,
      chargerType: chargerType ?? this.chargerType,
      batteryPctStart: batteryPctStart ?? this.batteryPctStart,
      batteryPctEnd: batteryPctEnd ?? this.batteryPctEnd,
      paymentNote: paymentNote ?? this.paymentNote,
      notes: notes ?? this.notes,
      sharetankLitres: sharetankLitres ?? this.sharetankLitres,
      listCost: listCost ?? this.listCost,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (tripKm.present) {
      map['trip_km'] = Variable<double>(tripKm.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (isFull.present) {
      map['is_full'] = Variable<bool>(isFull.value);
    }
    if (stationId.present) {
      map['station_id'] = Variable<String>(stationId.value);
    }
    if (stationName.present) {
      map['station_name'] = Variable<String>(stationName.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (chargerType.present) {
      map['charger_type'] = Variable<String>(chargerType.value);
    }
    if (batteryPctStart.present) {
      map['battery_pct_start'] = Variable<double>(batteryPctStart.value);
    }
    if (batteryPctEnd.present) {
      map['battery_pct_end'] = Variable<double>(batteryPctEnd.value);
    }
    if (paymentNote.present) {
      map['payment_note'] = Variable<String>(paymentNote.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sharetankLitres.present) {
      map['sharetank_litres'] = Variable<double>(sharetankLitres.value);
    }
    if (listCost.present) {
      map['list_cost'] = Variable<double>(listCost.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyEventsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('tripKm: $tripKm, ')
          ..write('quantity: $quantity, ')
          ..write('cost: $cost, ')
          ..write('isFull: $isFull, ')
          ..write('stationId: $stationId, ')
          ..write('stationName: $stationName, ')
          ..write('fuelType: $fuelType, ')
          ..write('chargerType: $chargerType, ')
          ..write('batteryPctStart: $batteryPctStart, ')
          ..write('batteryPctEnd: $batteryPctEnd, ')
          ..write('paymentNote: $paymentNote, ')
          ..write('notes: $notes, ')
          ..write('sharetankLitres: $sharetankLitres, ')
          ..write('listCost: $listCost, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderMonthsMeta = const VerificationMeta(
    'reminderMonths',
  );
  @override
  late final GeneratedColumn<int> reminderMonths = GeneratedColumn<int>(
    'reminder_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderKmMeta = const VerificationMeta(
    'reminderKm',
  );
  @override
  late final GeneratedColumn<int> reminderKm = GeneratedColumn<int>(
    'reminder_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app'),
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceItemIdMeta = const VerificationMeta(
    'serviceItemId',
  );
  @override
  late final GeneratedColumn<String> serviceItemId = GeneratedColumn<String>(
    'service_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    at,
    odometerKm,
    kind,
    description,
    cost,
    location,
    notes,
    reminderMonths,
    reminderKm,
    source,
    sourceRef,
    serviceItemId,
    tripId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reminder_months')) {
      context.handle(
        _reminderMonthsMeta,
        reminderMonths.isAcceptableOrUnknown(
          data['reminder_months']!,
          _reminderMonthsMeta,
        ),
      );
    }
    if (data.containsKey('reminder_km')) {
      context.handle(
        _reminderKmMeta,
        reminderKm.isAcceptableOrUnknown(data['reminder_km']!, _reminderKmMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('service_item_id')) {
      context.handle(
        _serviceItemIdMeta,
        serviceItemId.isAcceptableOrUnknown(
          data['service_item_id']!,
          _serviceItemIdMeta,
        ),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reminderMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_months'],
      ),
      reminderKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_km'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      serviceItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_item_id'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String vehicleId;
  final DateTime at;
  final double? odometerKm;

  /// 'insurance', 'rego', 'wof', 'service', 'tyres', 'other'
  final String kind;
  final String description;
  final double cost;
  final String? location;
  final String? notes;
  final int? reminderMonths;
  final int? reminderKm;
  final String source;
  final String? sourceRef;

  /// v3: the service schedule item this record completed, if any.
  final String? serviceItemId;

  /// v4: the trip a toll or parking charge belongs to, if any.
  final String? tripId;
  const Expense({
    required this.id,
    required this.vehicleId,
    required this.at,
    this.odometerKm,
    required this.kind,
    required this.description,
    required this.cost,
    this.location,
    this.notes,
    this.reminderMonths,
    this.reminderKm,
    required this.source,
    this.sourceRef,
    this.serviceItemId,
    this.tripId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || odometerKm != null) {
      map['odometer_km'] = Variable<double>(odometerKm);
    }
    map['kind'] = Variable<String>(kind);
    map['description'] = Variable<String>(description);
    map['cost'] = Variable<double>(cost);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || reminderMonths != null) {
      map['reminder_months'] = Variable<int>(reminderMonths);
    }
    if (!nullToAbsent || reminderKm != null) {
      map['reminder_km'] = Variable<int>(reminderKm);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    if (!nullToAbsent || serviceItemId != null) {
      map['service_item_id'] = Variable<String>(serviceItemId);
    }
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<String>(tripId);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      at: Value(at),
      odometerKm: odometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerKm),
      kind: Value(kind),
      description: Value(description),
      cost: Value(cost),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      reminderMonths: reminderMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMonths),
      reminderKm: reminderKm == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderKm),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      serviceItemId: serviceItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceItemId),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      at: serializer.fromJson<DateTime>(json['at']),
      odometerKm: serializer.fromJson<double?>(json['odometerKm']),
      kind: serializer.fromJson<String>(json['kind']),
      description: serializer.fromJson<String>(json['description']),
      cost: serializer.fromJson<double>(json['cost']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      reminderMonths: serializer.fromJson<int?>(json['reminderMonths']),
      reminderKm: serializer.fromJson<int?>(json['reminderKm']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      serviceItemId: serializer.fromJson<String?>(json['serviceItemId']),
      tripId: serializer.fromJson<String?>(json['tripId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'at': serializer.toJson<DateTime>(at),
      'odometerKm': serializer.toJson<double?>(odometerKm),
      'kind': serializer.toJson<String>(kind),
      'description': serializer.toJson<String>(description),
      'cost': serializer.toJson<double>(cost),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'reminderMonths': serializer.toJson<int?>(reminderMonths),
      'reminderKm': serializer.toJson<int?>(reminderKm),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'serviceItemId': serializer.toJson<String?>(serviceItemId),
      'tripId': serializer.toJson<String?>(tripId),
    };
  }

  Expense copyWith({
    String? id,
    String? vehicleId,
    DateTime? at,
    Value<double?> odometerKm = const Value.absent(),
    String? kind,
    String? description,
    double? cost,
    Value<String?> location = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> reminderMonths = const Value.absent(),
    Value<int?> reminderKm = const Value.absent(),
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    Value<String?> serviceItemId = const Value.absent(),
    Value<String?> tripId = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    at: at ?? this.at,
    odometerKm: odometerKm.present ? odometerKm.value : this.odometerKm,
    kind: kind ?? this.kind,
    description: description ?? this.description,
    cost: cost ?? this.cost,
    location: location.present ? location.value : this.location,
    notes: notes.present ? notes.value : this.notes,
    reminderMonths: reminderMonths.present
        ? reminderMonths.value
        : this.reminderMonths,
    reminderKm: reminderKm.present ? reminderKm.value : this.reminderKm,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    serviceItemId: serviceItemId.present
        ? serviceItemId.value
        : this.serviceItemId,
    tripId: tripId.present ? tripId.value : this.tripId,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      at: data.at.present ? data.at.value : this.at,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      kind: data.kind.present ? data.kind.value : this.kind,
      description: data.description.present
          ? data.description.value
          : this.description,
      cost: data.cost.present ? data.cost.value : this.cost,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      reminderMonths: data.reminderMonths.present
          ? data.reminderMonths.value
          : this.reminderMonths,
      reminderKm: data.reminderKm.present
          ? data.reminderKm.value
          : this.reminderKm,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      serviceItemId: data.serviceItemId.present
          ? data.serviceItemId.value
          : this.serviceItemId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('at: $at, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('kind: $kind, ')
          ..write('description: $description, ')
          ..write('cost: $cost, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('reminderMonths: $reminderMonths, ')
          ..write('reminderKm: $reminderKm, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('serviceItemId: $serviceItemId, ')
          ..write('tripId: $tripId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    at,
    odometerKm,
    kind,
    description,
    cost,
    location,
    notes,
    reminderMonths,
    reminderKm,
    source,
    sourceRef,
    serviceItemId,
    tripId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.at == this.at &&
          other.odometerKm == this.odometerKm &&
          other.kind == this.kind &&
          other.description == this.description &&
          other.cost == this.cost &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.reminderMonths == this.reminderMonths &&
          other.reminderKm == this.reminderKm &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.serviceItemId == this.serviceItemId &&
          other.tripId == this.tripId);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<DateTime> at;
  final Value<double?> odometerKm;
  final Value<String> kind;
  final Value<String> description;
  final Value<double> cost;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<int?> reminderMonths;
  final Value<int?> reminderKm;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<String?> serviceItemId;
  final Value<String?> tripId;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.at = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.kind = const Value.absent(),
    this.description = const Value.absent(),
    this.cost = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderMonths = const Value.absent(),
    this.reminderKm = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.serviceItemId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String vehicleId,
    required DateTime at,
    this.odometerKm = const Value.absent(),
    required String kind,
    required String description,
    required double cost,
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderMonths = const Value.absent(),
    this.reminderKm = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.serviceItemId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       at = Value(at),
       kind = Value(kind),
       description = Value(description),
       cost = Value(cost);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<DateTime>? at,
    Expression<double>? odometerKm,
    Expression<String>? kind,
    Expression<String>? description,
    Expression<double>? cost,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<int>? reminderMonths,
    Expression<int>? reminderKm,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<String>? serviceItemId,
    Expression<String>? tripId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (at != null) 'at': at,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (kind != null) 'kind': kind,
      if (description != null) 'description': description,
      if (cost != null) 'cost': cost,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (reminderMonths != null) 'reminder_months': reminderMonths,
      if (reminderKm != null) 'reminder_km': reminderKm,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (serviceItemId != null) 'service_item_id': serviceItemId,
      if (tripId != null) 'trip_id': tripId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<DateTime>? at,
    Value<double?>? odometerKm,
    Value<String>? kind,
    Value<String>? description,
    Value<double>? cost,
    Value<String?>? location,
    Value<String?>? notes,
    Value<int?>? reminderMonths,
    Value<int?>? reminderKm,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<String?>? serviceItemId,
    Value<String?>? tripId,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      at: at ?? this.at,
      odometerKm: odometerKm ?? this.odometerKm,
      kind: kind ?? this.kind,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      reminderMonths: reminderMonths ?? this.reminderMonths,
      reminderKm: reminderKm ?? this.reminderKm,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      serviceItemId: serviceItemId ?? this.serviceItemId,
      tripId: tripId ?? this.tripId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reminderMonths.present) {
      map['reminder_months'] = Variable<int>(reminderMonths.value);
    }
    if (reminderKm.present) {
      map['reminder_km'] = Variable<int>(reminderKm.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (serviceItemId.present) {
      map['service_item_id'] = Variable<String>(serviceItemId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('at: $at, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('kind: $kind, ')
          ..write('description: $description, ')
          ..write('cost: $cost, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('reminderMonths: $reminderMonths, ')
          ..write('reminderKm: $reminderKm, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('serviceItemId: $serviceItemId, ')
          ..write('tripId: $tripId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startOdometerKmMeta = const VerificationMeta(
    'startOdometerKm',
  );
  @override
  late final GeneratedColumn<double> startOdometerKm = GeneratedColumn<double>(
    'start_odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endOdometerKmMeta = const VerificationMeta(
    'endOdometerKm',
  );
  @override
  late final GeneratedColumn<double> endOdometerKm = GeneratedColumn<double>(
    'end_odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsDistanceKmMeta = const VerificationMeta(
    'gpsDistanceKm',
  );
  @override
  late final GeneratedColumn<double> gpsDistanceKm = GeneratedColumn<double>(
    'gps_distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('done'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app'),
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedByMeta = const VerificationMeta(
    'startedBy',
  );
  @override
  late final GeneratedColumn<String> startedBy = GeneratedColumn<String>(
    'started_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statsJsonMeta = const VerificationMeta(
    'statsJson',
  );
  @override
  late final GeneratedColumn<String> statsJson = GeneratedColumn<String>(
    'stats_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    name,
    startAt,
    endAt,
    startOdometerKm,
    endOdometerKm,
    gpsDistanceKm,
    status,
    notes,
    source,
    sourceRef,
    startedBy,
    statsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('start_odometer_km')) {
      context.handle(
        _startOdometerKmMeta,
        startOdometerKm.isAcceptableOrUnknown(
          data['start_odometer_km']!,
          _startOdometerKmMeta,
        ),
      );
    }
    if (data.containsKey('end_odometer_km')) {
      context.handle(
        _endOdometerKmMeta,
        endOdometerKm.isAcceptableOrUnknown(
          data['end_odometer_km']!,
          _endOdometerKmMeta,
        ),
      );
    }
    if (data.containsKey('gps_distance_km')) {
      context.handle(
        _gpsDistanceKmMeta,
        gpsDistanceKm.isAcceptableOrUnknown(
          data['gps_distance_km']!,
          _gpsDistanceKmMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('started_by')) {
      context.handle(
        _startedByMeta,
        startedBy.isAcceptableOrUnknown(data['started_by']!, _startedByMeta),
      );
    }
    if (data.containsKey('stats_json')) {
      context.handle(
        _statsJsonMeta,
        statsJson.isAcceptableOrUnknown(data['stats_json']!, _statsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      startOdometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_odometer_km'],
      ),
      endOdometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_odometer_km'],
      ),
      gpsDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_distance_km'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      startedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_by'],
      ),
      statsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats_json'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String vehicleId;
  final String name;
  final DateTime startAt;
  final DateTime? endAt;
  final double? startOdometerKm;
  final double? endOdometerKm;
  final double? gpsDistanceKm;

  /// 'recording', 'done', 'report' (odometer-only range imported from the old app)
  final String status;
  final String? notes;
  final String source;
  final String? sourceRef;

  /// v2: 'manual' or 'bluetooth', how the recording started.
  final String? startedBy;

  /// v2: summary from computeTripStats, so the list needn't load every point.
  final String? statsJson;
  const Trip({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.startAt,
    this.endAt,
    this.startOdometerKm,
    this.endOdometerKm,
    this.gpsDistanceKm,
    required this.status,
    this.notes,
    required this.source,
    this.sourceRef,
    this.startedBy,
    this.statsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['name'] = Variable<String>(name);
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    if (!nullToAbsent || startOdometerKm != null) {
      map['start_odometer_km'] = Variable<double>(startOdometerKm);
    }
    if (!nullToAbsent || endOdometerKm != null) {
      map['end_odometer_km'] = Variable<double>(endOdometerKm);
    }
    if (!nullToAbsent || gpsDistanceKm != null) {
      map['gps_distance_km'] = Variable<double>(gpsDistanceKm);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    if (!nullToAbsent || startedBy != null) {
      map['started_by'] = Variable<String>(startedBy);
    }
    if (!nullToAbsent || statsJson != null) {
      map['stats_json'] = Variable<String>(statsJson);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      name: Value(name),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      startOdometerKm: startOdometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(startOdometerKm),
      endOdometerKm: endOdometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(endOdometerKm),
      gpsDistanceKm: gpsDistanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsDistanceKm),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      startedBy: startedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(startedBy),
      statsJson: statsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(statsJson),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      name: serializer.fromJson<String>(json['name']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      startOdometerKm: serializer.fromJson<double?>(json['startOdometerKm']),
      endOdometerKm: serializer.fromJson<double?>(json['endOdometerKm']),
      gpsDistanceKm: serializer.fromJson<double?>(json['gpsDistanceKm']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      startedBy: serializer.fromJson<String?>(json['startedBy']),
      statsJson: serializer.fromJson<String?>(json['statsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'name': serializer.toJson<String>(name),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'startOdometerKm': serializer.toJson<double?>(startOdometerKm),
      'endOdometerKm': serializer.toJson<double?>(endOdometerKm),
      'gpsDistanceKm': serializer.toJson<double?>(gpsDistanceKm),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'startedBy': serializer.toJson<String?>(startedBy),
      'statsJson': serializer.toJson<String?>(statsJson),
    };
  }

  Trip copyWith({
    String? id,
    String? vehicleId,
    String? name,
    DateTime? startAt,
    Value<DateTime?> endAt = const Value.absent(),
    Value<double?> startOdometerKm = const Value.absent(),
    Value<double?> endOdometerKm = const Value.absent(),
    Value<double?> gpsDistanceKm = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    Value<String?> startedBy = const Value.absent(),
    Value<String?> statsJson = const Value.absent(),
  }) => Trip(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    name: name ?? this.name,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    startOdometerKm: startOdometerKm.present
        ? startOdometerKm.value
        : this.startOdometerKm,
    endOdometerKm: endOdometerKm.present
        ? endOdometerKm.value
        : this.endOdometerKm,
    gpsDistanceKm: gpsDistanceKm.present
        ? gpsDistanceKm.value
        : this.gpsDistanceKm,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    startedBy: startedBy.present ? startedBy.value : this.startedBy,
    statsJson: statsJson.present ? statsJson.value : this.statsJson,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      name: data.name.present ? data.name.value : this.name,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      startOdometerKm: data.startOdometerKm.present
          ? data.startOdometerKm.value
          : this.startOdometerKm,
      endOdometerKm: data.endOdometerKm.present
          ? data.endOdometerKm.value
          : this.endOdometerKm,
      gpsDistanceKm: data.gpsDistanceKm.present
          ? data.gpsDistanceKm.value
          : this.gpsDistanceKm,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      startedBy: data.startedBy.present ? data.startedBy.value : this.startedBy,
      statsJson: data.statsJson.present ? data.statsJson.value : this.statsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('startOdometerKm: $startOdometerKm, ')
          ..write('endOdometerKm: $endOdometerKm, ')
          ..write('gpsDistanceKm: $gpsDistanceKm, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('startedBy: $startedBy, ')
          ..write('statsJson: $statsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    name,
    startAt,
    endAt,
    startOdometerKm,
    endOdometerKm,
    gpsDistanceKm,
    status,
    notes,
    source,
    sourceRef,
    startedBy,
    statsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.name == this.name &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.startOdometerKm == this.startOdometerKm &&
          other.endOdometerKm == this.endOdometerKm &&
          other.gpsDistanceKm == this.gpsDistanceKm &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.startedBy == this.startedBy &&
          other.statsJson == this.statsJson);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> name;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<double?> startOdometerKm;
  final Value<double?> endOdometerKm;
  final Value<double?> gpsDistanceKm;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<String?> startedBy;
  final Value<String?> statsJson;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.name = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.startOdometerKm = const Value.absent(),
    this.endOdometerKm = const Value.absent(),
    this.gpsDistanceKm = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.startedBy = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String vehicleId,
    required String name,
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.startOdometerKm = const Value.absent(),
    this.endOdometerKm = const Value.absent(),
    this.gpsDistanceKm = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.startedBy = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       name = Value(name),
       startAt = Value(startAt);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? name,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<double>? startOdometerKm,
    Expression<double>? endOdometerKm,
    Expression<double>? gpsDistanceKm,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<String>? startedBy,
    Expression<String>? statsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (name != null) 'name': name,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (startOdometerKm != null) 'start_odometer_km': startOdometerKm,
      if (endOdometerKm != null) 'end_odometer_km': endOdometerKm,
      if (gpsDistanceKm != null) 'gps_distance_km': gpsDistanceKm,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (startedBy != null) 'started_by': startedBy,
      if (statsJson != null) 'stats_json': statsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? name,
    Value<DateTime>? startAt,
    Value<DateTime?>? endAt,
    Value<double?>? startOdometerKm,
    Value<double?>? endOdometerKm,
    Value<double?>? gpsDistanceKm,
    Value<String>? status,
    Value<String?>? notes,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<String?>? startedBy,
    Value<String?>? statsJson,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      startOdometerKm: startOdometerKm ?? this.startOdometerKm,
      endOdometerKm: endOdometerKm ?? this.endOdometerKm,
      gpsDistanceKm: gpsDistanceKm ?? this.gpsDistanceKm,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      startedBy: startedBy ?? this.startedBy,
      statsJson: statsJson ?? this.statsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (startOdometerKm.present) {
      map['start_odometer_km'] = Variable<double>(startOdometerKm.value);
    }
    if (endOdometerKm.present) {
      map['end_odometer_km'] = Variable<double>(endOdometerKm.value);
    }
    if (gpsDistanceKm.present) {
      map['gps_distance_km'] = Variable<double>(gpsDistanceKm.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (startedBy.present) {
      map['started_by'] = Variable<String>(startedBy.value);
    }
    if (statsJson.present) {
      map['stats_json'] = Variable<String>(statsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('startOdometerKm: $startOdometerKm, ')
          ..write('endOdometerKm: $endOdometerKm, ')
          ..write('gpsDistanceKm: $gpsDistanceKm, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('startedBy: $startedBy, ')
          ..write('statsJson: $statsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripPointsTable extends TripPoints
    with TableInfo<$TripPointsTable, TripPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    tripId,
    at,
    lat,
    lon,
    speedMps,
    accuracyM,
    altitudeM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  TripPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPoint(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_m'],
      ),
    );
  }

  @override
  $TripPointsTable createAlias(String alias) {
    return $TripPointsTable(attachedDatabase, alias);
  }
}

class TripPoint extends DataClass implements Insertable<TripPoint> {
  final int seq;
  final String tripId;
  final DateTime at;
  final double lat;
  final double lon;
  final double? speedMps;
  final double? accuracyM;
  final double? altitudeM;
  const TripPoint({
    required this.seq,
    required this.tripId,
    required this.at,
    required this.lat,
    required this.lon,
    this.speedMps,
    this.accuracyM,
    this.altitudeM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['trip_id'] = Variable<String>(tripId);
    map['at'] = Variable<DateTime>(at);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    if (!nullToAbsent || speedMps != null) {
      map['speed_mps'] = Variable<double>(speedMps);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    return map;
  }

  TripPointsCompanion toCompanion(bool nullToAbsent) {
    return TripPointsCompanion(
      seq: Value(seq),
      tripId: Value(tripId),
      at: Value(at),
      lat: Value(lat),
      lon: Value(lon),
      speedMps: speedMps == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMps),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
    );
  }

  factory TripPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPoint(
      seq: serializer.fromJson<int>(json['seq']),
      tripId: serializer.fromJson<String>(json['tripId']),
      at: serializer.fromJson<DateTime>(json['at']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      speedMps: serializer.fromJson<double?>(json['speedMps']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'tripId': serializer.toJson<String>(tripId),
      'at': serializer.toJson<DateTime>(at),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'speedMps': serializer.toJson<double?>(speedMps),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'altitudeM': serializer.toJson<double?>(altitudeM),
    };
  }

  TripPoint copyWith({
    int? seq,
    String? tripId,
    DateTime? at,
    double? lat,
    double? lon,
    Value<double?> speedMps = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    Value<double?> altitudeM = const Value.absent(),
  }) => TripPoint(
    seq: seq ?? this.seq,
    tripId: tripId ?? this.tripId,
    at: at ?? this.at,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    speedMps: speedMps.present ? speedMps.value : this.speedMps,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
  );
  TripPoint copyWithCompanion(TripPointsCompanion data) {
    return TripPoint(
      seq: data.seq.present ? data.seq.value : this.seq,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      at: data.at.present ? data.at.value : this.at,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPoint(')
          ..write('seq: $seq, ')
          ..write('tripId: $tripId, ')
          ..write('at: $at, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('speedMps: $speedMps, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('altitudeM: $altitudeM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seq, tripId, at, lat, lon, speedMps, accuracyM, altitudeM);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPoint &&
          other.seq == this.seq &&
          other.tripId == this.tripId &&
          other.at == this.at &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.speedMps == this.speedMps &&
          other.accuracyM == this.accuracyM &&
          other.altitudeM == this.altitudeM);
}

class TripPointsCompanion extends UpdateCompanion<TripPoint> {
  final Value<int> seq;
  final Value<String> tripId;
  final Value<DateTime> at;
  final Value<double> lat;
  final Value<double> lon;
  final Value<double?> speedMps;
  final Value<double?> accuracyM;
  final Value<double?> altitudeM;
  const TripPointsCompanion({
    this.seq = const Value.absent(),
    this.tripId = const Value.absent(),
    this.at = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.altitudeM = const Value.absent(),
  });
  TripPointsCompanion.insert({
    this.seq = const Value.absent(),
    required String tripId,
    required DateTime at,
    required double lat,
    required double lon,
    this.speedMps = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.altitudeM = const Value.absent(),
  }) : tripId = Value(tripId),
       at = Value(at),
       lat = Value(lat),
       lon = Value(lon);
  static Insertable<TripPoint> custom({
    Expression<int>? seq,
    Expression<String>? tripId,
    Expression<DateTime>? at,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? speedMps,
    Expression<double>? accuracyM,
    Expression<double>? altitudeM,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (tripId != null) 'trip_id': tripId,
      if (at != null) 'at': at,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (speedMps != null) 'speed_mps': speedMps,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (altitudeM != null) 'altitude_m': altitudeM,
    });
  }

  TripPointsCompanion copyWith({
    Value<int>? seq,
    Value<String>? tripId,
    Value<DateTime>? at,
    Value<double>? lat,
    Value<double>? lon,
    Value<double?>? speedMps,
    Value<double?>? accuracyM,
    Value<double?>? altitudeM,
  }) {
    return TripPointsCompanion(
      seq: seq ?? this.seq,
      tripId: tripId ?? this.tripId,
      at: at ?? this.at,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      speedMps: speedMps ?? this.speedMps,
      accuracyM: accuracyM ?? this.accuracyM,
      altitudeM: altitudeM ?? this.altitudeM,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripPointsCompanion(')
          ..write('seq: $seq, ')
          ..write('tripId: $tripId, ')
          ..write('at: $at, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('speedMps: $speedMps, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('altitudeM: $altitudeM')
          ..write(')'))
        .toString();
  }
}

class $TripStopsTable extends TripStops
    with TableInfo<$TripStopsTable, TripStop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripStopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _arriveAtMeta = const VerificationMeta(
    'arriveAt',
  );
  @override
  late final GeneratedColumn<DateTime> arriveAt = GeneratedColumn<DateTime>(
    'arrive_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departAtMeta = const VerificationMeta(
    'departAt',
  );
  @override
  late final GeneratedColumn<DateTime> departAt = GeneratedColumn<DateTime>(
    'depart_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyEventIdMeta = const VerificationMeta(
    'energyEventId',
  );
  @override
  late final GeneratedColumn<String> energyEventId = GeneratedColumn<String>(
    'energy_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    arriveAt,
    departAt,
    lat,
    lon,
    name,
    energyEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_stops';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripStop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('arrive_at')) {
      context.handle(
        _arriveAtMeta,
        arriveAt.isAcceptableOrUnknown(data['arrive_at']!, _arriveAtMeta),
      );
    } else if (isInserting) {
      context.missing(_arriveAtMeta);
    }
    if (data.containsKey('depart_at')) {
      context.handle(
        _departAtMeta,
        departAt.isAcceptableOrUnknown(data['depart_at']!, _departAtMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('energy_event_id')) {
      context.handle(
        _energyEventIdMeta,
        energyEventId.isAcceptableOrUnknown(
          data['energy_event_id']!,
          _energyEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripStop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripStop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      arriveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrive_at'],
      )!,
      departAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}depart_at'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      energyEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}energy_event_id'],
      ),
    );
  }

  @override
  $TripStopsTable createAlias(String alias) {
    return $TripStopsTable(attachedDatabase, alias);
  }
}

class TripStop extends DataClass implements Insertable<TripStop> {
  final String id;
  final String tripId;
  final DateTime arriveAt;
  final DateTime? departAt;
  final double? lat;
  final double? lon;
  final String? name;
  final String? energyEventId;
  const TripStop({
    required this.id,
    required this.tripId,
    required this.arriveAt,
    this.departAt,
    this.lat,
    this.lon,
    this.name,
    this.energyEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['arrive_at'] = Variable<DateTime>(arriveAt);
    if (!nullToAbsent || departAt != null) {
      map['depart_at'] = Variable<DateTime>(departAt);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || energyEventId != null) {
      map['energy_event_id'] = Variable<String>(energyEventId);
    }
    return map;
  }

  TripStopsCompanion toCompanion(bool nullToAbsent) {
    return TripStopsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      arriveAt: Value(arriveAt),
      departAt: departAt == null && nullToAbsent
          ? const Value.absent()
          : Value(departAt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      energyEventId: energyEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(energyEventId),
    );
  }

  factory TripStop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripStop(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      arriveAt: serializer.fromJson<DateTime>(json['arriveAt']),
      departAt: serializer.fromJson<DateTime?>(json['departAt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      name: serializer.fromJson<String?>(json['name']),
      energyEventId: serializer.fromJson<String?>(json['energyEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'arriveAt': serializer.toJson<DateTime>(arriveAt),
      'departAt': serializer.toJson<DateTime?>(departAt),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'name': serializer.toJson<String?>(name),
      'energyEventId': serializer.toJson<String?>(energyEventId),
    };
  }

  TripStop copyWith({
    String? id,
    String? tripId,
    DateTime? arriveAt,
    Value<DateTime?> departAt = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> energyEventId = const Value.absent(),
  }) => TripStop(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    arriveAt: arriveAt ?? this.arriveAt,
    departAt: departAt.present ? departAt.value : this.departAt,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    name: name.present ? name.value : this.name,
    energyEventId: energyEventId.present
        ? energyEventId.value
        : this.energyEventId,
  );
  TripStop copyWithCompanion(TripStopsCompanion data) {
    return TripStop(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      arriveAt: data.arriveAt.present ? data.arriveAt.value : this.arriveAt,
      departAt: data.departAt.present ? data.departAt.value : this.departAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      name: data.name.present ? data.name.value : this.name,
      energyEventId: data.energyEventId.present
          ? data.energyEventId.value
          : this.energyEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripStop(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('arriveAt: $arriveAt, ')
          ..write('departAt: $departAt, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('name: $name, ')
          ..write('energyEventId: $energyEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    arriveAt,
    departAt,
    lat,
    lon,
    name,
    energyEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripStop &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.arriveAt == this.arriveAt &&
          other.departAt == this.departAt &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.name == this.name &&
          other.energyEventId == this.energyEventId);
}

class TripStopsCompanion extends UpdateCompanion<TripStop> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<DateTime> arriveAt;
  final Value<DateTime?> departAt;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<String?> name;
  final Value<String?> energyEventId;
  final Value<int> rowid;
  const TripStopsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.arriveAt = const Value.absent(),
    this.departAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.name = const Value.absent(),
    this.energyEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripStopsCompanion.insert({
    required String id,
    required String tripId,
    required DateTime arriveAt,
    this.departAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.name = const Value.absent(),
    this.energyEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       arriveAt = Value(arriveAt);
  static Insertable<TripStop> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? arriveAt,
    Expression<DateTime>? departAt,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? name,
    Expression<String>? energyEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (arriveAt != null) 'arrive_at': arriveAt,
      if (departAt != null) 'depart_at': departAt,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (name != null) 'name': name,
      if (energyEventId != null) 'energy_event_id': energyEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripStopsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<DateTime>? arriveAt,
    Value<DateTime?>? departAt,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<String?>? name,
    Value<String?>? energyEventId,
    Value<int>? rowid,
  }) {
    return TripStopsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      arriveAt: arriveAt ?? this.arriveAt,
      departAt: departAt ?? this.departAt,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      name: name ?? this.name,
      energyEventId: energyEventId ?? this.energyEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (arriveAt.present) {
      map['arrive_at'] = Variable<DateTime>(arriveAt.value);
    }
    if (departAt.present) {
      map['depart_at'] = Variable<DateTime>(departAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (energyEventId.present) {
      map['energy_event_id'] = Variable<String>(energyEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripStopsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('arriveAt: $arriveAt, ')
          ..write('departAt: $departAt, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('name: $name, ')
          ..write('energyEventId: $energyEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TyreSetsTable extends TyreSets with TableInfo<$TyreSetsTable, TyreSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TyreSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fittedAtMeta = const VerificationMeta(
    'fittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fittedAt = GeneratedColumn<DateTime>(
    'fitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fittedOdometerKmMeta = const VerificationMeta(
    'fittedOdometerKm',
  );
  @override
  late final GeneratedColumn<double> fittedOdometerKm = GeneratedColumn<double>(
    'fitted_odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendedFrontKpaMeta =
      const VerificationMeta('recommendedFrontKpa');
  @override
  late final GeneratedColumn<double> recommendedFrontKpa =
      GeneratedColumn<double>(
        'recommended_front_kpa',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recommendedRearKpaMeta =
      const VerificationMeta('recommendedRearKpa');
  @override
  late final GeneratedColumn<double> recommendedRearKpa =
      GeneratedColumn<double>(
        'recommended_rear_kpa',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    name,
    fittedAt,
    fittedOdometerKm,
    size,
    cost,
    recommendedFrontKpa,
    recommendedRearKpa,
    removedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tyre_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<TyreSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fitted_at')) {
      context.handle(
        _fittedAtMeta,
        fittedAt.isAcceptableOrUnknown(data['fitted_at']!, _fittedAtMeta),
      );
    }
    if (data.containsKey('fitted_odometer_km')) {
      context.handle(
        _fittedOdometerKmMeta,
        fittedOdometerKm.isAcceptableOrUnknown(
          data['fitted_odometer_km']!,
          _fittedOdometerKmMeta,
        ),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('recommended_front_kpa')) {
      context.handle(
        _recommendedFrontKpaMeta,
        recommendedFrontKpa.isAcceptableOrUnknown(
          data['recommended_front_kpa']!,
          _recommendedFrontKpaMeta,
        ),
      );
    }
    if (data.containsKey('recommended_rear_kpa')) {
      context.handle(
        _recommendedRearKpaMeta,
        recommendedRearKpa.isAcceptableOrUnknown(
          data['recommended_rear_kpa']!,
          _recommendedRearKpaMeta,
        ),
      );
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TyreSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TyreSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fitted_at'],
      ),
      fittedOdometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fitted_odometer_km'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      ),
      recommendedFrontKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recommended_front_kpa'],
      ),
      recommendedRearKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recommended_rear_kpa'],
      ),
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
    );
  }

  @override
  $TyreSetsTable createAlias(String alias) {
    return $TyreSetsTable(attachedDatabase, alias);
  }
}

class TyreSet extends DataClass implements Insertable<TyreSet> {
  final String id;
  final String vehicleId;
  final String name;
  final DateTime? fittedAt;
  final double? fittedOdometerKm;
  final String? size;
  final double? cost;
  final double? recommendedFrontKpa;
  final double? recommendedRearKpa;
  final DateTime? removedAt;
  const TyreSet({
    required this.id,
    required this.vehicleId,
    required this.name,
    this.fittedAt,
    this.fittedOdometerKm,
    this.size,
    this.cost,
    this.recommendedFrontKpa,
    this.recommendedRearKpa,
    this.removedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fittedAt != null) {
      map['fitted_at'] = Variable<DateTime>(fittedAt);
    }
    if (!nullToAbsent || fittedOdometerKm != null) {
      map['fitted_odometer_km'] = Variable<double>(fittedOdometerKm);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    if (!nullToAbsent || recommendedFrontKpa != null) {
      map['recommended_front_kpa'] = Variable<double>(recommendedFrontKpa);
    }
    if (!nullToAbsent || recommendedRearKpa != null) {
      map['recommended_rear_kpa'] = Variable<double>(recommendedRearKpa);
    }
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    return map;
  }

  TyreSetsCompanion toCompanion(bool nullToAbsent) {
    return TyreSetsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      name: Value(name),
      fittedAt: fittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fittedAt),
      fittedOdometerKm: fittedOdometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(fittedOdometerKm),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      recommendedFrontKpa: recommendedFrontKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedFrontKpa),
      recommendedRearKpa: recommendedRearKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedRearKpa),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
    );
  }

  factory TyreSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TyreSet(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      name: serializer.fromJson<String>(json['name']),
      fittedAt: serializer.fromJson<DateTime?>(json['fittedAt']),
      fittedOdometerKm: serializer.fromJson<double?>(json['fittedOdometerKm']),
      size: serializer.fromJson<String?>(json['size']),
      cost: serializer.fromJson<double?>(json['cost']),
      recommendedFrontKpa: serializer.fromJson<double?>(
        json['recommendedFrontKpa'],
      ),
      recommendedRearKpa: serializer.fromJson<double?>(
        json['recommendedRearKpa'],
      ),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'name': serializer.toJson<String>(name),
      'fittedAt': serializer.toJson<DateTime?>(fittedAt),
      'fittedOdometerKm': serializer.toJson<double?>(fittedOdometerKm),
      'size': serializer.toJson<String?>(size),
      'cost': serializer.toJson<double?>(cost),
      'recommendedFrontKpa': serializer.toJson<double?>(recommendedFrontKpa),
      'recommendedRearKpa': serializer.toJson<double?>(recommendedRearKpa),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
    };
  }

  TyreSet copyWith({
    String? id,
    String? vehicleId,
    String? name,
    Value<DateTime?> fittedAt = const Value.absent(),
    Value<double?> fittedOdometerKm = const Value.absent(),
    Value<String?> size = const Value.absent(),
    Value<double?> cost = const Value.absent(),
    Value<double?> recommendedFrontKpa = const Value.absent(),
    Value<double?> recommendedRearKpa = const Value.absent(),
    Value<DateTime?> removedAt = const Value.absent(),
  }) => TyreSet(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    name: name ?? this.name,
    fittedAt: fittedAt.present ? fittedAt.value : this.fittedAt,
    fittedOdometerKm: fittedOdometerKm.present
        ? fittedOdometerKm.value
        : this.fittedOdometerKm,
    size: size.present ? size.value : this.size,
    cost: cost.present ? cost.value : this.cost,
    recommendedFrontKpa: recommendedFrontKpa.present
        ? recommendedFrontKpa.value
        : this.recommendedFrontKpa,
    recommendedRearKpa: recommendedRearKpa.present
        ? recommendedRearKpa.value
        : this.recommendedRearKpa,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
  );
  TyreSet copyWithCompanion(TyreSetsCompanion data) {
    return TyreSet(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      name: data.name.present ? data.name.value : this.name,
      fittedAt: data.fittedAt.present ? data.fittedAt.value : this.fittedAt,
      fittedOdometerKm: data.fittedOdometerKm.present
          ? data.fittedOdometerKm.value
          : this.fittedOdometerKm,
      size: data.size.present ? data.size.value : this.size,
      cost: data.cost.present ? data.cost.value : this.cost,
      recommendedFrontKpa: data.recommendedFrontKpa.present
          ? data.recommendedFrontKpa.value
          : this.recommendedFrontKpa,
      recommendedRearKpa: data.recommendedRearKpa.present
          ? data.recommendedRearKpa.value
          : this.recommendedRearKpa,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TyreSet(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('fittedAt: $fittedAt, ')
          ..write('fittedOdometerKm: $fittedOdometerKm, ')
          ..write('size: $size, ')
          ..write('cost: $cost, ')
          ..write('recommendedFrontKpa: $recommendedFrontKpa, ')
          ..write('recommendedRearKpa: $recommendedRearKpa, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    name,
    fittedAt,
    fittedOdometerKm,
    size,
    cost,
    recommendedFrontKpa,
    recommendedRearKpa,
    removedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TyreSet &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.name == this.name &&
          other.fittedAt == this.fittedAt &&
          other.fittedOdometerKm == this.fittedOdometerKm &&
          other.size == this.size &&
          other.cost == this.cost &&
          other.recommendedFrontKpa == this.recommendedFrontKpa &&
          other.recommendedRearKpa == this.recommendedRearKpa &&
          other.removedAt == this.removedAt);
}

class TyreSetsCompanion extends UpdateCompanion<TyreSet> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> name;
  final Value<DateTime?> fittedAt;
  final Value<double?> fittedOdometerKm;
  final Value<String?> size;
  final Value<double?> cost;
  final Value<double?> recommendedFrontKpa;
  final Value<double?> recommendedRearKpa;
  final Value<DateTime?> removedAt;
  final Value<int> rowid;
  const TyreSetsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.name = const Value.absent(),
    this.fittedAt = const Value.absent(),
    this.fittedOdometerKm = const Value.absent(),
    this.size = const Value.absent(),
    this.cost = const Value.absent(),
    this.recommendedFrontKpa = const Value.absent(),
    this.recommendedRearKpa = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TyreSetsCompanion.insert({
    required String id,
    required String vehicleId,
    required String name,
    this.fittedAt = const Value.absent(),
    this.fittedOdometerKm = const Value.absent(),
    this.size = const Value.absent(),
    this.cost = const Value.absent(),
    this.recommendedFrontKpa = const Value.absent(),
    this.recommendedRearKpa = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       name = Value(name);
  static Insertable<TyreSet> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? name,
    Expression<DateTime>? fittedAt,
    Expression<double>? fittedOdometerKm,
    Expression<String>? size,
    Expression<double>? cost,
    Expression<double>? recommendedFrontKpa,
    Expression<double>? recommendedRearKpa,
    Expression<DateTime>? removedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (name != null) 'name': name,
      if (fittedAt != null) 'fitted_at': fittedAt,
      if (fittedOdometerKm != null) 'fitted_odometer_km': fittedOdometerKm,
      if (size != null) 'size': size,
      if (cost != null) 'cost': cost,
      if (recommendedFrontKpa != null)
        'recommended_front_kpa': recommendedFrontKpa,
      if (recommendedRearKpa != null)
        'recommended_rear_kpa': recommendedRearKpa,
      if (removedAt != null) 'removed_at': removedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TyreSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? name,
    Value<DateTime?>? fittedAt,
    Value<double?>? fittedOdometerKm,
    Value<String?>? size,
    Value<double?>? cost,
    Value<double?>? recommendedFrontKpa,
    Value<double?>? recommendedRearKpa,
    Value<DateTime?>? removedAt,
    Value<int>? rowid,
  }) {
    return TyreSetsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      fittedAt: fittedAt ?? this.fittedAt,
      fittedOdometerKm: fittedOdometerKm ?? this.fittedOdometerKm,
      size: size ?? this.size,
      cost: cost ?? this.cost,
      recommendedFrontKpa: recommendedFrontKpa ?? this.recommendedFrontKpa,
      recommendedRearKpa: recommendedRearKpa ?? this.recommendedRearKpa,
      removedAt: removedAt ?? this.removedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fittedAt.present) {
      map['fitted_at'] = Variable<DateTime>(fittedAt.value);
    }
    if (fittedOdometerKm.present) {
      map['fitted_odometer_km'] = Variable<double>(fittedOdometerKm.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (recommendedFrontKpa.present) {
      map['recommended_front_kpa'] = Variable<double>(
        recommendedFrontKpa.value,
      );
    }
    if (recommendedRearKpa.present) {
      map['recommended_rear_kpa'] = Variable<double>(recommendedRearKpa.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TyreSetsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('fittedAt: $fittedAt, ')
          ..write('fittedOdometerKm: $fittedOdometerKm, ')
          ..write('size: $size, ')
          ..write('cost: $cost, ')
          ..write('recommendedFrontKpa: $recommendedFrontKpa, ')
          ..write('recommendedRearKpa: $recommendedRearKpa, ')
          ..write('removedAt: $removedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TyreChecksTable extends TyreChecks
    with TableInfo<$TyreChecksTable, TyreCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TyreChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _tyreSetIdMeta = const VerificationMeta(
    'tyreSetId',
  );
  @override
  late final GeneratedColumn<String> tyreSetId = GeneratedColumn<String>(
    'tyre_set_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundFlKpaMeta = const VerificationMeta(
    'foundFlKpa',
  );
  @override
  late final GeneratedColumn<double> foundFlKpa = GeneratedColumn<double>(
    'found_fl_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundFrKpaMeta = const VerificationMeta(
    'foundFrKpa',
  );
  @override
  late final GeneratedColumn<double> foundFrKpa = GeneratedColumn<double>(
    'found_fr_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundRlKpaMeta = const VerificationMeta(
    'foundRlKpa',
  );
  @override
  late final GeneratedColumn<double> foundRlKpa = GeneratedColumn<double>(
    'found_rl_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundRrKpaMeta = const VerificationMeta(
    'foundRrKpa',
  );
  @override
  late final GeneratedColumn<double> foundRrKpa = GeneratedColumn<double>(
    'found_rr_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundSpareKpaMeta = const VerificationMeta(
    'foundSpareKpa',
  );
  @override
  late final GeneratedColumn<double> foundSpareKpa = GeneratedColumn<double>(
    'found_spare_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftFlKpaMeta = const VerificationMeta(
    'leftFlKpa',
  );
  @override
  late final GeneratedColumn<double> leftFlKpa = GeneratedColumn<double>(
    'left_fl_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftFrKpaMeta = const VerificationMeta(
    'leftFrKpa',
  );
  @override
  late final GeneratedColumn<double> leftFrKpa = GeneratedColumn<double>(
    'left_fr_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftRlKpaMeta = const VerificationMeta(
    'leftRlKpa',
  );
  @override
  late final GeneratedColumn<double> leftRlKpa = GeneratedColumn<double>(
    'left_rl_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftRrKpaMeta = const VerificationMeta(
    'leftRrKpa',
  );
  @override
  late final GeneratedColumn<double> leftRrKpa = GeneratedColumn<double>(
    'left_rr_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftSpareKpaMeta = const VerificationMeta(
    'leftSpareKpa',
  );
  @override
  late final GeneratedColumn<double> leftSpareKpa = GeneratedColumn<double>(
    'left_spare_kpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airAddedMeta = const VerificationMeta(
    'airAdded',
  );
  @override
  late final GeneratedColumn<bool> airAdded = GeneratedColumn<bool>(
    'air_added',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("air_added" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    tyreSetId,
    at,
    odometerKm,
    foundFlKpa,
    foundFrKpa,
    foundRlKpa,
    foundRrKpa,
    foundSpareKpa,
    leftFlKpa,
    leftFrKpa,
    leftRlKpa,
    leftRrKpa,
    leftSpareKpa,
    airAdded,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tyre_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TyreCheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('tyre_set_id')) {
      context.handle(
        _tyreSetIdMeta,
        tyreSetId.isAcceptableOrUnknown(data['tyre_set_id']!, _tyreSetIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    }
    if (data.containsKey('found_fl_kpa')) {
      context.handle(
        _foundFlKpaMeta,
        foundFlKpa.isAcceptableOrUnknown(
          data['found_fl_kpa']!,
          _foundFlKpaMeta,
        ),
      );
    }
    if (data.containsKey('found_fr_kpa')) {
      context.handle(
        _foundFrKpaMeta,
        foundFrKpa.isAcceptableOrUnknown(
          data['found_fr_kpa']!,
          _foundFrKpaMeta,
        ),
      );
    }
    if (data.containsKey('found_rl_kpa')) {
      context.handle(
        _foundRlKpaMeta,
        foundRlKpa.isAcceptableOrUnknown(
          data['found_rl_kpa']!,
          _foundRlKpaMeta,
        ),
      );
    }
    if (data.containsKey('found_rr_kpa')) {
      context.handle(
        _foundRrKpaMeta,
        foundRrKpa.isAcceptableOrUnknown(
          data['found_rr_kpa']!,
          _foundRrKpaMeta,
        ),
      );
    }
    if (data.containsKey('found_spare_kpa')) {
      context.handle(
        _foundSpareKpaMeta,
        foundSpareKpa.isAcceptableOrUnknown(
          data['found_spare_kpa']!,
          _foundSpareKpaMeta,
        ),
      );
    }
    if (data.containsKey('left_fl_kpa')) {
      context.handle(
        _leftFlKpaMeta,
        leftFlKpa.isAcceptableOrUnknown(data['left_fl_kpa']!, _leftFlKpaMeta),
      );
    }
    if (data.containsKey('left_fr_kpa')) {
      context.handle(
        _leftFrKpaMeta,
        leftFrKpa.isAcceptableOrUnknown(data['left_fr_kpa']!, _leftFrKpaMeta),
      );
    }
    if (data.containsKey('left_rl_kpa')) {
      context.handle(
        _leftRlKpaMeta,
        leftRlKpa.isAcceptableOrUnknown(data['left_rl_kpa']!, _leftRlKpaMeta),
      );
    }
    if (data.containsKey('left_rr_kpa')) {
      context.handle(
        _leftRrKpaMeta,
        leftRrKpa.isAcceptableOrUnknown(data['left_rr_kpa']!, _leftRrKpaMeta),
      );
    }
    if (data.containsKey('left_spare_kpa')) {
      context.handle(
        _leftSpareKpaMeta,
        leftSpareKpa.isAcceptableOrUnknown(
          data['left_spare_kpa']!,
          _leftSpareKpaMeta,
        ),
      );
    }
    if (data.containsKey('air_added')) {
      context.handle(
        _airAddedMeta,
        airAdded.isAcceptableOrUnknown(data['air_added']!, _airAddedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TyreCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TyreCheck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      tyreSetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tyre_set_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      ),
      foundFlKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_fl_kpa'],
      ),
      foundFrKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_fr_kpa'],
      ),
      foundRlKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_rl_kpa'],
      ),
      foundRrKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_rr_kpa'],
      ),
      foundSpareKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_spare_kpa'],
      ),
      leftFlKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_fl_kpa'],
      ),
      leftFrKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_fr_kpa'],
      ),
      leftRlKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_rl_kpa'],
      ),
      leftRrKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_rr_kpa'],
      ),
      leftSpareKpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_spare_kpa'],
      ),
      airAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}air_added'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TyreChecksTable createAlias(String alias) {
    return $TyreChecksTable(attachedDatabase, alias);
  }
}

class TyreCheck extends DataClass implements Insertable<TyreCheck> {
  final String id;
  final String vehicleId;
  final String? tyreSetId;
  final DateTime at;
  final double? odometerKm;
  final double? foundFlKpa;
  final double? foundFrKpa;
  final double? foundRlKpa;
  final double? foundRrKpa;
  final double? foundSpareKpa;
  final double? leftFlKpa;
  final double? leftFrKpa;
  final double? leftRlKpa;
  final double? leftRrKpa;
  final double? leftSpareKpa;
  final bool airAdded;
  final String? notes;
  const TyreCheck({
    required this.id,
    required this.vehicleId,
    this.tyreSetId,
    required this.at,
    this.odometerKm,
    this.foundFlKpa,
    this.foundFrKpa,
    this.foundRlKpa,
    this.foundRrKpa,
    this.foundSpareKpa,
    this.leftFlKpa,
    this.leftFrKpa,
    this.leftRlKpa,
    this.leftRrKpa,
    this.leftSpareKpa,
    required this.airAdded,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    if (!nullToAbsent || tyreSetId != null) {
      map['tyre_set_id'] = Variable<String>(tyreSetId);
    }
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || odometerKm != null) {
      map['odometer_km'] = Variable<double>(odometerKm);
    }
    if (!nullToAbsent || foundFlKpa != null) {
      map['found_fl_kpa'] = Variable<double>(foundFlKpa);
    }
    if (!nullToAbsent || foundFrKpa != null) {
      map['found_fr_kpa'] = Variable<double>(foundFrKpa);
    }
    if (!nullToAbsent || foundRlKpa != null) {
      map['found_rl_kpa'] = Variable<double>(foundRlKpa);
    }
    if (!nullToAbsent || foundRrKpa != null) {
      map['found_rr_kpa'] = Variable<double>(foundRrKpa);
    }
    if (!nullToAbsent || foundSpareKpa != null) {
      map['found_spare_kpa'] = Variable<double>(foundSpareKpa);
    }
    if (!nullToAbsent || leftFlKpa != null) {
      map['left_fl_kpa'] = Variable<double>(leftFlKpa);
    }
    if (!nullToAbsent || leftFrKpa != null) {
      map['left_fr_kpa'] = Variable<double>(leftFrKpa);
    }
    if (!nullToAbsent || leftRlKpa != null) {
      map['left_rl_kpa'] = Variable<double>(leftRlKpa);
    }
    if (!nullToAbsent || leftRrKpa != null) {
      map['left_rr_kpa'] = Variable<double>(leftRrKpa);
    }
    if (!nullToAbsent || leftSpareKpa != null) {
      map['left_spare_kpa'] = Variable<double>(leftSpareKpa);
    }
    map['air_added'] = Variable<bool>(airAdded);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TyreChecksCompanion toCompanion(bool nullToAbsent) {
    return TyreChecksCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      tyreSetId: tyreSetId == null && nullToAbsent
          ? const Value.absent()
          : Value(tyreSetId),
      at: Value(at),
      odometerKm: odometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerKm),
      foundFlKpa: foundFlKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(foundFlKpa),
      foundFrKpa: foundFrKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(foundFrKpa),
      foundRlKpa: foundRlKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(foundRlKpa),
      foundRrKpa: foundRrKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(foundRrKpa),
      foundSpareKpa: foundSpareKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(foundSpareKpa),
      leftFlKpa: leftFlKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(leftFlKpa),
      leftFrKpa: leftFrKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(leftFrKpa),
      leftRlKpa: leftRlKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(leftRlKpa),
      leftRrKpa: leftRrKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(leftRrKpa),
      leftSpareKpa: leftSpareKpa == null && nullToAbsent
          ? const Value.absent()
          : Value(leftSpareKpa),
      airAdded: Value(airAdded),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory TyreCheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TyreCheck(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      tyreSetId: serializer.fromJson<String?>(json['tyreSetId']),
      at: serializer.fromJson<DateTime>(json['at']),
      odometerKm: serializer.fromJson<double?>(json['odometerKm']),
      foundFlKpa: serializer.fromJson<double?>(json['foundFlKpa']),
      foundFrKpa: serializer.fromJson<double?>(json['foundFrKpa']),
      foundRlKpa: serializer.fromJson<double?>(json['foundRlKpa']),
      foundRrKpa: serializer.fromJson<double?>(json['foundRrKpa']),
      foundSpareKpa: serializer.fromJson<double?>(json['foundSpareKpa']),
      leftFlKpa: serializer.fromJson<double?>(json['leftFlKpa']),
      leftFrKpa: serializer.fromJson<double?>(json['leftFrKpa']),
      leftRlKpa: serializer.fromJson<double?>(json['leftRlKpa']),
      leftRrKpa: serializer.fromJson<double?>(json['leftRrKpa']),
      leftSpareKpa: serializer.fromJson<double?>(json['leftSpareKpa']),
      airAdded: serializer.fromJson<bool>(json['airAdded']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'tyreSetId': serializer.toJson<String?>(tyreSetId),
      'at': serializer.toJson<DateTime>(at),
      'odometerKm': serializer.toJson<double?>(odometerKm),
      'foundFlKpa': serializer.toJson<double?>(foundFlKpa),
      'foundFrKpa': serializer.toJson<double?>(foundFrKpa),
      'foundRlKpa': serializer.toJson<double?>(foundRlKpa),
      'foundRrKpa': serializer.toJson<double?>(foundRrKpa),
      'foundSpareKpa': serializer.toJson<double?>(foundSpareKpa),
      'leftFlKpa': serializer.toJson<double?>(leftFlKpa),
      'leftFrKpa': serializer.toJson<double?>(leftFrKpa),
      'leftRlKpa': serializer.toJson<double?>(leftRlKpa),
      'leftRrKpa': serializer.toJson<double?>(leftRrKpa),
      'leftSpareKpa': serializer.toJson<double?>(leftSpareKpa),
      'airAdded': serializer.toJson<bool>(airAdded),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  TyreCheck copyWith({
    String? id,
    String? vehicleId,
    Value<String?> tyreSetId = const Value.absent(),
    DateTime? at,
    Value<double?> odometerKm = const Value.absent(),
    Value<double?> foundFlKpa = const Value.absent(),
    Value<double?> foundFrKpa = const Value.absent(),
    Value<double?> foundRlKpa = const Value.absent(),
    Value<double?> foundRrKpa = const Value.absent(),
    Value<double?> foundSpareKpa = const Value.absent(),
    Value<double?> leftFlKpa = const Value.absent(),
    Value<double?> leftFrKpa = const Value.absent(),
    Value<double?> leftRlKpa = const Value.absent(),
    Value<double?> leftRrKpa = const Value.absent(),
    Value<double?> leftSpareKpa = const Value.absent(),
    bool? airAdded,
    Value<String?> notes = const Value.absent(),
  }) => TyreCheck(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    tyreSetId: tyreSetId.present ? tyreSetId.value : this.tyreSetId,
    at: at ?? this.at,
    odometerKm: odometerKm.present ? odometerKm.value : this.odometerKm,
    foundFlKpa: foundFlKpa.present ? foundFlKpa.value : this.foundFlKpa,
    foundFrKpa: foundFrKpa.present ? foundFrKpa.value : this.foundFrKpa,
    foundRlKpa: foundRlKpa.present ? foundRlKpa.value : this.foundRlKpa,
    foundRrKpa: foundRrKpa.present ? foundRrKpa.value : this.foundRrKpa,
    foundSpareKpa: foundSpareKpa.present
        ? foundSpareKpa.value
        : this.foundSpareKpa,
    leftFlKpa: leftFlKpa.present ? leftFlKpa.value : this.leftFlKpa,
    leftFrKpa: leftFrKpa.present ? leftFrKpa.value : this.leftFrKpa,
    leftRlKpa: leftRlKpa.present ? leftRlKpa.value : this.leftRlKpa,
    leftRrKpa: leftRrKpa.present ? leftRrKpa.value : this.leftRrKpa,
    leftSpareKpa: leftSpareKpa.present ? leftSpareKpa.value : this.leftSpareKpa,
    airAdded: airAdded ?? this.airAdded,
    notes: notes.present ? notes.value : this.notes,
  );
  TyreCheck copyWithCompanion(TyreChecksCompanion data) {
    return TyreCheck(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      tyreSetId: data.tyreSetId.present ? data.tyreSetId.value : this.tyreSetId,
      at: data.at.present ? data.at.value : this.at,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      foundFlKpa: data.foundFlKpa.present
          ? data.foundFlKpa.value
          : this.foundFlKpa,
      foundFrKpa: data.foundFrKpa.present
          ? data.foundFrKpa.value
          : this.foundFrKpa,
      foundRlKpa: data.foundRlKpa.present
          ? data.foundRlKpa.value
          : this.foundRlKpa,
      foundRrKpa: data.foundRrKpa.present
          ? data.foundRrKpa.value
          : this.foundRrKpa,
      foundSpareKpa: data.foundSpareKpa.present
          ? data.foundSpareKpa.value
          : this.foundSpareKpa,
      leftFlKpa: data.leftFlKpa.present ? data.leftFlKpa.value : this.leftFlKpa,
      leftFrKpa: data.leftFrKpa.present ? data.leftFrKpa.value : this.leftFrKpa,
      leftRlKpa: data.leftRlKpa.present ? data.leftRlKpa.value : this.leftRlKpa,
      leftRrKpa: data.leftRrKpa.present ? data.leftRrKpa.value : this.leftRrKpa,
      leftSpareKpa: data.leftSpareKpa.present
          ? data.leftSpareKpa.value
          : this.leftSpareKpa,
      airAdded: data.airAdded.present ? data.airAdded.value : this.airAdded,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TyreCheck(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('tyreSetId: $tyreSetId, ')
          ..write('at: $at, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('foundFlKpa: $foundFlKpa, ')
          ..write('foundFrKpa: $foundFrKpa, ')
          ..write('foundRlKpa: $foundRlKpa, ')
          ..write('foundRrKpa: $foundRrKpa, ')
          ..write('foundSpareKpa: $foundSpareKpa, ')
          ..write('leftFlKpa: $leftFlKpa, ')
          ..write('leftFrKpa: $leftFrKpa, ')
          ..write('leftRlKpa: $leftRlKpa, ')
          ..write('leftRrKpa: $leftRrKpa, ')
          ..write('leftSpareKpa: $leftSpareKpa, ')
          ..write('airAdded: $airAdded, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    tyreSetId,
    at,
    odometerKm,
    foundFlKpa,
    foundFrKpa,
    foundRlKpa,
    foundRrKpa,
    foundSpareKpa,
    leftFlKpa,
    leftFrKpa,
    leftRlKpa,
    leftRrKpa,
    leftSpareKpa,
    airAdded,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TyreCheck &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.tyreSetId == this.tyreSetId &&
          other.at == this.at &&
          other.odometerKm == this.odometerKm &&
          other.foundFlKpa == this.foundFlKpa &&
          other.foundFrKpa == this.foundFrKpa &&
          other.foundRlKpa == this.foundRlKpa &&
          other.foundRrKpa == this.foundRrKpa &&
          other.foundSpareKpa == this.foundSpareKpa &&
          other.leftFlKpa == this.leftFlKpa &&
          other.leftFrKpa == this.leftFrKpa &&
          other.leftRlKpa == this.leftRlKpa &&
          other.leftRrKpa == this.leftRrKpa &&
          other.leftSpareKpa == this.leftSpareKpa &&
          other.airAdded == this.airAdded &&
          other.notes == this.notes);
}

class TyreChecksCompanion extends UpdateCompanion<TyreCheck> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String?> tyreSetId;
  final Value<DateTime> at;
  final Value<double?> odometerKm;
  final Value<double?> foundFlKpa;
  final Value<double?> foundFrKpa;
  final Value<double?> foundRlKpa;
  final Value<double?> foundRrKpa;
  final Value<double?> foundSpareKpa;
  final Value<double?> leftFlKpa;
  final Value<double?> leftFrKpa;
  final Value<double?> leftRlKpa;
  final Value<double?> leftRrKpa;
  final Value<double?> leftSpareKpa;
  final Value<bool> airAdded;
  final Value<String?> notes;
  final Value<int> rowid;
  const TyreChecksCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.tyreSetId = const Value.absent(),
    this.at = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.foundFlKpa = const Value.absent(),
    this.foundFrKpa = const Value.absent(),
    this.foundRlKpa = const Value.absent(),
    this.foundRrKpa = const Value.absent(),
    this.foundSpareKpa = const Value.absent(),
    this.leftFlKpa = const Value.absent(),
    this.leftFrKpa = const Value.absent(),
    this.leftRlKpa = const Value.absent(),
    this.leftRrKpa = const Value.absent(),
    this.leftSpareKpa = const Value.absent(),
    this.airAdded = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TyreChecksCompanion.insert({
    required String id,
    required String vehicleId,
    this.tyreSetId = const Value.absent(),
    required DateTime at,
    this.odometerKm = const Value.absent(),
    this.foundFlKpa = const Value.absent(),
    this.foundFrKpa = const Value.absent(),
    this.foundRlKpa = const Value.absent(),
    this.foundRrKpa = const Value.absent(),
    this.foundSpareKpa = const Value.absent(),
    this.leftFlKpa = const Value.absent(),
    this.leftFrKpa = const Value.absent(),
    this.leftRlKpa = const Value.absent(),
    this.leftRrKpa = const Value.absent(),
    this.leftSpareKpa = const Value.absent(),
    this.airAdded = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       at = Value(at);
  static Insertable<TyreCheck> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? tyreSetId,
    Expression<DateTime>? at,
    Expression<double>? odometerKm,
    Expression<double>? foundFlKpa,
    Expression<double>? foundFrKpa,
    Expression<double>? foundRlKpa,
    Expression<double>? foundRrKpa,
    Expression<double>? foundSpareKpa,
    Expression<double>? leftFlKpa,
    Expression<double>? leftFrKpa,
    Expression<double>? leftRlKpa,
    Expression<double>? leftRrKpa,
    Expression<double>? leftSpareKpa,
    Expression<bool>? airAdded,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (tyreSetId != null) 'tyre_set_id': tyreSetId,
      if (at != null) 'at': at,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (foundFlKpa != null) 'found_fl_kpa': foundFlKpa,
      if (foundFrKpa != null) 'found_fr_kpa': foundFrKpa,
      if (foundRlKpa != null) 'found_rl_kpa': foundRlKpa,
      if (foundRrKpa != null) 'found_rr_kpa': foundRrKpa,
      if (foundSpareKpa != null) 'found_spare_kpa': foundSpareKpa,
      if (leftFlKpa != null) 'left_fl_kpa': leftFlKpa,
      if (leftFrKpa != null) 'left_fr_kpa': leftFrKpa,
      if (leftRlKpa != null) 'left_rl_kpa': leftRlKpa,
      if (leftRrKpa != null) 'left_rr_kpa': leftRrKpa,
      if (leftSpareKpa != null) 'left_spare_kpa': leftSpareKpa,
      if (airAdded != null) 'air_added': airAdded,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TyreChecksCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String?>? tyreSetId,
    Value<DateTime>? at,
    Value<double?>? odometerKm,
    Value<double?>? foundFlKpa,
    Value<double?>? foundFrKpa,
    Value<double?>? foundRlKpa,
    Value<double?>? foundRrKpa,
    Value<double?>? foundSpareKpa,
    Value<double?>? leftFlKpa,
    Value<double?>? leftFrKpa,
    Value<double?>? leftRlKpa,
    Value<double?>? leftRrKpa,
    Value<double?>? leftSpareKpa,
    Value<bool>? airAdded,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return TyreChecksCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      tyreSetId: tyreSetId ?? this.tyreSetId,
      at: at ?? this.at,
      odometerKm: odometerKm ?? this.odometerKm,
      foundFlKpa: foundFlKpa ?? this.foundFlKpa,
      foundFrKpa: foundFrKpa ?? this.foundFrKpa,
      foundRlKpa: foundRlKpa ?? this.foundRlKpa,
      foundRrKpa: foundRrKpa ?? this.foundRrKpa,
      foundSpareKpa: foundSpareKpa ?? this.foundSpareKpa,
      leftFlKpa: leftFlKpa ?? this.leftFlKpa,
      leftFrKpa: leftFrKpa ?? this.leftFrKpa,
      leftRlKpa: leftRlKpa ?? this.leftRlKpa,
      leftRrKpa: leftRrKpa ?? this.leftRrKpa,
      leftSpareKpa: leftSpareKpa ?? this.leftSpareKpa,
      airAdded: airAdded ?? this.airAdded,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (tyreSetId.present) {
      map['tyre_set_id'] = Variable<String>(tyreSetId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (foundFlKpa.present) {
      map['found_fl_kpa'] = Variable<double>(foundFlKpa.value);
    }
    if (foundFrKpa.present) {
      map['found_fr_kpa'] = Variable<double>(foundFrKpa.value);
    }
    if (foundRlKpa.present) {
      map['found_rl_kpa'] = Variable<double>(foundRlKpa.value);
    }
    if (foundRrKpa.present) {
      map['found_rr_kpa'] = Variable<double>(foundRrKpa.value);
    }
    if (foundSpareKpa.present) {
      map['found_spare_kpa'] = Variable<double>(foundSpareKpa.value);
    }
    if (leftFlKpa.present) {
      map['left_fl_kpa'] = Variable<double>(leftFlKpa.value);
    }
    if (leftFrKpa.present) {
      map['left_fr_kpa'] = Variable<double>(leftFrKpa.value);
    }
    if (leftRlKpa.present) {
      map['left_rl_kpa'] = Variable<double>(leftRlKpa.value);
    }
    if (leftRrKpa.present) {
      map['left_rr_kpa'] = Variable<double>(leftRrKpa.value);
    }
    if (leftSpareKpa.present) {
      map['left_spare_kpa'] = Variable<double>(leftSpareKpa.value);
    }
    if (airAdded.present) {
      map['air_added'] = Variable<bool>(airAdded.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TyreChecksCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('tyreSetId: $tyreSetId, ')
          ..write('at: $at, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('foundFlKpa: $foundFlKpa, ')
          ..write('foundFrKpa: $foundFrKpa, ')
          ..write('foundRlKpa: $foundRlKpa, ')
          ..write('foundRrKpa: $foundRrKpa, ')
          ..write('foundSpareKpa: $foundSpareKpa, ')
          ..write('leftFlKpa: $leftFlKpa, ')
          ..write('leftFrKpa: $leftFrKpa, ')
          ..write('leftRlKpa: $leftRlKpa, ')
          ..write('leftRrKpa: $leftRrKpa, ')
          ..write('leftSpareKpa: $leftSpareKpa, ')
          ..write('airAdded: $airAdded, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    targetTable,
    rowId,
    action,
    attempts,
    lastError,
    queuedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  SyncItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncItem(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}queued_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncItem extends DataClass implements Insertable<SyncItem> {
  final int seq;
  final String targetTable;
  final String rowId;

  /// 'upsert' or 'delete'
  final String action;
  final int attempts;
  final String? lastError;
  final DateTime queuedAt;
  const SyncItem({
    required this.seq,
    required this.targetTable,
    required this.rowId,
    required this.action,
    required this.attempts,
    this.lastError,
    required this.queuedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['target_table'] = Variable<String>(targetTable);
    map['row_id'] = Variable<String>(rowId);
    map['action'] = Variable<String>(action);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['queued_at'] = Variable<DateTime>(queuedAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      seq: Value(seq),
      targetTable: Value(targetTable),
      rowId: Value(rowId),
      action: Value(action),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      queuedAt: Value(queuedAt),
    );
  }

  factory SyncItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncItem(
      seq: serializer.fromJson<int>(json['seq']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      action: serializer.fromJson<String>(json['action']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'targetTable': serializer.toJson<String>(targetTable),
      'rowId': serializer.toJson<String>(rowId),
      'action': serializer.toJson<String>(action),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
    };
  }

  SyncItem copyWith({
    int? seq,
    String? targetTable,
    String? rowId,
    String? action,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    DateTime? queuedAt,
  }) => SyncItem(
    seq: seq ?? this.seq,
    targetTable: targetTable ?? this.targetTable,
    rowId: rowId ?? this.rowId,
    action: action ?? this.action,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    queuedAt: queuedAt ?? this.queuedAt,
  );
  SyncItem copyWithCompanion(SyncQueueCompanion data) {
    return SyncItem(
      seq: data.seq.present ? data.seq.value : this.seq,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      action: data.action.present ? data.action.value : this.action,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncItem(')
          ..write('seq: $seq, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('action: $action, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('queuedAt: $queuedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    targetTable,
    rowId,
    action,
    attempts,
    lastError,
    queuedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncItem &&
          other.seq == this.seq &&
          other.targetTable == this.targetTable &&
          other.rowId == this.rowId &&
          other.action == this.action &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.queuedAt == this.queuedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncItem> {
  final Value<int> seq;
  final Value<String> targetTable;
  final Value<String> rowId;
  final Value<String> action;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> queuedAt;
  const SyncQueueCompanion({
    this.seq = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.action = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.queuedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.seq = const Value.absent(),
    required String targetTable,
    required String rowId,
    required String action,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.queuedAt = const Value.absent(),
  }) : targetTable = Value(targetTable),
       rowId = Value(rowId),
       action = Value(action);
  static Insertable<SyncItem> custom({
    Expression<int>? seq,
    Expression<String>? targetTable,
    Expression<String>? rowId,
    Expression<String>? action,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? queuedAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (targetTable != null) 'target_table': targetTable,
      if (rowId != null) 'row_id': rowId,
      if (action != null) 'action': action,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (queuedAt != null) 'queued_at': queuedAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? seq,
    Value<String>? targetTable,
    Value<String>? rowId,
    Value<String>? action,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime>? queuedAt,
  }) {
    return SyncQueueCompanion(
      seq: seq ?? this.seq,
      targetTable: targetTable ?? this.targetTable,
      rowId: rowId ?? this.rowId,
      action: action ?? this.action,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('seq: $seq, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('action: $action, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('queuedAt: $queuedAt')
          ..write(')'))
        .toString();
  }
}

class $ServiceItemsTable extends ServiceItems
    with TableInfo<$ServiceItemsTable, ServiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('service'),
  );
  static const VerificationMeta _intervalMonthsMeta = const VerificationMeta(
    'intervalMonths',
  );
  @override
  late final GeneratedColumn<int> intervalMonths = GeneratedColumn<int>(
    'interval_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalKmMeta = const VerificationMeta(
    'intervalKm',
  );
  @override
  late final GeneratedColumn<int> intervalKm = GeneratedColumn<int>(
    'interval_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastDoneAtMeta = const VerificationMeta(
    'lastDoneAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDoneAt = GeneratedColumn<DateTime>(
    'last_done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastDoneKmMeta = const VerificationMeta(
    'lastDoneKm',
  );
  @override
  late final GeneratedColumn<double> lastDoneKm = GeneratedColumn<double>(
    'last_done_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    name,
    kind,
    intervalMonths,
    intervalKm,
    lastDoneAt,
    lastDoneKm,
    notes,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('interval_months')) {
      context.handle(
        _intervalMonthsMeta,
        intervalMonths.isAcceptableOrUnknown(
          data['interval_months']!,
          _intervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('interval_km')) {
      context.handle(
        _intervalKmMeta,
        intervalKm.isAcceptableOrUnknown(data['interval_km']!, _intervalKmMeta),
      );
    }
    if (data.containsKey('last_done_at')) {
      context.handle(
        _lastDoneAtMeta,
        lastDoneAt.isAcceptableOrUnknown(
          data['last_done_at']!,
          _lastDoneAtMeta,
        ),
      );
    }
    if (data.containsKey('last_done_km')) {
      context.handle(
        _lastDoneKmMeta,
        lastDoneKm.isAcceptableOrUnknown(
          data['last_done_km']!,
          _lastDoneKmMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      intervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_months'],
      ),
      intervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_km'],
      ),
      lastDoneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_done_at'],
      ),
      lastDoneKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_done_km'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ServiceItemsTable createAlias(String alias) {
    return $ServiceItemsTable(attachedDatabase, alias);
  }
}

class ServiceItem extends DataClass implements Insertable<ServiceItem> {
  final String id;
  final String vehicleId;
  final String name;

  /// Expense kind used when it's logged: 'service', 'wof', 'rego', 'tyres', 'other'
  final String kind;
  final int? intervalMonths;
  final int? intervalKm;
  final DateTime? lastDoneAt;
  final double? lastDoneKm;
  final String? notes;
  final bool active;
  final DateTime createdAt;
  const ServiceItem({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.kind,
    this.intervalMonths,
    this.intervalKm,
    this.lastDoneAt,
    this.lastDoneKm,
    this.notes,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || intervalMonths != null) {
      map['interval_months'] = Variable<int>(intervalMonths);
    }
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<int>(intervalKm);
    }
    if (!nullToAbsent || lastDoneAt != null) {
      map['last_done_at'] = Variable<DateTime>(lastDoneAt);
    }
    if (!nullToAbsent || lastDoneKm != null) {
      map['last_done_km'] = Variable<double>(lastDoneKm);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceItemsCompanion toCompanion(bool nullToAbsent) {
    return ServiceItemsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      name: Value(name),
      kind: Value(kind),
      intervalMonths: intervalMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMonths),
      intervalKm: intervalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalKm),
      lastDoneAt: lastDoneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDoneAt),
      lastDoneKm: lastDoneKm == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDoneKm),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceItem(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      intervalMonths: serializer.fromJson<int?>(json['intervalMonths']),
      intervalKm: serializer.fromJson<int?>(json['intervalKm']),
      lastDoneAt: serializer.fromJson<DateTime?>(json['lastDoneAt']),
      lastDoneKm: serializer.fromJson<double?>(json['lastDoneKm']),
      notes: serializer.fromJson<String?>(json['notes']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'intervalMonths': serializer.toJson<int?>(intervalMonths),
      'intervalKm': serializer.toJson<int?>(intervalKm),
      'lastDoneAt': serializer.toJson<DateTime?>(lastDoneAt),
      'lastDoneKm': serializer.toJson<double?>(lastDoneKm),
      'notes': serializer.toJson<String?>(notes),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceItem copyWith({
    String? id,
    String? vehicleId,
    String? name,
    String? kind,
    Value<int?> intervalMonths = const Value.absent(),
    Value<int?> intervalKm = const Value.absent(),
    Value<DateTime?> lastDoneAt = const Value.absent(),
    Value<double?> lastDoneKm = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? active,
    DateTime? createdAt,
  }) => ServiceItem(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    intervalMonths: intervalMonths.present
        ? intervalMonths.value
        : this.intervalMonths,
    intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
    lastDoneAt: lastDoneAt.present ? lastDoneAt.value : this.lastDoneAt,
    lastDoneKm: lastDoneKm.present ? lastDoneKm.value : this.lastDoneKm,
    notes: notes.present ? notes.value : this.notes,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  ServiceItem copyWithCompanion(ServiceItemsCompanion data) {
    return ServiceItem(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      intervalMonths: data.intervalMonths.present
          ? data.intervalMonths.value
          : this.intervalMonths,
      intervalKm: data.intervalKm.present
          ? data.intervalKm.value
          : this.intervalKm,
      lastDoneAt: data.lastDoneAt.present
          ? data.lastDoneAt.value
          : this.lastDoneAt,
      lastDoneKm: data.lastDoneKm.present
          ? data.lastDoneKm.value
          : this.lastDoneKm,
      notes: data.notes.present ? data.notes.value : this.notes,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItem(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('lastDoneAt: $lastDoneAt, ')
          ..write('lastDoneKm: $lastDoneKm, ')
          ..write('notes: $notes, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    name,
    kind,
    intervalMonths,
    intervalKm,
    lastDoneAt,
    lastDoneKm,
    notes,
    active,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceItem &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.intervalMonths == this.intervalMonths &&
          other.intervalKm == this.intervalKm &&
          other.lastDoneAt == this.lastDoneAt &&
          other.lastDoneKm == this.lastDoneKm &&
          other.notes == this.notes &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class ServiceItemsCompanion extends UpdateCompanion<ServiceItem> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> name;
  final Value<String> kind;
  final Value<int?> intervalMonths;
  final Value<int?> intervalKm;
  final Value<DateTime?> lastDoneAt;
  final Value<double?> lastDoneKm;
  final Value<String?> notes;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ServiceItemsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.lastDoneAt = const Value.absent(),
    this.lastDoneKm = const Value.absent(),
    this.notes = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceItemsCompanion.insert({
    required String id,
    required String vehicleId,
    required String name,
    this.kind = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.lastDoneAt = const Value.absent(),
    this.lastDoneKm = const Value.absent(),
    this.notes = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       name = Value(name);
  static Insertable<ServiceItem> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? intervalMonths,
    Expression<int>? intervalKm,
    Expression<DateTime>? lastDoneAt,
    Expression<double>? lastDoneKm,
    Expression<String>? notes,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (intervalMonths != null) 'interval_months': intervalMonths,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (lastDoneAt != null) 'last_done_at': lastDoneAt,
      if (lastDoneKm != null) 'last_done_km': lastDoneKm,
      if (notes != null) 'notes': notes,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? name,
    Value<String>? kind,
    Value<int?>? intervalMonths,
    Value<int?>? intervalKm,
    Value<DateTime?>? lastDoneAt,
    Value<double?>? lastDoneKm,
    Value<String?>? notes,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ServiceItemsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      intervalKm: intervalKm ?? this.intervalKm,
      lastDoneAt: lastDoneAt ?? this.lastDoneAt,
      lastDoneKm: lastDoneKm ?? this.lastDoneKm,
      notes: notes ?? this.notes,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (intervalMonths.present) {
      map['interval_months'] = Variable<int>(intervalMonths.value);
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<int>(intervalKm.value);
    }
    if (lastDoneAt.present) {
      map['last_done_at'] = Variable<DateTime>(lastDoneAt.value);
    }
    if (lastDoneKm.present) {
      map['last_done_km'] = Variable<double>(lastDoneKm.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('lastDoneAt: $lastDoneAt, ')
          ..write('lastDoneKm: $lastDoneKm, ')
          ..write('notes: $notes, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsurancePoliciesTable extends InsurancePolicies
    with TableInfo<$InsurancePoliciesTable, InsurancePolicy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsurancePoliciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _insurerMeta = const VerificationMeta(
    'insurer',
  );
  @override
  late final GeneratedColumn<String> insurer = GeneratedColumn<String>(
    'insurer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('comprehensive'),
  );
  static const VerificationMeta _policyNumberMeta = const VerificationMeta(
    'policyNumber',
  );
  @override
  late final GeneratedColumn<String> policyNumber = GeneratedColumn<String>(
    'policy_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insuredValueMeta = const VerificationMeta(
    'insuredValue',
  );
  @override
  late final GeneratedColumn<double> insuredValue = GeneratedColumn<double>(
    'insured_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _premiumMeta = const VerificationMeta(
    'premium',
  );
  @override
  late final GeneratedColumn<double> premium = GeneratedColumn<double>(
    'premium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _premiumPeriodMeta = const VerificationMeta(
    'premiumPeriod',
  );
  @override
  late final GeneratedColumn<String> premiumPeriod = GeneratedColumn<String>(
    'premium_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('year'),
  );
  static const VerificationMeta _excessMeta = const VerificationMeta('excess');
  @override
  late final GeneratedColumn<double> excess = GeneratedColumn<double>(
    'excess',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _renewAtMeta = const VerificationMeta(
    'renewAt',
  );
  @override
  late final GeneratedColumn<DateTime> renewAt = GeneratedColumn<DateTime>(
    'renew_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    insurer,
    cover,
    policyNumber,
    insuredValue,
    valueType,
    premium,
    premiumPeriod,
    excess,
    startAt,
    renewAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_policies';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsurancePolicy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('insurer')) {
      context.handle(
        _insurerMeta,
        insurer.isAcceptableOrUnknown(data['insurer']!, _insurerMeta),
      );
    } else if (isInserting) {
      context.missing(_insurerMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('policy_number')) {
      context.handle(
        _policyNumberMeta,
        policyNumber.isAcceptableOrUnknown(
          data['policy_number']!,
          _policyNumberMeta,
        ),
      );
    }
    if (data.containsKey('insured_value')) {
      context.handle(
        _insuredValueMeta,
        insuredValue.isAcceptableOrUnknown(
          data['insured_value']!,
          _insuredValueMeta,
        ),
      );
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    }
    if (data.containsKey('premium')) {
      context.handle(
        _premiumMeta,
        premium.isAcceptableOrUnknown(data['premium']!, _premiumMeta),
      );
    }
    if (data.containsKey('premium_period')) {
      context.handle(
        _premiumPeriodMeta,
        premiumPeriod.isAcceptableOrUnknown(
          data['premium_period']!,
          _premiumPeriodMeta,
        ),
      );
    }
    if (data.containsKey('excess')) {
      context.handle(
        _excessMeta,
        excess.isAcceptableOrUnknown(data['excess']!, _excessMeta),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('renew_at')) {
      context.handle(
        _renewAtMeta,
        renewAt.isAcceptableOrUnknown(data['renew_at']!, _renewAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InsurancePolicy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsurancePolicy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      insurer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurer'],
      )!,
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      )!,
      policyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_number'],
      ),
      insuredValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}insured_value'],
      ),
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      ),
      premium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}premium'],
      ),
      premiumPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}premium_period'],
      )!,
      excess: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}excess'],
      ),
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      renewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}renew_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $InsurancePoliciesTable createAlias(String alias) {
    return $InsurancePoliciesTable(attachedDatabase, alias);
  }
}

class InsurancePolicy extends DataClass implements Insertable<InsurancePolicy> {
  final String id;
  final String vehicleId;
  final String insurer;

  /// 'comprehensive', 'third_party_fire_theft', 'third_party'
  final String cover;

  /// Stays on the phone; never synced to Sheets.
  final String? policyNumber;
  final double? insuredValue;

  /// 'agreed' or 'market'
  final String? valueType;
  final double? premium;

  /// 'year' or 'month'
  final String premiumPeriod;
  final double? excess;
  final DateTime startAt;
  final DateTime? renewAt;
  final String? notes;
  const InsurancePolicy({
    required this.id,
    required this.vehicleId,
    required this.insurer,
    required this.cover,
    this.policyNumber,
    this.insuredValue,
    this.valueType,
    this.premium,
    required this.premiumPeriod,
    this.excess,
    required this.startAt,
    this.renewAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['insurer'] = Variable<String>(insurer);
    map['cover'] = Variable<String>(cover);
    if (!nullToAbsent || policyNumber != null) {
      map['policy_number'] = Variable<String>(policyNumber);
    }
    if (!nullToAbsent || insuredValue != null) {
      map['insured_value'] = Variable<double>(insuredValue);
    }
    if (!nullToAbsent || valueType != null) {
      map['value_type'] = Variable<String>(valueType);
    }
    if (!nullToAbsent || premium != null) {
      map['premium'] = Variable<double>(premium);
    }
    map['premium_period'] = Variable<String>(premiumPeriod);
    if (!nullToAbsent || excess != null) {
      map['excess'] = Variable<double>(excess);
    }
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || renewAt != null) {
      map['renew_at'] = Variable<DateTime>(renewAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InsurancePoliciesCompanion toCompanion(bool nullToAbsent) {
    return InsurancePoliciesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      insurer: Value(insurer),
      cover: Value(cover),
      policyNumber: policyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(policyNumber),
      insuredValue: insuredValue == null && nullToAbsent
          ? const Value.absent()
          : Value(insuredValue),
      valueType: valueType == null && nullToAbsent
          ? const Value.absent()
          : Value(valueType),
      premium: premium == null && nullToAbsent
          ? const Value.absent()
          : Value(premium),
      premiumPeriod: Value(premiumPeriod),
      excess: excess == null && nullToAbsent
          ? const Value.absent()
          : Value(excess),
      startAt: Value(startAt),
      renewAt: renewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(renewAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory InsurancePolicy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsurancePolicy(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      insurer: serializer.fromJson<String>(json['insurer']),
      cover: serializer.fromJson<String>(json['cover']),
      policyNumber: serializer.fromJson<String?>(json['policyNumber']),
      insuredValue: serializer.fromJson<double?>(json['insuredValue']),
      valueType: serializer.fromJson<String?>(json['valueType']),
      premium: serializer.fromJson<double?>(json['premium']),
      premiumPeriod: serializer.fromJson<String>(json['premiumPeriod']),
      excess: serializer.fromJson<double?>(json['excess']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      renewAt: serializer.fromJson<DateTime?>(json['renewAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'insurer': serializer.toJson<String>(insurer),
      'cover': serializer.toJson<String>(cover),
      'policyNumber': serializer.toJson<String?>(policyNumber),
      'insuredValue': serializer.toJson<double?>(insuredValue),
      'valueType': serializer.toJson<String?>(valueType),
      'premium': serializer.toJson<double?>(premium),
      'premiumPeriod': serializer.toJson<String>(premiumPeriod),
      'excess': serializer.toJson<double?>(excess),
      'startAt': serializer.toJson<DateTime>(startAt),
      'renewAt': serializer.toJson<DateTime?>(renewAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InsurancePolicy copyWith({
    String? id,
    String? vehicleId,
    String? insurer,
    String? cover,
    Value<String?> policyNumber = const Value.absent(),
    Value<double?> insuredValue = const Value.absent(),
    Value<String?> valueType = const Value.absent(),
    Value<double?> premium = const Value.absent(),
    String? premiumPeriod,
    Value<double?> excess = const Value.absent(),
    DateTime? startAt,
    Value<DateTime?> renewAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => InsurancePolicy(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    insurer: insurer ?? this.insurer,
    cover: cover ?? this.cover,
    policyNumber: policyNumber.present ? policyNumber.value : this.policyNumber,
    insuredValue: insuredValue.present ? insuredValue.value : this.insuredValue,
    valueType: valueType.present ? valueType.value : this.valueType,
    premium: premium.present ? premium.value : this.premium,
    premiumPeriod: premiumPeriod ?? this.premiumPeriod,
    excess: excess.present ? excess.value : this.excess,
    startAt: startAt ?? this.startAt,
    renewAt: renewAt.present ? renewAt.value : this.renewAt,
    notes: notes.present ? notes.value : this.notes,
  );
  InsurancePolicy copyWithCompanion(InsurancePoliciesCompanion data) {
    return InsurancePolicy(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      insurer: data.insurer.present ? data.insurer.value : this.insurer,
      cover: data.cover.present ? data.cover.value : this.cover,
      policyNumber: data.policyNumber.present
          ? data.policyNumber.value
          : this.policyNumber,
      insuredValue: data.insuredValue.present
          ? data.insuredValue.value
          : this.insuredValue,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      premium: data.premium.present ? data.premium.value : this.premium,
      premiumPeriod: data.premiumPeriod.present
          ? data.premiumPeriod.value
          : this.premiumPeriod,
      excess: data.excess.present ? data.excess.value : this.excess,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      renewAt: data.renewAt.present ? data.renewAt.value : this.renewAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsurancePolicy(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('insurer: $insurer, ')
          ..write('cover: $cover, ')
          ..write('policyNumber: $policyNumber, ')
          ..write('insuredValue: $insuredValue, ')
          ..write('valueType: $valueType, ')
          ..write('premium: $premium, ')
          ..write('premiumPeriod: $premiumPeriod, ')
          ..write('excess: $excess, ')
          ..write('startAt: $startAt, ')
          ..write('renewAt: $renewAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    insurer,
    cover,
    policyNumber,
    insuredValue,
    valueType,
    premium,
    premiumPeriod,
    excess,
    startAt,
    renewAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsurancePolicy &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.insurer == this.insurer &&
          other.cover == this.cover &&
          other.policyNumber == this.policyNumber &&
          other.insuredValue == this.insuredValue &&
          other.valueType == this.valueType &&
          other.premium == this.premium &&
          other.premiumPeriod == this.premiumPeriod &&
          other.excess == this.excess &&
          other.startAt == this.startAt &&
          other.renewAt == this.renewAt &&
          other.notes == this.notes);
}

class InsurancePoliciesCompanion extends UpdateCompanion<InsurancePolicy> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> insurer;
  final Value<String> cover;
  final Value<String?> policyNumber;
  final Value<double?> insuredValue;
  final Value<String?> valueType;
  final Value<double?> premium;
  final Value<String> premiumPeriod;
  final Value<double?> excess;
  final Value<DateTime> startAt;
  final Value<DateTime?> renewAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const InsurancePoliciesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.insurer = const Value.absent(),
    this.cover = const Value.absent(),
    this.policyNumber = const Value.absent(),
    this.insuredValue = const Value.absent(),
    this.valueType = const Value.absent(),
    this.premium = const Value.absent(),
    this.premiumPeriod = const Value.absent(),
    this.excess = const Value.absent(),
    this.startAt = const Value.absent(),
    this.renewAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsurancePoliciesCompanion.insert({
    required String id,
    required String vehicleId,
    required String insurer,
    this.cover = const Value.absent(),
    this.policyNumber = const Value.absent(),
    this.insuredValue = const Value.absent(),
    this.valueType = const Value.absent(),
    this.premium = const Value.absent(),
    this.premiumPeriod = const Value.absent(),
    this.excess = const Value.absent(),
    required DateTime startAt,
    this.renewAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       insurer = Value(insurer),
       startAt = Value(startAt);
  static Insertable<InsurancePolicy> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? insurer,
    Expression<String>? cover,
    Expression<String>? policyNumber,
    Expression<double>? insuredValue,
    Expression<String>? valueType,
    Expression<double>? premium,
    Expression<String>? premiumPeriod,
    Expression<double>? excess,
    Expression<DateTime>? startAt,
    Expression<DateTime>? renewAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (insurer != null) 'insurer': insurer,
      if (cover != null) 'cover': cover,
      if (policyNumber != null) 'policy_number': policyNumber,
      if (insuredValue != null) 'insured_value': insuredValue,
      if (valueType != null) 'value_type': valueType,
      if (premium != null) 'premium': premium,
      if (premiumPeriod != null) 'premium_period': premiumPeriod,
      if (excess != null) 'excess': excess,
      if (startAt != null) 'start_at': startAt,
      if (renewAt != null) 'renew_at': renewAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsurancePoliciesCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? insurer,
    Value<String>? cover,
    Value<String?>? policyNumber,
    Value<double?>? insuredValue,
    Value<String?>? valueType,
    Value<double?>? premium,
    Value<String>? premiumPeriod,
    Value<double?>? excess,
    Value<DateTime>? startAt,
    Value<DateTime?>? renewAt,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return InsurancePoliciesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      insurer: insurer ?? this.insurer,
      cover: cover ?? this.cover,
      policyNumber: policyNumber ?? this.policyNumber,
      insuredValue: insuredValue ?? this.insuredValue,
      valueType: valueType ?? this.valueType,
      premium: premium ?? this.premium,
      premiumPeriod: premiumPeriod ?? this.premiumPeriod,
      excess: excess ?? this.excess,
      startAt: startAt ?? this.startAt,
      renewAt: renewAt ?? this.renewAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (insurer.present) {
      map['insurer'] = Variable<String>(insurer.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (policyNumber.present) {
      map['policy_number'] = Variable<String>(policyNumber.value);
    }
    if (insuredValue.present) {
      map['insured_value'] = Variable<double>(insuredValue.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (premium.present) {
      map['premium'] = Variable<double>(premium.value);
    }
    if (premiumPeriod.present) {
      map['premium_period'] = Variable<String>(premiumPeriod.value);
    }
    if (excess.present) {
      map['excess'] = Variable<double>(excess.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (renewAt.present) {
      map['renew_at'] = Variable<DateTime>(renewAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsurancePoliciesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('insurer: $insurer, ')
          ..write('cover: $cover, ')
          ..write('policyNumber: $policyNumber, ')
          ..write('insuredValue: $insuredValue, ')
          ..write('valueType: $valueType, ')
          ..write('premium: $premium, ')
          ..write('premiumPeriod: $premiumPeriod, ')
          ..write('excess: $excess, ')
          ..write('startAt: $startAt, ')
          ..write('renewAt: $renewAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FuelCreditsTable extends FuelCredits
    with TableInfo<$FuelCreditsTable, FuelCredit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelCreditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _litresMeta = const VerificationMeta('litres');
  @override
  late final GeneratedColumn<double> litres = GeneratedColumn<double>(
    'litres',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    at,
    fuelType,
    litres,
    cost,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_credits';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelCredit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    }
    if (data.containsKey('litres')) {
      context.handle(
        _litresMeta,
        litres.isAcceptableOrUnknown(data['litres']!, _litresMeta),
      );
    } else if (isInserting) {
      context.missing(_litresMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelCredit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelCredit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      ),
      litres: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}litres'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FuelCreditsTable createAlias(String alias) {
    return $FuelCreditsTable(attachedDatabase, alias);
  }
}

class FuelCredit extends DataClass implements Insertable<FuelCredit> {
  final String id;
  final DateTime at;

  /// '91', '95' or 'diesel'
  final String? fuelType;
  final double litres;
  final double cost;
  final String? notes;
  final DateTime createdAt;
  const FuelCredit({
    required this.id,
    required this.at,
    this.fuelType,
    required this.litres,
    required this.cost,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || fuelType != null) {
      map['fuel_type'] = Variable<String>(fuelType);
    }
    map['litres'] = Variable<double>(litres);
    map['cost'] = Variable<double>(cost);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FuelCreditsCompanion toCompanion(bool nullToAbsent) {
    return FuelCreditsCompanion(
      id: Value(id),
      at: Value(at),
      fuelType: fuelType == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelType),
      litres: Value(litres),
      cost: Value(cost),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory FuelCredit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelCredit(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      fuelType: serializer.fromJson<String?>(json['fuelType']),
      litres: serializer.fromJson<double>(json['litres']),
      cost: serializer.fromJson<double>(json['cost']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<DateTime>(at),
      'fuelType': serializer.toJson<String?>(fuelType),
      'litres': serializer.toJson<double>(litres),
      'cost': serializer.toJson<double>(cost),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FuelCredit copyWith({
    String? id,
    DateTime? at,
    Value<String?> fuelType = const Value.absent(),
    double? litres,
    double? cost,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => FuelCredit(
    id: id ?? this.id,
    at: at ?? this.at,
    fuelType: fuelType.present ? fuelType.value : this.fuelType,
    litres: litres ?? this.litres,
    cost: cost ?? this.cost,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  FuelCredit copyWithCompanion(FuelCreditsCompanion data) {
    return FuelCredit(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      litres: data.litres.present ? data.litres.value : this.litres,
      cost: data.cost.present ? data.cost.value : this.cost,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelCredit(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('fuelType: $fuelType, ')
          ..write('litres: $litres, ')
          ..write('cost: $cost, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, at, fuelType, litres, cost, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelCredit &&
          other.id == this.id &&
          other.at == this.at &&
          other.fuelType == this.fuelType &&
          other.litres == this.litres &&
          other.cost == this.cost &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class FuelCreditsCompanion extends UpdateCompanion<FuelCredit> {
  final Value<String> id;
  final Value<DateTime> at;
  final Value<String?> fuelType;
  final Value<double> litres;
  final Value<double> cost;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FuelCreditsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.litres = const Value.absent(),
    this.cost = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FuelCreditsCompanion.insert({
    required String id,
    required DateTime at,
    this.fuelType = const Value.absent(),
    required double litres,
    required double cost,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       litres = Value(litres),
       cost = Value(cost);
  static Insertable<FuelCredit> custom({
    Expression<String>? id,
    Expression<DateTime>? at,
    Expression<String>? fuelType,
    Expression<double>? litres,
    Expression<double>? cost,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (fuelType != null) 'fuel_type': fuelType,
      if (litres != null) 'litres': litres,
      if (cost != null) 'cost': cost,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FuelCreditsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? at,
    Value<String?>? fuelType,
    Value<double>? litres,
    Value<double>? cost,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FuelCreditsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      fuelType: fuelType ?? this.fuelType,
      litres: litres ?? this.litres,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (litres.present) {
      map['litres'] = Variable<double>(litres.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelCreditsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('fuelType: $fuelType, ')
          ..write('litres: $litres, ')
          ..write('cost: $cost, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $StationsTable stations = $StationsTable(this);
  late final $EnergyEventsTable energyEvents = $EnergyEventsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TripPointsTable tripPoints = $TripPointsTable(this);
  late final $TripStopsTable tripStops = $TripStopsTable(this);
  late final $TyreSetsTable tyreSets = $TyreSetsTable(this);
  late final $TyreChecksTable tyreChecks = $TyreChecksTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $ServiceItemsTable serviceItems = $ServiceItemsTable(this);
  late final $InsurancePoliciesTable insurancePolicies =
      $InsurancePoliciesTable(this);
  late final $FuelCreditsTable fuelCredits = $FuelCreditsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    attachments,
    stations,
    energyEvents,
    expenses,
    trips,
    tripPoints,
    tripStops,
    tyreSets,
    tyreChecks,
    syncQueue,
    serviceItems,
    insurancePolicies,
    fuelCredits,
  ];
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String id,
      required String name,
      Value<String> kind,
      Value<String?> make,
      Value<String?> model,
      Value<int?> year,
      Value<double?> tankSize,
      Value<double?> ratedEconomy,
      Value<int?> startOdometerKm,
      Value<DateTime?> purchaseDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String> ownership,
      Value<DateTime?> archivedAt,
      Value<String?> loanJson,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<String?> make,
      Value<String?> model,
      Value<int?> year,
      Value<double?> tankSize,
      Value<double?> ratedEconomy,
      Value<int?> startOdometerKm,
      Value<DateTime?> purchaseDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String> ownership,
      Value<DateTime?> archivedAt,
      Value<String?> loanJson,
      Value<int> rowid,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.attachments.vehicleId),
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EnergyEventsTable, List<EnergyEvent>>
  _energyEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.energyEvents,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.energyEvents.vehicleId),
  );

  $$EnergyEventsTableProcessedTableManager get energyEventsRefs {
    final manager = $$EnergyEventsTableTableManager(
      $_db,
      $_db.energyEvents,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_energyEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.expenses.vehicleId),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripsTable, List<Trip>> _tripsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trips,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.trips.vehicleId),
  );

  $$TripsTableProcessedTableManager get tripsRefs {
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TyreSetsTable, List<TyreSet>> _tyreSetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tyreSets,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.tyreSets.vehicleId),
  );

  $$TyreSetsTableProcessedTableManager get tyreSetsRefs {
    final manager = $$TyreSetsTableTableManager(
      $_db,
      $_db.tyreSets,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tyreSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TyreChecksTable, List<TyreCheck>>
  _tyreChecksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tyreChecks,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.tyreChecks.vehicleId),
  );

  $$TyreChecksTableProcessedTableManager get tyreChecksRefs {
    final manager = $$TyreChecksTableTableManager(
      $_db,
      $_db.tyreChecks,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tyreChecksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceItemsTable, List<ServiceItem>>
  _serviceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceItems,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.serviceItems.vehicleId),
  );

  $$ServiceItemsTableProcessedTableManager get serviceItemsRefs {
    final manager = $$ServiceItemsTableTableManager(
      $_db,
      $_db.serviceItems,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InsurancePoliciesTable, List<InsurancePolicy>>
  _insurancePoliciesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.insurancePolicies,
        aliasName: $_aliasNameGenerator(
          db.vehicles.id,
          db.insurancePolicies.vehicleId,
        ),
      );

  $$InsurancePoliciesTableProcessedTableManager get insurancePoliciesRefs {
    final manager = $$InsurancePoliciesTableTableManager(
      $_db,
      $_db.insurancePolicies,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _insurancePoliciesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tankSize => $composableBuilder(
    column: $table.tankSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratedEconomy => $composableBuilder(
    column: $table.ratedEconomy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOdometerKm => $composableBuilder(
    column: $table.startOdometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownership => $composableBuilder(
    column: $table.ownership,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanJson => $composableBuilder(
    column: $table.loanJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> energyEventsRefs(
    Expression<bool> Function($$EnergyEventsTableFilterComposer f) f,
  ) {
    final $$EnergyEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.energyEvents,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnergyEventsTableFilterComposer(
            $db: $db,
            $table: $db.energyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripsRefs(
    Expression<bool> Function($$TripsTableFilterComposer f) f,
  ) {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tyreSetsRefs(
    Expression<bool> Function($$TyreSetsTableFilterComposer f) f,
  ) {
    final $$TyreSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tyreSets,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TyreSetsTableFilterComposer(
            $db: $db,
            $table: $db.tyreSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tyreChecksRefs(
    Expression<bool> Function($$TyreChecksTableFilterComposer f) f,
  ) {
    final $$TyreChecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tyreChecks,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TyreChecksTableFilterComposer(
            $db: $db,
            $table: $db.tyreChecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceItemsRefs(
    Expression<bool> Function($$ServiceItemsTableFilterComposer f) f,
  ) {
    final $$ServiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> insurancePoliciesRefs(
    Expression<bool> Function($$InsurancePoliciesTableFilterComposer f) f,
  ) {
    final $$InsurancePoliciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insurancePolicies,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancePoliciesTableFilterComposer(
            $db: $db,
            $table: $db.insurancePolicies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tankSize => $composableBuilder(
    column: $table.tankSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratedEconomy => $composableBuilder(
    column: $table.ratedEconomy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOdometerKm => $composableBuilder(
    column: $table.startOdometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownership => $composableBuilder(
    column: $table.ownership,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanJson => $composableBuilder(
    column: $table.loanJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<double> get tankSize =>
      $composableBuilder(column: $table.tankSize, builder: (column) => column);

  GeneratedColumn<double> get ratedEconomy => $composableBuilder(
    column: $table.ratedEconomy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startOdometerKm => $composableBuilder(
    column: $table.startOdometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownership =>
      $composableBuilder(column: $table.ownership, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loanJson =>
      $composableBuilder(column: $table.loanJson, builder: (column) => column);

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> energyEventsRefs<T extends Object>(
    Expression<T> Function($$EnergyEventsTableAnnotationComposer a) f,
  ) {
    final $$EnergyEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.energyEvents,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnergyEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.energyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripsRefs<T extends Object>(
    Expression<T> Function($$TripsTableAnnotationComposer a) f,
  ) {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tyreSetsRefs<T extends Object>(
    Expression<T> Function($$TyreSetsTableAnnotationComposer a) f,
  ) {
    final $$TyreSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tyreSets,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TyreSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.tyreSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tyreChecksRefs<T extends Object>(
    Expression<T> Function($$TyreChecksTableAnnotationComposer a) f,
  ) {
    final $$TyreChecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tyreChecks,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TyreChecksTableAnnotationComposer(
            $db: $db,
            $table: $db.tyreChecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> serviceItemsRefs<T extends Object>(
    Expression<T> Function($$ServiceItemsTableAnnotationComposer a) f,
  ) {
    final $$ServiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> insurancePoliciesRefs<T extends Object>(
    Expression<T> Function($$InsurancePoliciesTableAnnotationComposer a) f,
  ) {
    final $$InsurancePoliciesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.insurancePolicies,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InsurancePoliciesTableAnnotationComposer(
                $db: $db,
                $table: $db.insurancePolicies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({
            bool attachmentsRefs,
            bool energyEventsRefs,
            bool expensesRefs,
            bool tripsRefs,
            bool tyreSetsRefs,
            bool tyreChecksRefs,
            bool serviceItemsRefs,
            bool insurancePoliciesRefs,
          })
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<double?> tankSize = const Value.absent(),
                Value<double?> ratedEconomy = const Value.absent(),
                Value<int?> startOdometerKm = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> ownership = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String?> loanJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                name: name,
                kind: kind,
                make: make,
                model: model,
                year: year,
                tankSize: tankSize,
                ratedEconomy: ratedEconomy,
                startOdometerKm: startOdometerKm,
                purchaseDate: purchaseDate,
                notes: notes,
                createdAt: createdAt,
                ownership: ownership,
                archivedAt: archivedAt,
                loanJson: loanJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> kind = const Value.absent(),
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<double?> tankSize = const Value.absent(),
                Value<double?> ratedEconomy = const Value.absent(),
                Value<int?> startOdometerKm = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> ownership = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String?> loanJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                make: make,
                model: model,
                year: year,
                tankSize: tankSize,
                ratedEconomy: ratedEconomy,
                startOdometerKm: startOdometerKm,
                purchaseDate: purchaseDate,
                notes: notes,
                createdAt: createdAt,
                ownership: ownership,
                archivedAt: archivedAt,
                loanJson: loanJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                attachmentsRefs = false,
                energyEventsRefs = false,
                expensesRefs = false,
                tripsRefs = false,
                tyreSetsRefs = false,
                tyreChecksRefs = false,
                serviceItemsRefs = false,
                insurancePoliciesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentsRefs) db.attachments,
                    if (energyEventsRefs) db.energyEvents,
                    if (expensesRefs) db.expenses,
                    if (tripsRefs) db.trips,
                    if (tyreSetsRefs) db.tyreSets,
                    if (tyreChecksRefs) db.tyreChecks,
                    if (serviceItemsRefs) db.serviceItems,
                    if (insurancePoliciesRefs) db.insurancePolicies,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          Attachment
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (energyEventsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          EnergyEvent
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._energyEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).energyEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          Trip
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._tripsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).tripsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tyreSetsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          TyreSet
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._tyreSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).tyreSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tyreChecksRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          TyreCheck
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._tyreChecksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).tyreChecksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceItemsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          ServiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._serviceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (insurancePoliciesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          InsurancePolicy
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._insurancePoliciesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).insurancePoliciesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({
        bool attachmentsRefs,
        bool energyEventsRefs,
        bool expensesRefs,
        bool tripsRefs,
        bool tyreSetsRefs,
        bool tyreChecksRefs,
        bool serviceItemsRefs,
        bool insurancePoliciesRefs,
      })
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String vehicleId,
      required String ownerKind,
      required String ownerId,
      Value<String> docType,
      Value<String?> title,
      required String fileName,
      required String mimeType,
      Value<int> sizeBytes,
      Value<DateTime?> docDate,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> ownerKind,
      Value<String> ownerId,
      Value<String> docType,
      Value<String?> title,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<DateTime?> docDate,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.attachments.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerKind => $composableBuilder(
    column: $table.ownerKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get docDate => $composableBuilder(
    column: $table.docDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerKind => $composableBuilder(
    column: $table.ownerKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get docDate => $composableBuilder(
    column: $table.docDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerKind =>
      $composableBuilder(column: $table.ownerKind, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get docDate =>
      $composableBuilder(column: $table.docDate, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> ownerKind = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> docType = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime?> docDate = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                vehicleId: vehicleId,
                ownerKind: ownerKind,
                ownerId: ownerId,
                docType: docType,
                title: title,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                docDate: docDate,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String ownerKind,
                required String ownerId,
                Value<String> docType = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required String fileName,
                required String mimeType,
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime?> docDate = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                ownerKind: ownerKind,
                ownerId: ownerId,
                docType: docType,
                title: title,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                docDate: docDate,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$StationsTableCreateCompanionBuilder =
    StationsCompanion Function({
      required String id,
      required String name,
      Value<String?> brand,
      Value<double?> lat,
      Value<double?> lon,
      Value<int> rowid,
    });
typedef $$StationsTableUpdateCompanionBuilder =
    StationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> brand,
      Value<double?> lat,
      Value<double?> lon,
      Value<int> rowid,
    });

final class $$StationsTableReferences
    extends BaseReferences<_$AppDatabase, $StationsTable, Station> {
  $$StationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EnergyEventsTable, List<EnergyEvent>>
  _energyEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.energyEvents,
    aliasName: $_aliasNameGenerator(db.stations.id, db.energyEvents.stationId),
  );

  $$EnergyEventsTableProcessedTableManager get energyEventsRefs {
    final manager = $$EnergyEventsTableTableManager(
      $_db,
      $_db.energyEvents,
    ).filter((f) => f.stationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_energyEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StationsTableFilterComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> energyEventsRefs(
    Expression<bool> Function($$EnergyEventsTableFilterComposer f) f,
  ) {
    final $$EnergyEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.energyEvents,
      getReferencedColumn: (t) => t.stationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnergyEventsTableFilterComposer(
            $db: $db,
            $table: $db.energyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  Expression<T> energyEventsRefs<T extends Object>(
    Expression<T> Function($$EnergyEventsTableAnnotationComposer a) f,
  ) {
    final $$EnergyEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.energyEvents,
      getReferencedColumn: (t) => t.stationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnergyEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.energyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StationsTable,
          Station,
          $$StationsTableFilterComposer,
          $$StationsTableOrderingComposer,
          $$StationsTableAnnotationComposer,
          $$StationsTableCreateCompanionBuilder,
          $$StationsTableUpdateCompanionBuilder,
          (Station, $$StationsTableReferences),
          Station,
          PrefetchHooks Function({bool energyEventsRefs})
        > {
  $$StationsTableTableManager(_$AppDatabase db, $StationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StationsCompanion(
                id: id,
                name: name,
                brand: brand,
                lat: lat,
                lon: lon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StationsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                lat: lat,
                lon: lon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({energyEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (energyEventsRefs) db.energyEvents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (energyEventsRefs)
                    await $_getPrefetchedData<
                      Station,
                      $StationsTable,
                      EnergyEvent
                    >(
                      currentTable: table,
                      referencedTable: $$StationsTableReferences
                          ._energyEventsRefsTable(db),
                      managerFromTypedResult: (p0) => $$StationsTableReferences(
                        db,
                        table,
                        p0,
                      ).energyEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stationId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StationsTable,
      Station,
      $$StationsTableFilterComposer,
      $$StationsTableOrderingComposer,
      $$StationsTableAnnotationComposer,
      $$StationsTableCreateCompanionBuilder,
      $$StationsTableUpdateCompanionBuilder,
      (Station, $$StationsTableReferences),
      Station,
      PrefetchHooks Function({bool energyEventsRefs})
    >;
typedef $$EnergyEventsTableCreateCompanionBuilder =
    EnergyEventsCompanion Function({
      required String id,
      required String vehicleId,
      Value<String> kind,
      required DateTime at,
      required double odometerKm,
      Value<double?> tripKm,
      required double quantity,
      required double cost,
      Value<bool> isFull,
      Value<String?> stationId,
      Value<String?> stationName,
      Value<String?> fuelType,
      Value<String?> chargerType,
      Value<double?> batteryPctStart,
      Value<double?> batteryPctEnd,
      Value<String?> paymentNote,
      Value<String?> notes,
      Value<double?> sharetankLitres,
      Value<double?> listCost,
      Value<double?> lat,
      Value<double?> lon,
      Value<String> source,
      Value<String?> sourceRef,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$EnergyEventsTableUpdateCompanionBuilder =
    EnergyEventsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> kind,
      Value<DateTime> at,
      Value<double> odometerKm,
      Value<double?> tripKm,
      Value<double> quantity,
      Value<double> cost,
      Value<bool> isFull,
      Value<String?> stationId,
      Value<String?> stationName,
      Value<String?> fuelType,
      Value<String?> chargerType,
      Value<double?> batteryPctStart,
      Value<double?> batteryPctEnd,
      Value<String?> paymentNote,
      Value<String?> notes,
      Value<double?> sharetankLitres,
      Value<double?> listCost,
      Value<double?> lat,
      Value<double?> lon,
      Value<String> source,
      Value<String?> sourceRef,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$EnergyEventsTableReferences
    extends BaseReferences<_$AppDatabase, $EnergyEventsTable, EnergyEvent> {
  $$EnergyEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.energyEvents.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StationsTable _stationIdTable(_$AppDatabase db) =>
      db.stations.createAlias(
        $_aliasNameGenerator(db.energyEvents.stationId, db.stations.id),
      );

  $$StationsTableProcessedTableManager? get stationId {
    final $_column = $_itemColumn<String>('station_id');
    if ($_column == null) return null;
    final manager = $$StationsTableTableManager(
      $_db,
      $_db.stations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnergyEventsTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyEventsTable> {
  $$EnergyEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tripKm => $composableBuilder(
    column: $table.tripKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFull => $composableBuilder(
    column: $table.isFull,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationName => $composableBuilder(
    column: $table.stationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chargerType => $composableBuilder(
    column: $table.chargerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batteryPctStart => $composableBuilder(
    column: $table.batteryPctStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batteryPctEnd => $composableBuilder(
    column: $table.batteryPctEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentNote => $composableBuilder(
    column: $table.paymentNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sharetankLitres => $composableBuilder(
    column: $table.sharetankLitres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get listCost => $composableBuilder(
    column: $table.listCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationsTableFilterComposer get stationId {
    final $$StationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableFilterComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnergyEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyEventsTable> {
  $$EnergyEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tripKm => $composableBuilder(
    column: $table.tripKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFull => $composableBuilder(
    column: $table.isFull,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationName => $composableBuilder(
    column: $table.stationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chargerType => $composableBuilder(
    column: $table.chargerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batteryPctStart => $composableBuilder(
    column: $table.batteryPctStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batteryPctEnd => $composableBuilder(
    column: $table.batteryPctEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentNote => $composableBuilder(
    column: $table.paymentNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sharetankLitres => $composableBuilder(
    column: $table.sharetankLitres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get listCost => $composableBuilder(
    column: $table.listCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationsTableOrderingComposer get stationId {
    final $$StationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableOrderingComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnergyEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyEventsTable> {
  $$EnergyEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tripKm =>
      $composableBuilder(column: $table.tripKm, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<bool> get isFull =>
      $composableBuilder(column: $table.isFull, builder: (column) => column);

  GeneratedColumn<String> get stationName => $composableBuilder(
    column: $table.stationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<String> get chargerType => $composableBuilder(
    column: $table.chargerType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get batteryPctStart => $composableBuilder(
    column: $table.batteryPctStart,
    builder: (column) => column,
  );

  GeneratedColumn<double> get batteryPctEnd => $composableBuilder(
    column: $table.batteryPctEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentNote => $composableBuilder(
    column: $table.paymentNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get sharetankLitres => $composableBuilder(
    column: $table.sharetankLitres,
    builder: (column) => column,
  );

  GeneratedColumn<double> get listCost =>
      $composableBuilder(column: $table.listCost, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationsTableAnnotationComposer get stationId {
    final $$StationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableAnnotationComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnergyEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnergyEventsTable,
          EnergyEvent,
          $$EnergyEventsTableFilterComposer,
          $$EnergyEventsTableOrderingComposer,
          $$EnergyEventsTableAnnotationComposer,
          $$EnergyEventsTableCreateCompanionBuilder,
          $$EnergyEventsTableUpdateCompanionBuilder,
          (EnergyEvent, $$EnergyEventsTableReferences),
          EnergyEvent,
          PrefetchHooks Function({bool vehicleId, bool stationId})
        > {
  $$EnergyEventsTableTableManager(_$AppDatabase db, $EnergyEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<double> odometerKm = const Value.absent(),
                Value<double?> tripKm = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<bool> isFull = const Value.absent(),
                Value<String?> stationId = const Value.absent(),
                Value<String?> stationName = const Value.absent(),
                Value<String?> fuelType = const Value.absent(),
                Value<String?> chargerType = const Value.absent(),
                Value<double?> batteryPctStart = const Value.absent(),
                Value<double?> batteryPctEnd = const Value.absent(),
                Value<String?> paymentNote = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> sharetankLitres = const Value.absent(),
                Value<double?> listCost = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnergyEventsCompanion(
                id: id,
                vehicleId: vehicleId,
                kind: kind,
                at: at,
                odometerKm: odometerKm,
                tripKm: tripKm,
                quantity: quantity,
                cost: cost,
                isFull: isFull,
                stationId: stationId,
                stationName: stationName,
                fuelType: fuelType,
                chargerType: chargerType,
                batteryPctStart: batteryPctStart,
                batteryPctEnd: batteryPctEnd,
                paymentNote: paymentNote,
                notes: notes,
                sharetankLitres: sharetankLitres,
                listCost: listCost,
                lat: lat,
                lon: lon,
                source: source,
                sourceRef: sourceRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                Value<String> kind = const Value.absent(),
                required DateTime at,
                required double odometerKm,
                Value<double?> tripKm = const Value.absent(),
                required double quantity,
                required double cost,
                Value<bool> isFull = const Value.absent(),
                Value<String?> stationId = const Value.absent(),
                Value<String?> stationName = const Value.absent(),
                Value<String?> fuelType = const Value.absent(),
                Value<String?> chargerType = const Value.absent(),
                Value<double?> batteryPctStart = const Value.absent(),
                Value<double?> batteryPctEnd = const Value.absent(),
                Value<String?> paymentNote = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> sharetankLitres = const Value.absent(),
                Value<double?> listCost = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnergyEventsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                kind: kind,
                at: at,
                odometerKm: odometerKm,
                tripKm: tripKm,
                quantity: quantity,
                cost: cost,
                isFull: isFull,
                stationId: stationId,
                stationName: stationName,
                fuelType: fuelType,
                chargerType: chargerType,
                batteryPctStart: batteryPctStart,
                batteryPctEnd: batteryPctEnd,
                paymentNote: paymentNote,
                notes: notes,
                sharetankLitres: sharetankLitres,
                listCost: listCost,
                lat: lat,
                lon: lon,
                source: source,
                sourceRef: sourceRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnergyEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false, stationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$EnergyEventsTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$EnergyEventsTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (stationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stationId,
                                referencedTable: $$EnergyEventsTableReferences
                                    ._stationIdTable(db),
                                referencedColumn: $$EnergyEventsTableReferences
                                    ._stationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EnergyEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnergyEventsTable,
      EnergyEvent,
      $$EnergyEventsTableFilterComposer,
      $$EnergyEventsTableOrderingComposer,
      $$EnergyEventsTableAnnotationComposer,
      $$EnergyEventsTableCreateCompanionBuilder,
      $$EnergyEventsTableUpdateCompanionBuilder,
      (EnergyEvent, $$EnergyEventsTableReferences),
      EnergyEvent,
      PrefetchHooks Function({bool vehicleId, bool stationId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String vehicleId,
      required DateTime at,
      Value<double?> odometerKm,
      required String kind,
      required String description,
      required double cost,
      Value<String?> location,
      Value<String?> notes,
      Value<int?> reminderMonths,
      Value<int?> reminderKm,
      Value<String> source,
      Value<String?> sourceRef,
      Value<String?> serviceItemId,
      Value<String?> tripId,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<DateTime> at,
      Value<double?> odometerKm,
      Value<String> kind,
      Value<String> description,
      Value<double> cost,
      Value<String?> location,
      Value<String?> notes,
      Value<int?> reminderMonths,
      Value<int?> reminderKm,
      Value<String> source,
      Value<String?> sourceRef,
      Value<String?> serviceItemId,
      Value<String?> tripId,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) => db.vehicles
      .createAlias($_aliasNameGenerator(db.expenses.vehicleId, db.vehicles.id));

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMonths => $composableBuilder(
    column: $table.reminderMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderKm => $composableBuilder(
    column: $table.reminderKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceItemId => $composableBuilder(
    column: $table.serviceItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMonths => $composableBuilder(
    column: $table.reminderMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderKm => $composableBuilder(
    column: $table.reminderKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceItemId => $composableBuilder(
    column: $table.serviceItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get reminderMonths => $composableBuilder(
    column: $table.reminderMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderKm => $composableBuilder(
    column: $table.reminderKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<String> get serviceItemId => $composableBuilder(
    column: $table.serviceItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<double?> odometerKm = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> reminderMonths = const Value.absent(),
                Value<int?> reminderKm = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> serviceItemId = const Value.absent(),
                Value<String?> tripId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                vehicleId: vehicleId,
                at: at,
                odometerKm: odometerKm,
                kind: kind,
                description: description,
                cost: cost,
                location: location,
                notes: notes,
                reminderMonths: reminderMonths,
                reminderKm: reminderKm,
                source: source,
                sourceRef: sourceRef,
                serviceItemId: serviceItemId,
                tripId: tripId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required DateTime at,
                Value<double?> odometerKm = const Value.absent(),
                required String kind,
                required String description,
                required double cost,
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> reminderMonths = const Value.absent(),
                Value<int?> reminderKm = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> serviceItemId = const Value.absent(),
                Value<String?> tripId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                at: at,
                odometerKm: odometerKm,
                kind: kind,
                description: description,
                cost: cost,
                location: location,
                notes: notes,
                reminderMonths: reminderMonths,
                reminderKm: reminderKm,
                source: source,
                sourceRef: sourceRef,
                serviceItemId: serviceItemId,
                tripId: tripId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$ExpensesTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      required String id,
      required String vehicleId,
      required String name,
      required DateTime startAt,
      Value<DateTime?> endAt,
      Value<double?> startOdometerKm,
      Value<double?> endOdometerKm,
      Value<double?> gpsDistanceKm,
      Value<String> status,
      Value<String?> notes,
      Value<String> source,
      Value<String?> sourceRef,
      Value<String?> startedBy,
      Value<String?> statsJson,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> name,
      Value<DateTime> startAt,
      Value<DateTime?> endAt,
      Value<double?> startOdometerKm,
      Value<double?> endOdometerKm,
      Value<double?> gpsDistanceKm,
      Value<String> status,
      Value<String?> notes,
      Value<String> source,
      Value<String?> sourceRef,
      Value<String?> startedBy,
      Value<String?> statsJson,
      Value<int> rowid,
    });

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) => db.vehicles
      .createAlias($_aliasNameGenerator(db.trips.vehicleId, db.vehicles.id));

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TripPointsTable, List<TripPoint>>
  _tripPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripPoints,
    aliasName: $_aliasNameGenerator(db.trips.id, db.tripPoints.tripId),
  );

  $$TripPointsTableProcessedTableManager get tripPointsRefs {
    final manager = $$TripPointsTableTableManager(
      $_db,
      $_db.tripPoints,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripStopsTable, List<TripStop>>
  _tripStopsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripStops,
    aliasName: $_aliasNameGenerator(db.trips.id, db.tripStops.tripId),
  );

  $$TripStopsTableProcessedTableManager get tripStopsRefs {
    final manager = $$TripStopsTableTableManager(
      $_db,
      $_db.tripStops,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripStopsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startOdometerKm => $composableBuilder(
    column: $table.startOdometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endOdometerKm => $composableBuilder(
    column: $table.endOdometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsDistanceKm => $composableBuilder(
    column: $table.gpsDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedBy => $composableBuilder(
    column: $table.startedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tripPointsRefs(
    Expression<bool> Function($$TripPointsTableFilterComposer f) f,
  ) {
    final $$TripPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPoints,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPointsTableFilterComposer(
            $db: $db,
            $table: $db.tripPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripStopsRefs(
    Expression<bool> Function($$TripStopsTableFilterComposer f) f,
  ) {
    final $$TripStopsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripStops,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripStopsTableFilterComposer(
            $db: $db,
            $table: $db.tripStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startOdometerKm => $composableBuilder(
    column: $table.startOdometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endOdometerKm => $composableBuilder(
    column: $table.endOdometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsDistanceKm => $composableBuilder(
    column: $table.gpsDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedBy => $composableBuilder(
    column: $table.startedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<double> get startOdometerKm => $composableBuilder(
    column: $table.startOdometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endOdometerKm => $composableBuilder(
    column: $table.endOdometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsDistanceKm => $composableBuilder(
    column: $table.gpsDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<String> get startedBy =>
      $composableBuilder(column: $table.startedBy, builder: (column) => column);

  GeneratedColumn<String> get statsJson =>
      $composableBuilder(column: $table.statsJson, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tripPointsRefs<T extends Object>(
    Expression<T> Function($$TripPointsTableAnnotationComposer a) f,
  ) {
    final $$TripPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPoints,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripStopsRefs<T extends Object>(
    Expression<T> Function($$TripStopsTableAnnotationComposer a) f,
  ) {
    final $$TripStopsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripStops,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripStopsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, $$TripsTableReferences),
          Trip,
          PrefetchHooks Function({
            bool vehicleId,
            bool tripPointsRefs,
            bool tripStopsRefs,
          })
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<double?> startOdometerKm = const Value.absent(),
                Value<double?> endOdometerKm = const Value.absent(),
                Value<double?> gpsDistanceKm = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> startedBy = const Value.absent(),
                Value<String?> statsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                vehicleId: vehicleId,
                name: name,
                startAt: startAt,
                endAt: endAt,
                startOdometerKm: startOdometerKm,
                endOdometerKm: endOdometerKm,
                gpsDistanceKm: gpsDistanceKm,
                status: status,
                notes: notes,
                source: source,
                sourceRef: sourceRef,
                startedBy: startedBy,
                statsJson: statsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String name,
                required DateTime startAt,
                Value<DateTime?> endAt = const Value.absent(),
                Value<double?> startOdometerKm = const Value.absent(),
                Value<double?> endOdometerKm = const Value.absent(),
                Value<double?> gpsDistanceKm = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> startedBy = const Value.absent(),
                Value<String?> statsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                name: name,
                startAt: startAt,
                endAt: endAt,
                startOdometerKm: startOdometerKm,
                endOdometerKm: endOdometerKm,
                gpsDistanceKm: gpsDistanceKm,
                status: status,
                notes: notes,
                source: source,
                sourceRef: sourceRef,
                startedBy: startedBy,
                statsJson: statsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehicleId = false,
                tripPointsRefs = false,
                tripStopsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripPointsRefs) db.tripPoints,
                    if (tripStopsRefs) db.tripStops,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable: $$TripsTableReferences
                                        ._vehicleIdTable(db),
                                    referencedColumn: $$TripsTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripPointsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, TripPoint>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripStopsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, TripStop>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripStopsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripStopsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, $$TripsTableReferences),
      Trip,
      PrefetchHooks Function({
        bool vehicleId,
        bool tripPointsRefs,
        bool tripStopsRefs,
      })
    >;
typedef $$TripPointsTableCreateCompanionBuilder =
    TripPointsCompanion Function({
      Value<int> seq,
      required String tripId,
      required DateTime at,
      required double lat,
      required double lon,
      Value<double?> speedMps,
      Value<double?> accuracyM,
      Value<double?> altitudeM,
    });
typedef $$TripPointsTableUpdateCompanionBuilder =
    TripPointsCompanion Function({
      Value<int> seq,
      Value<String> tripId,
      Value<DateTime> at,
      Value<double> lat,
      Value<double> lon,
      Value<double?> speedMps,
      Value<double?> accuracyM,
      Value<double?> altitudeM,
    });

final class $$TripPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TripPointsTable, TripPoint> {
  $$TripPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.tripPoints.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TripPointsTable> {
  $$TripPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPointsTable> {
  $$TripPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPointsTable> {
  $$TripPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripPointsTable,
          TripPoint,
          $$TripPointsTableFilterComposer,
          $$TripPointsTableOrderingComposer,
          $$TripPointsTableAnnotationComposer,
          $$TripPointsTableCreateCompanionBuilder,
          $$TripPointsTableUpdateCompanionBuilder,
          (TripPoint, $$TripPointsTableReferences),
          TripPoint,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripPointsTableTableManager(_$AppDatabase db, $TripPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
              }) => TripPointsCompanion(
                seq: seq,
                tripId: tripId,
                at: at,
                lat: lat,
                lon: lon,
                speedMps: speedMps,
                accuracyM: accuracyM,
                altitudeM: altitudeM,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String tripId,
                required DateTime at,
                required double lat,
                required double lon,
                Value<double?> speedMps = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
              }) => TripPointsCompanion.insert(
                seq: seq,
                tripId: tripId,
                at: at,
                lat: lat,
                lon: lon,
                speedMps: speedMps,
                accuracyM: accuracyM,
                altitudeM: altitudeM,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$TripPointsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$TripPointsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripPointsTable,
      TripPoint,
      $$TripPointsTableFilterComposer,
      $$TripPointsTableOrderingComposer,
      $$TripPointsTableAnnotationComposer,
      $$TripPointsTableCreateCompanionBuilder,
      $$TripPointsTableUpdateCompanionBuilder,
      (TripPoint, $$TripPointsTableReferences),
      TripPoint,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$TripStopsTableCreateCompanionBuilder =
    TripStopsCompanion Function({
      required String id,
      required String tripId,
      required DateTime arriveAt,
      Value<DateTime?> departAt,
      Value<double?> lat,
      Value<double?> lon,
      Value<String?> name,
      Value<String?> energyEventId,
      Value<int> rowid,
    });
typedef $$TripStopsTableUpdateCompanionBuilder =
    TripStopsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<DateTime> arriveAt,
      Value<DateTime?> departAt,
      Value<double?> lat,
      Value<double?> lon,
      Value<String?> name,
      Value<String?> energyEventId,
      Value<int> rowid,
    });

final class $$TripStopsTableReferences
    extends BaseReferences<_$AppDatabase, $TripStopsTable, TripStop> {
  $$TripStopsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.tripStops.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripStopsTableFilterComposer
    extends Composer<_$AppDatabase, $TripStopsTable> {
  $$TripStopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arriveAt => $composableBuilder(
    column: $table.arriveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get departAt => $composableBuilder(
    column: $table.departAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get energyEventId => $composableBuilder(
    column: $table.energyEventId,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripStopsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripStopsTable> {
  $$TripStopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arriveAt => $composableBuilder(
    column: $table.arriveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get departAt => $composableBuilder(
    column: $table.departAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyEventId => $composableBuilder(
    column: $table.energyEventId,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripStopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripStopsTable> {
  $$TripStopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get arriveAt =>
      $composableBuilder(column: $table.arriveAt, builder: (column) => column);

  GeneratedColumn<DateTime> get departAt =>
      $composableBuilder(column: $table.departAt, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get energyEventId => $composableBuilder(
    column: $table.energyEventId,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripStopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripStopsTable,
          TripStop,
          $$TripStopsTableFilterComposer,
          $$TripStopsTableOrderingComposer,
          $$TripStopsTableAnnotationComposer,
          $$TripStopsTableCreateCompanionBuilder,
          $$TripStopsTableUpdateCompanionBuilder,
          (TripStop, $$TripStopsTableReferences),
          TripStop,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripStopsTableTableManager(_$AppDatabase db, $TripStopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripStopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripStopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripStopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> arriveAt = const Value.absent(),
                Value<DateTime?> departAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> energyEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripStopsCompanion(
                id: id,
                tripId: tripId,
                arriveAt: arriveAt,
                departAt: departAt,
                lat: lat,
                lon: lon,
                name: name,
                energyEventId: energyEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required DateTime arriveAt,
                Value<DateTime?> departAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> energyEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripStopsCompanion.insert(
                id: id,
                tripId: tripId,
                arriveAt: arriveAt,
                departAt: departAt,
                lat: lat,
                lon: lon,
                name: name,
                energyEventId: energyEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripStopsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$TripStopsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$TripStopsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripStopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripStopsTable,
      TripStop,
      $$TripStopsTableFilterComposer,
      $$TripStopsTableOrderingComposer,
      $$TripStopsTableAnnotationComposer,
      $$TripStopsTableCreateCompanionBuilder,
      $$TripStopsTableUpdateCompanionBuilder,
      (TripStop, $$TripStopsTableReferences),
      TripStop,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$TyreSetsTableCreateCompanionBuilder =
    TyreSetsCompanion Function({
      required String id,
      required String vehicleId,
      required String name,
      Value<DateTime?> fittedAt,
      Value<double?> fittedOdometerKm,
      Value<String?> size,
      Value<double?> cost,
      Value<double?> recommendedFrontKpa,
      Value<double?> recommendedRearKpa,
      Value<DateTime?> removedAt,
      Value<int> rowid,
    });
typedef $$TyreSetsTableUpdateCompanionBuilder =
    TyreSetsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> name,
      Value<DateTime?> fittedAt,
      Value<double?> fittedOdometerKm,
      Value<String?> size,
      Value<double?> cost,
      Value<double?> recommendedFrontKpa,
      Value<double?> recommendedRearKpa,
      Value<DateTime?> removedAt,
      Value<int> rowid,
    });

final class $$TyreSetsTableReferences
    extends BaseReferences<_$AppDatabase, $TyreSetsTable, TyreSet> {
  $$TyreSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) => db.vehicles
      .createAlias($_aliasNameGenerator(db.tyreSets.vehicleId, db.vehicles.id));

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TyreSetsTableFilterComposer
    extends Composer<_$AppDatabase, $TyreSetsTable> {
  $$TyreSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fittedAt => $composableBuilder(
    column: $table.fittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fittedOdometerKm => $composableBuilder(
    column: $table.fittedOdometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recommendedFrontKpa => $composableBuilder(
    column: $table.recommendedFrontKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recommendedRearKpa => $composableBuilder(
    column: $table.recommendedRearKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TyreSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $TyreSetsTable> {
  $$TyreSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fittedAt => $composableBuilder(
    column: $table.fittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fittedOdometerKm => $composableBuilder(
    column: $table.fittedOdometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recommendedFrontKpa => $composableBuilder(
    column: $table.recommendedFrontKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recommendedRearKpa => $composableBuilder(
    column: $table.recommendedRearKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TyreSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TyreSetsTable> {
  $$TyreSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get fittedAt =>
      $composableBuilder(column: $table.fittedAt, builder: (column) => column);

  GeneratedColumn<double> get fittedOdometerKm => $composableBuilder(
    column: $table.fittedOdometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<double> get recommendedFrontKpa => $composableBuilder(
    column: $table.recommendedFrontKpa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recommendedRearKpa => $composableBuilder(
    column: $table.recommendedRearKpa,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TyreSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TyreSetsTable,
          TyreSet,
          $$TyreSetsTableFilterComposer,
          $$TyreSetsTableOrderingComposer,
          $$TyreSetsTableAnnotationComposer,
          $$TyreSetsTableCreateCompanionBuilder,
          $$TyreSetsTableUpdateCompanionBuilder,
          (TyreSet, $$TyreSetsTableReferences),
          TyreSet,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$TyreSetsTableTableManager(_$AppDatabase db, $TyreSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TyreSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TyreSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TyreSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> fittedAt = const Value.absent(),
                Value<double?> fittedOdometerKm = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<double?> recommendedFrontKpa = const Value.absent(),
                Value<double?> recommendedRearKpa = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TyreSetsCompanion(
                id: id,
                vehicleId: vehicleId,
                name: name,
                fittedAt: fittedAt,
                fittedOdometerKm: fittedOdometerKm,
                size: size,
                cost: cost,
                recommendedFrontKpa: recommendedFrontKpa,
                recommendedRearKpa: recommendedRearKpa,
                removedAt: removedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String name,
                Value<DateTime?> fittedAt = const Value.absent(),
                Value<double?> fittedOdometerKm = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<double?> recommendedFrontKpa = const Value.absent(),
                Value<double?> recommendedRearKpa = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TyreSetsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                name: name,
                fittedAt: fittedAt,
                fittedOdometerKm: fittedOdometerKm,
                size: size,
                cost: cost,
                recommendedFrontKpa: recommendedFrontKpa,
                recommendedRearKpa: recommendedRearKpa,
                removedAt: removedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TyreSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$TyreSetsTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$TyreSetsTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TyreSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TyreSetsTable,
      TyreSet,
      $$TyreSetsTableFilterComposer,
      $$TyreSetsTableOrderingComposer,
      $$TyreSetsTableAnnotationComposer,
      $$TyreSetsTableCreateCompanionBuilder,
      $$TyreSetsTableUpdateCompanionBuilder,
      (TyreSet, $$TyreSetsTableReferences),
      TyreSet,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$TyreChecksTableCreateCompanionBuilder =
    TyreChecksCompanion Function({
      required String id,
      required String vehicleId,
      Value<String?> tyreSetId,
      required DateTime at,
      Value<double?> odometerKm,
      Value<double?> foundFlKpa,
      Value<double?> foundFrKpa,
      Value<double?> foundRlKpa,
      Value<double?> foundRrKpa,
      Value<double?> foundSpareKpa,
      Value<double?> leftFlKpa,
      Value<double?> leftFrKpa,
      Value<double?> leftRlKpa,
      Value<double?> leftRrKpa,
      Value<double?> leftSpareKpa,
      Value<bool> airAdded,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$TyreChecksTableUpdateCompanionBuilder =
    TyreChecksCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String?> tyreSetId,
      Value<DateTime> at,
      Value<double?> odometerKm,
      Value<double?> foundFlKpa,
      Value<double?> foundFrKpa,
      Value<double?> foundRlKpa,
      Value<double?> foundRrKpa,
      Value<double?> foundSpareKpa,
      Value<double?> leftFlKpa,
      Value<double?> leftFrKpa,
      Value<double?> leftRlKpa,
      Value<double?> leftRrKpa,
      Value<double?> leftSpareKpa,
      Value<bool> airAdded,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$TyreChecksTableReferences
    extends BaseReferences<_$AppDatabase, $TyreChecksTable, TyreCheck> {
  $$TyreChecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.tyreChecks.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TyreChecksTableFilterComposer
    extends Composer<_$AppDatabase, $TyreChecksTable> {
  $$TyreChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tyreSetId => $composableBuilder(
    column: $table.tyreSetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundFlKpa => $composableBuilder(
    column: $table.foundFlKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundFrKpa => $composableBuilder(
    column: $table.foundFrKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundRlKpa => $composableBuilder(
    column: $table.foundRlKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundRrKpa => $composableBuilder(
    column: $table.foundRrKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundSpareKpa => $composableBuilder(
    column: $table.foundSpareKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftFlKpa => $composableBuilder(
    column: $table.leftFlKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftFrKpa => $composableBuilder(
    column: $table.leftFrKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftRlKpa => $composableBuilder(
    column: $table.leftRlKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftRrKpa => $composableBuilder(
    column: $table.leftRrKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftSpareKpa => $composableBuilder(
    column: $table.leftSpareKpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get airAdded => $composableBuilder(
    column: $table.airAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TyreChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $TyreChecksTable> {
  $$TyreChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tyreSetId => $composableBuilder(
    column: $table.tyreSetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundFlKpa => $composableBuilder(
    column: $table.foundFlKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundFrKpa => $composableBuilder(
    column: $table.foundFrKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundRlKpa => $composableBuilder(
    column: $table.foundRlKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundRrKpa => $composableBuilder(
    column: $table.foundRrKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundSpareKpa => $composableBuilder(
    column: $table.foundSpareKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftFlKpa => $composableBuilder(
    column: $table.leftFlKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftFrKpa => $composableBuilder(
    column: $table.leftFrKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftRlKpa => $composableBuilder(
    column: $table.leftRlKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftRrKpa => $composableBuilder(
    column: $table.leftRrKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftSpareKpa => $composableBuilder(
    column: $table.leftSpareKpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get airAdded => $composableBuilder(
    column: $table.airAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TyreChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TyreChecksTable> {
  $$TyreChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tyreSetId =>
      $composableBuilder(column: $table.tyreSetId, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundFlKpa => $composableBuilder(
    column: $table.foundFlKpa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundFrKpa => $composableBuilder(
    column: $table.foundFrKpa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundRlKpa => $composableBuilder(
    column: $table.foundRlKpa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundRrKpa => $composableBuilder(
    column: $table.foundRrKpa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundSpareKpa => $composableBuilder(
    column: $table.foundSpareKpa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leftFlKpa =>
      $composableBuilder(column: $table.leftFlKpa, builder: (column) => column);

  GeneratedColumn<double> get leftFrKpa =>
      $composableBuilder(column: $table.leftFrKpa, builder: (column) => column);

  GeneratedColumn<double> get leftRlKpa =>
      $composableBuilder(column: $table.leftRlKpa, builder: (column) => column);

  GeneratedColumn<double> get leftRrKpa =>
      $composableBuilder(column: $table.leftRrKpa, builder: (column) => column);

  GeneratedColumn<double> get leftSpareKpa => $composableBuilder(
    column: $table.leftSpareKpa,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get airAdded =>
      $composableBuilder(column: $table.airAdded, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TyreChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TyreChecksTable,
          TyreCheck,
          $$TyreChecksTableFilterComposer,
          $$TyreChecksTableOrderingComposer,
          $$TyreChecksTableAnnotationComposer,
          $$TyreChecksTableCreateCompanionBuilder,
          $$TyreChecksTableUpdateCompanionBuilder,
          (TyreCheck, $$TyreChecksTableReferences),
          TyreCheck,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$TyreChecksTableTableManager(_$AppDatabase db, $TyreChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TyreChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TyreChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TyreChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String?> tyreSetId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<double?> odometerKm = const Value.absent(),
                Value<double?> foundFlKpa = const Value.absent(),
                Value<double?> foundFrKpa = const Value.absent(),
                Value<double?> foundRlKpa = const Value.absent(),
                Value<double?> foundRrKpa = const Value.absent(),
                Value<double?> foundSpareKpa = const Value.absent(),
                Value<double?> leftFlKpa = const Value.absent(),
                Value<double?> leftFrKpa = const Value.absent(),
                Value<double?> leftRlKpa = const Value.absent(),
                Value<double?> leftRrKpa = const Value.absent(),
                Value<double?> leftSpareKpa = const Value.absent(),
                Value<bool> airAdded = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TyreChecksCompanion(
                id: id,
                vehicleId: vehicleId,
                tyreSetId: tyreSetId,
                at: at,
                odometerKm: odometerKm,
                foundFlKpa: foundFlKpa,
                foundFrKpa: foundFrKpa,
                foundRlKpa: foundRlKpa,
                foundRrKpa: foundRrKpa,
                foundSpareKpa: foundSpareKpa,
                leftFlKpa: leftFlKpa,
                leftFrKpa: leftFrKpa,
                leftRlKpa: leftRlKpa,
                leftRrKpa: leftRrKpa,
                leftSpareKpa: leftSpareKpa,
                airAdded: airAdded,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                Value<String?> tyreSetId = const Value.absent(),
                required DateTime at,
                Value<double?> odometerKm = const Value.absent(),
                Value<double?> foundFlKpa = const Value.absent(),
                Value<double?> foundFrKpa = const Value.absent(),
                Value<double?> foundRlKpa = const Value.absent(),
                Value<double?> foundRrKpa = const Value.absent(),
                Value<double?> foundSpareKpa = const Value.absent(),
                Value<double?> leftFlKpa = const Value.absent(),
                Value<double?> leftFrKpa = const Value.absent(),
                Value<double?> leftRlKpa = const Value.absent(),
                Value<double?> leftRrKpa = const Value.absent(),
                Value<double?> leftSpareKpa = const Value.absent(),
                Value<bool> airAdded = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TyreChecksCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                tyreSetId: tyreSetId,
                at: at,
                odometerKm: odometerKm,
                foundFlKpa: foundFlKpa,
                foundFrKpa: foundFrKpa,
                foundRlKpa: foundRlKpa,
                foundRrKpa: foundRrKpa,
                foundSpareKpa: foundSpareKpa,
                leftFlKpa: leftFlKpa,
                leftFrKpa: leftFrKpa,
                leftRlKpa: leftRlKpa,
                leftRrKpa: leftRrKpa,
                leftSpareKpa: leftSpareKpa,
                airAdded: airAdded,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TyreChecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$TyreChecksTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$TyreChecksTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TyreChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TyreChecksTable,
      TyreCheck,
      $$TyreChecksTableFilterComposer,
      $$TyreChecksTableOrderingComposer,
      $$TyreChecksTableAnnotationComposer,
      $$TyreChecksTableCreateCompanionBuilder,
      $$TyreChecksTableUpdateCompanionBuilder,
      (TyreCheck, $$TyreChecksTableReferences),
      TyreCheck,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> seq,
      required String targetTable,
      required String rowId,
      required String action,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> queuedAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> seq,
      Value<String> targetTable,
      Value<String> rowId,
      Value<String> action,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> queuedAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncItem,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (SyncItem, BaseReferences<_$AppDatabase, $SyncQueueTable, SyncItem>),
          SyncItem,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
              }) => SyncQueueCompanion(
                seq: seq,
                targetTable: targetTable,
                rowId: rowId,
                action: action,
                attempts: attempts,
                lastError: lastError,
                queuedAt: queuedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String targetTable,
                required String rowId,
                required String action,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                seq: seq,
                targetTable: targetTable,
                rowId: rowId,
                action: action,
                attempts: attempts,
                lastError: lastError,
                queuedAt: queuedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncItem,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (SyncItem, BaseReferences<_$AppDatabase, $SyncQueueTable, SyncItem>),
      SyncItem,
      PrefetchHooks Function()
    >;
typedef $$ServiceItemsTableCreateCompanionBuilder =
    ServiceItemsCompanion Function({
      required String id,
      required String vehicleId,
      required String name,
      Value<String> kind,
      Value<int?> intervalMonths,
      Value<int?> intervalKm,
      Value<DateTime?> lastDoneAt,
      Value<double?> lastDoneKm,
      Value<String?> notes,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ServiceItemsTableUpdateCompanionBuilder =
    ServiceItemsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> name,
      Value<String> kind,
      Value<int?> intervalMonths,
      Value<int?> intervalKm,
      Value<DateTime?> lastDoneAt,
      Value<double?> lastDoneKm,
      Value<String?> notes,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ServiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ServiceItemsTable, ServiceItem> {
  $$ServiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.serviceItems.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ServiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDoneAt => $composableBuilder(
    column: $table.lastDoneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastDoneKm => $composableBuilder(
    column: $table.lastDoneKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDoneAt => $composableBuilder(
    column: $table.lastDoneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastDoneKm => $composableBuilder(
    column: $table.lastDoneKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDoneAt => $composableBuilder(
    column: $table.lastDoneAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastDoneKm => $composableBuilder(
    column: $table.lastDoneKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceItemsTable,
          ServiceItem,
          $$ServiceItemsTableFilterComposer,
          $$ServiceItemsTableOrderingComposer,
          $$ServiceItemsTableAnnotationComposer,
          $$ServiceItemsTableCreateCompanionBuilder,
          $$ServiceItemsTableUpdateCompanionBuilder,
          (ServiceItem, $$ServiceItemsTableReferences),
          ServiceItem,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$ServiceItemsTableTableManager(_$AppDatabase db, $ServiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<int?> intervalKm = const Value.absent(),
                Value<DateTime?> lastDoneAt = const Value.absent(),
                Value<double?> lastDoneKm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceItemsCompanion(
                id: id,
                vehicleId: vehicleId,
                name: name,
                kind: kind,
                intervalMonths: intervalMonths,
                intervalKm: intervalKm,
                lastDoneAt: lastDoneAt,
                lastDoneKm: lastDoneKm,
                notes: notes,
                active: active,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String name,
                Value<String> kind = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<int?> intervalKm = const Value.absent(),
                Value<DateTime?> lastDoneAt = const Value.absent(),
                Value<double?> lastDoneKm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceItemsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                name: name,
                kind: kind,
                intervalMonths: intervalMonths,
                intervalKm: intervalKm,
                lastDoneAt: lastDoneAt,
                lastDoneKm: lastDoneKm,
                notes: notes,
                active: active,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$ServiceItemsTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$ServiceItemsTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ServiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceItemsTable,
      ServiceItem,
      $$ServiceItemsTableFilterComposer,
      $$ServiceItemsTableOrderingComposer,
      $$ServiceItemsTableAnnotationComposer,
      $$ServiceItemsTableCreateCompanionBuilder,
      $$ServiceItemsTableUpdateCompanionBuilder,
      (ServiceItem, $$ServiceItemsTableReferences),
      ServiceItem,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$InsurancePoliciesTableCreateCompanionBuilder =
    InsurancePoliciesCompanion Function({
      required String id,
      required String vehicleId,
      required String insurer,
      Value<String> cover,
      Value<String?> policyNumber,
      Value<double?> insuredValue,
      Value<String?> valueType,
      Value<double?> premium,
      Value<String> premiumPeriod,
      Value<double?> excess,
      required DateTime startAt,
      Value<DateTime?> renewAt,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$InsurancePoliciesTableUpdateCompanionBuilder =
    InsurancePoliciesCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> insurer,
      Value<String> cover,
      Value<String?> policyNumber,
      Value<double?> insuredValue,
      Value<String?> valueType,
      Value<double?> premium,
      Value<String> premiumPeriod,
      Value<double?> excess,
      Value<DateTime> startAt,
      Value<DateTime?> renewAt,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$InsurancePoliciesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InsurancePoliciesTable,
          InsurancePolicy
        > {
  $$InsurancePoliciesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.insurancePolicies.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InsurancePoliciesTableFilterComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insurer => $composableBuilder(
    column: $table.insurer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyNumber => $composableBuilder(
    column: $table.policyNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get insuredValue => $composableBuilder(
    column: $table.insuredValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get premium => $composableBuilder(
    column: $table.premium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get premiumPeriod => $composableBuilder(
    column: $table.premiumPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get excess => $composableBuilder(
    column: $table.excess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get renewAt => $composableBuilder(
    column: $table.renewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsurancePoliciesTableOrderingComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insurer => $composableBuilder(
    column: $table.insurer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyNumber => $composableBuilder(
    column: $table.policyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get insuredValue => $composableBuilder(
    column: $table.insuredValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get premium => $composableBuilder(
    column: $table.premium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get premiumPeriod => $composableBuilder(
    column: $table.premiumPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get excess => $composableBuilder(
    column: $table.excess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get renewAt => $composableBuilder(
    column: $table.renewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsurancePoliciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get insurer =>
      $composableBuilder(column: $table.insurer, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get policyNumber => $composableBuilder(
    column: $table.policyNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get insuredValue => $composableBuilder(
    column: $table.insuredValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<double> get premium =>
      $composableBuilder(column: $table.premium, builder: (column) => column);

  GeneratedColumn<String> get premiumPeriod => $composableBuilder(
    column: $table.premiumPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get excess =>
      $composableBuilder(column: $table.excess, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get renewAt =>
      $composableBuilder(column: $table.renewAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsurancePoliciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsurancePoliciesTable,
          InsurancePolicy,
          $$InsurancePoliciesTableFilterComposer,
          $$InsurancePoliciesTableOrderingComposer,
          $$InsurancePoliciesTableAnnotationComposer,
          $$InsurancePoliciesTableCreateCompanionBuilder,
          $$InsurancePoliciesTableUpdateCompanionBuilder,
          (InsurancePolicy, $$InsurancePoliciesTableReferences),
          InsurancePolicy,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$InsurancePoliciesTableTableManager(
    _$AppDatabase db,
    $InsurancePoliciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsurancePoliciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsurancePoliciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsurancePoliciesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> insurer = const Value.absent(),
                Value<String> cover = const Value.absent(),
                Value<String?> policyNumber = const Value.absent(),
                Value<double?> insuredValue = const Value.absent(),
                Value<String?> valueType = const Value.absent(),
                Value<double?> premium = const Value.absent(),
                Value<String> premiumPeriod = const Value.absent(),
                Value<double?> excess = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime?> renewAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancePoliciesCompanion(
                id: id,
                vehicleId: vehicleId,
                insurer: insurer,
                cover: cover,
                policyNumber: policyNumber,
                insuredValue: insuredValue,
                valueType: valueType,
                premium: premium,
                premiumPeriod: premiumPeriod,
                excess: excess,
                startAt: startAt,
                renewAt: renewAt,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String insurer,
                Value<String> cover = const Value.absent(),
                Value<String?> policyNumber = const Value.absent(),
                Value<double?> insuredValue = const Value.absent(),
                Value<String?> valueType = const Value.absent(),
                Value<double?> premium = const Value.absent(),
                Value<String> premiumPeriod = const Value.absent(),
                Value<double?> excess = const Value.absent(),
                required DateTime startAt,
                Value<DateTime?> renewAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancePoliciesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                insurer: insurer,
                cover: cover,
                policyNumber: policyNumber,
                insuredValue: insuredValue,
                valueType: valueType,
                premium: premium,
                premiumPeriod: premiumPeriod,
                excess: excess,
                startAt: startAt,
                renewAt: renewAt,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InsurancePoliciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$InsurancePoliciesTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$InsurancePoliciesTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InsurancePoliciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsurancePoliciesTable,
      InsurancePolicy,
      $$InsurancePoliciesTableFilterComposer,
      $$InsurancePoliciesTableOrderingComposer,
      $$InsurancePoliciesTableAnnotationComposer,
      $$InsurancePoliciesTableCreateCompanionBuilder,
      $$InsurancePoliciesTableUpdateCompanionBuilder,
      (InsurancePolicy, $$InsurancePoliciesTableReferences),
      InsurancePolicy,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$FuelCreditsTableCreateCompanionBuilder =
    FuelCreditsCompanion Function({
      required String id,
      required DateTime at,
      Value<String?> fuelType,
      required double litres,
      required double cost,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$FuelCreditsTableUpdateCompanionBuilder =
    FuelCreditsCompanion Function({
      Value<String> id,
      Value<DateTime> at,
      Value<String?> fuelType,
      Value<double> litres,
      Value<double> cost,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FuelCreditsTableFilterComposer
    extends Composer<_$AppDatabase, $FuelCreditsTable> {
  $$FuelCreditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get litres => $composableBuilder(
    column: $table.litres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FuelCreditsTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelCreditsTable> {
  $$FuelCreditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get litres => $composableBuilder(
    column: $table.litres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FuelCreditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelCreditsTable> {
  $$FuelCreditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<double> get litres =>
      $composableBuilder(column: $table.litres, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FuelCreditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelCreditsTable,
          FuelCredit,
          $$FuelCreditsTableFilterComposer,
          $$FuelCreditsTableOrderingComposer,
          $$FuelCreditsTableAnnotationComposer,
          $$FuelCreditsTableCreateCompanionBuilder,
          $$FuelCreditsTableUpdateCompanionBuilder,
          (
            FuelCredit,
            BaseReferences<_$AppDatabase, $FuelCreditsTable, FuelCredit>,
          ),
          FuelCredit,
          PrefetchHooks Function()
        > {
  $$FuelCreditsTableTableManager(_$AppDatabase db, $FuelCreditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelCreditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelCreditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelCreditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String?> fuelType = const Value.absent(),
                Value<double> litres = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FuelCreditsCompanion(
                id: id,
                at: at,
                fuelType: fuelType,
                litres: litres,
                cost: cost,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime at,
                Value<String?> fuelType = const Value.absent(),
                required double litres,
                required double cost,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FuelCreditsCompanion.insert(
                id: id,
                at: at,
                fuelType: fuelType,
                litres: litres,
                cost: cost,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FuelCreditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelCreditsTable,
      FuelCredit,
      $$FuelCreditsTableFilterComposer,
      $$FuelCreditsTableOrderingComposer,
      $$FuelCreditsTableAnnotationComposer,
      $$FuelCreditsTableCreateCompanionBuilder,
      $$FuelCreditsTableUpdateCompanionBuilder,
      (
        FuelCredit,
        BaseReferences<_$AppDatabase, $FuelCreditsTable, FuelCredit>,
      ),
      FuelCredit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$StationsTableTableManager get stations =>
      $$StationsTableTableManager(_db, _db.stations);
  $$EnergyEventsTableTableManager get energyEvents =>
      $$EnergyEventsTableTableManager(_db, _db.energyEvents);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TripPointsTableTableManager get tripPoints =>
      $$TripPointsTableTableManager(_db, _db.tripPoints);
  $$TripStopsTableTableManager get tripStops =>
      $$TripStopsTableTableManager(_db, _db.tripStops);
  $$TyreSetsTableTableManager get tyreSets =>
      $$TyreSetsTableTableManager(_db, _db.tyreSets);
  $$TyreChecksTableTableManager get tyreChecks =>
      $$TyreChecksTableTableManager(_db, _db.tyreChecks);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$ServiceItemsTableTableManager get serviceItems =>
      $$ServiceItemsTableTableManager(_db, _db.serviceItems);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(_db, _db.insurancePolicies);
  $$FuelCreditsTableTableManager get fuelCredits =>
      $$FuelCreditsTableTableManager(_db, _db.fuelCredits);
}
