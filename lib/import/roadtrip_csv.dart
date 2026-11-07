/// Parser for the "Road Trip" app's CSV export: one file with several titled
/// sections (FUEL RECORDS, MAINTENANCE RECORDS, ROAD TRIPS, VEHICLE, TIRE LOG,
/// VALUATIONS), each with its own header row, separated by blank lines.
library;

import 'package:csv/csv.dart';

class RoadTripFuel {
  final double odometerKm;
  final double? tripKm;
  final DateTime at;
  final double quantity;
  final String units;
  final double? pricePerUnit;
  final double cost;
  final bool partial;
  final String? octane;
  final String? location;
  final String? payment;
  final String? note;
  final double? lat;
  final double? lon;
  final String id;
  const RoadTripFuel({
    required this.odometerKm,
    this.tripKm,
    required this.at,
    required this.quantity,
    required this.units,
    this.pricePerUnit,
    required this.cost,
    required this.partial,
    this.octane,
    this.location,
    this.payment,
    this.note,
    this.lat,
    this.lon,
    required this.id,
  });
}

class RoadTripMaintenance {
  final String description;
  final DateTime at;
  final double? odometerKm;
  final double cost;
  final String? note;
  final String? location;
  final String type; // Expense / Service
  final String? reminderInterval; // e.g. "1y", "12m"
  final String id;
  const RoadTripMaintenance({
    required this.description,
    required this.at,
    this.odometerKm,
    required this.cost,
    this.note,
    this.location,
    required this.type,
    this.reminderInterval,
    required this.id,
  });
}

class RoadTripTrip {
  final String name;
  final DateTime startAt;
  final double? startOdometerKm;
  final DateTime? endAt;
  final double? endOdometerKm;
  final double? distanceKm;
  final String id;
  const RoadTripTrip({
    required this.name,
    required this.startAt,
    this.startOdometerKm,
    this.endAt,
    this.endOdometerKm,
    this.distanceKm,
    required this.id,
  });
}

class RoadTripVehicle {
  final String name;
  final double? tankCapacity;
  final String? currency;
  const RoadTripVehicle({required this.name, this.tankCapacity, this.currency});
}

class RoadTripTyreSet {
  final String name;
  final DateTime? startAt;
  final double? startOdometerKm;
  final String? size;
  final double? distanceKm;
  const RoadTripTyreSet({required this.name, this.startAt, this.startOdometerKm, this.size, this.distanceKm});
}

class RoadTripExport {
  final List<RoadTripFuel> fuel;
  final List<RoadTripMaintenance> maintenance;
  final List<RoadTripTrip> trips;
  final RoadTripVehicle? vehicle;
  final List<RoadTripTyreSet> tyreSets;
  final List<String> warnings;
  const RoadTripExport({
    required this.fuel,
    required this.maintenance,
    required this.trips,
    this.vehicle,
    required this.tyreSets,
    required this.warnings,
  });
}

bool looksLikeRoadTripCsv(String text) => text.trimLeft().startsWith('ROAD TRIP CSV');

/// Dates are `YYYY-M-D` optionally followed by ` H:MM`, no zero padding.
DateTime? parseRoadTripDate(String s) {
  final m = RegExp(r'^\s*(\d{4})-(\d{1,2})-(\d{1,2})(?:\s+(\d{1,2}):(\d{2}))?\s*$').firstMatch(s);
  if (m == null) return null;
  return DateTime(
    int.parse(m[1]!),
    int.parse(m[2]!),
    int.parse(m[3]!),
    m[4] == null ? 0 : int.parse(m[4]!),
    m[5] == null ? 0 : int.parse(m[5]!),
  );
}

double? _num(String? s) {
  if (s == null) return null;
  final t = s.trim();
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

String? _str(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

RoadTripExport parseRoadTripCsv(String text) {
  final warnings = <String>[];
  final rows = const CsvToListConverter(shouldParseNumbers: false, eol: '\n')
      .convert(text.replaceAll('\r\n', '\n'));

  // Split into sections: a section starts at a row whose first cell is an
  // all-caps title and the rest are empty, followed by a header row.
  final sections = <String, List<List<String>>>{};
  String? current;
  for (final raw in rows) {
    final row = raw.map((c) => c.toString()).toList();
    final first = row.isNotEmpty ? row.first.trim() : '';
    final restEmpty = row.skip(1).every((c) => c.trim().isEmpty);
    if (first.isNotEmpty && restEmpty && first == first.toUpperCase() && first.length > 3 && !first.startsWith('ROAD TRIP CSV')) {
      current = first;
      sections[current] = [];
      continue;
    }
    if (current == null) continue;
    if (row.every((c) => c.trim().isEmpty)) continue;
    sections[current]!.add(row);
  }

  Map<String, String> toMap(List<String> header, List<String> row) {
    final m = <String, String>{};
    for (var i = 0; i < header.length; i++) {
      m[header[i].trim()] = i < row.length ? row[i] : '';
    }
    return m;
  }

  List<Map<String, String>> records(String name) {
    final s = sections[name];
    if (s == null || s.isEmpty) return const [];
    final header = s.first;
    return s.skip(1).map((r) => toMap(header, r)).toList();
  }

  final fuel = <RoadTripFuel>[];
  for (final r in records('FUEL RECORDS')) {
    final at = parseRoadTripDate(r['Date'] ?? '');
    final odo = _num(r['Odometer (km)']);
    final qty = _num(r['Fill Amount']);
    final cost = _num(r['Total Price']);
    if (at == null || odo == null || qty == null || cost == null) {
      warnings.add('Skipped fuel row with missing fields: ${r['Date']} ${r['Odometer (km)']}');
      continue;
    }
    fuel.add(RoadTripFuel(
      odometerKm: odo,
      tripKm: _num(r['Trip Distance']),
      at: at,
      quantity: qty,
      units: _str(r['Fill Units']) ?? 'L',
      pricePerUnit: _num(r['Price per Unit']),
      cost: cost,
      partial: (_str(r['Partial Fill']) ?? '').toLowerCase() == 'partial',
      octane: _str(r['Octane']),
      location: _str(r['Location']),
      payment: _str(r['Payment']),
      note: _str(r['Note']),
      lat: _num(r['Latitude']),
      lon: _num(r['Longitude']),
      id: _str(r['ID']) ?? '${odo}_${at.toIso8601String()}',
    ));
  }

  final maintenance = <RoadTripMaintenance>[];
  for (final r in records('MAINTENANCE RECORDS')) {
    final at = parseRoadTripDate(r['Date'] ?? '');
    final cost = _num(r['Cost']);
    final desc = _str(r['Description']);
    if (at == null || cost == null || desc == null) {
      warnings.add('Skipped maintenance row: ${r['Description']} ${r['Date']}');
      continue;
    }
    maintenance.add(RoadTripMaintenance(
      description: desc,
      at: at,
      odometerKm: _num(r['Odometer (km)']),
      cost: cost,
      note: _str(r['Note']),
      location: _str(r['Location']),
      type: _str(r['Type']) ?? 'Expense',
      reminderInterval: _str(r['Reminder Interval']),
      id: _str(r['ID']) ?? '${desc}_${at.toIso8601String()}',
    ));
  }

  final trips = <RoadTripTrip>[];
  for (final r in records('ROAD TRIPS')) {
    final start = parseRoadTripDate(r['Start Date'] ?? '');
    final name = _str(r['Name']);
    if (start == null || name == null) continue;
    trips.add(RoadTripTrip(
      name: name,
      startAt: start,
      startOdometerKm: _num(r['Start Odometer (km)']),
      endAt: parseRoadTripDate(r['End Date'] ?? ''),
      endOdometerKm: _num(r['End Odometer']),
      distanceKm: _num(r['Distance']),
      id: _str(r['ID']) ?? name,
    ));
  }

  RoadTripVehicle? vehicle;
  final v = records('VEHICLE');
  if (v.isNotEmpty) {
    vehicle = RoadTripVehicle(
      name: _str(v.first['Name']) ?? 'Imported car',
      tankCapacity: _num(v.first['Tank Capacity']),
      currency: _str(v.first['Home Currency']),
    );
  }

  final tyres = <RoadTripTyreSet>[];
  for (final r in records('TIRE LOG')) {
    final name = _str(r['Name']);
    if (name == null) continue;
    tyres.add(RoadTripTyreSet(
      name: name,
      startAt: parseRoadTripDate(r['Start Date'] ?? ''),
      startOdometerKm: _num(r['Start Odometer (km)']),
      size: _str(r['Size']),
      distanceKm: _num(r['Distance']),
    ));
  }

  return RoadTripExport(
    fuel: fuel,
    maintenance: maintenance,
    trips: trips,
    vehicle: vehicle,
    tyreSets: tyres,
    warnings: warnings,
  );
}

/// Maps the old app's octane labels onto the NZ pump grades.
String? normaliseOctane(String? s) {
  if (s == null) return null;
  switch (s.trim().toLowerCase()) {
    case '91':
      return '91';
    case '95':
    case 'premium':
      return '95';
    case '98':
    case 'super-premium':
    case 'super premium':
      return '98';
    case 'diesel':
      return 'diesel';
    default:
      return s.trim();
  }
}

/// "1y" -> 12, "12m" -> 12, "6m" -> 6, "1w" -> null (too short to matter).
int? reminderMonths(String? interval) {
  if (interval == null) return null;
  final m = RegExp(r'^(\d+)\s*([ymw])$').firstMatch(interval.trim().toLowerCase());
  if (m == null) return null;
  final n = int.parse(m[1]!);
  switch (m[2]) {
    case 'y':
      return n * 12;
    case 'm':
      return n;
    default:
      return null;
  }
}
