/// Spreadsheet (CSV) and route (GPX) exports of what's in the app.
/// No Flutter imports, so it can be tested on its own.
library;

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../domain/driving_stats.dart' show TripFacts;
import '../domain/ownership_cost.dart';
import '../domain/road_match.dart' show RoadClass;
import '../domain/stats.dart';
import '../domain/trip_stats.dart' show SpeedBand;
import '../domain/trip_weather.dart' show weatherLabel;

final _date = DateFormat('yyyy-MM-dd');
final _time = DateFormat('HH:mm');

/// CSV text with a byte-order mark so Excel reads ° and other characters right.
String toCsv(List<List<Object?>> rows) => '﻿${const ListToCsvConverter().convert(rows)}';

String? _n(num? v, [int digits = 2]) => v == null ? null : double.parse(v.toStringAsFixed(digits)).toString().replaceAll(RegExp(r'\.0$'), '');
String _min(Duration d) => (d.inSeconds / 60).toStringAsFixed(1);

/// Inclusive date window; null ends are open.
class DateWindow {
  final DateTime? from, to;
  const DateWindow({this.from, this.to});
  static const all = DateWindow();
  bool has(DateTime d) => (from == null || !d.isBefore(from!)) && (to == null || d.isBefore(to!.add(const Duration(days: 1))));
  String get fileTag => from == null && to == null ? 'all' : '${from == null ? 'start' : _date.format(from!)}_to_${to == null ? 'now' : _date.format(to!)}';
}

/// Fill-ups and charges with economy per tank.
String fillUpsCsv(List<EnergyEvent> events, Map<String, String> vehicleNames, {DateWindow window = DateWindow.all}) {
  // Economy needs the whole history per vehicle and kind, so work it out first.
  final per100 = <String, double?>{};
  final dist = <String, double?>{};
  final groups = <String, List<EnergyEvent>>{};
  for (final e in events) {
    groups.putIfAbsent('${e.vehicleId}|${e.kind}', () => []).add(e);
  }
  for (final g in groups.values) {
    final rows = {for (final e in g) FuelRow(at: e.at, odometerKm: e.odometerKm, quantity: e.quantity, cost: e.cost, isFull: e.isFull, tripKm: e.tripKm): e};
    for (final s in tankStats(rows.keys.toList())) {
      final e = rows[s.fill]!;
      per100[e.id] = s.litresPer100;
      dist[e.id] = s.distanceKm;
    }
  }
  final list = events.where((e) => window.has(e.at)).toList()..sort((a, b) => a.at.compareTo(b.at));
  return toCsv([
    [
      'Vehicle', 'Type', 'Date', 'Time', 'Odometer km', 'Km since last', 'Litres or kWh', 'Cost \$', 'Price per L or kWh', 'Full',
      'L or kWh per 100 km', 'Fuel type', 'Station', 'Charger', 'Battery start %', 'Battery end %', 'Sharetank litres', 'Pump price \$',
      'Payment', 'Notes', 'Latitude', 'Longitude', 'Source',
    ],
    for (final e in list)
      [
        vehicleNames[e.vehicleId] ?? '',
        e.kind == 'charge' ? 'Charge' : 'Fuel',
        _date.format(e.at),
        _time.format(e.at),
        _n(e.odometerKm, 1),
        _n(dist[e.id], 1),
        _n(e.quantity, 2),
        _n(e.cost, 2),
        e.quantity > 0 ? _n(e.cost / e.quantity, 3) : null,
        e.isFull ? 'Yes' : 'No',
        _n(per100[e.id], 2),
        e.fuelType,
        e.stationName,
        e.chargerType,
        _n(e.batteryPctStart, 0),
        _n(e.batteryPctEnd, 0),
        _n(e.sharetankLitres, 2),
        _n(e.listCost, 2),
        e.paymentNote,
        e.notes,
        _n(e.lat, 5),
        _n(e.lon, 5),
        e.source,
      ],
  ]);
}

const _expenseKinds = {
  'service': 'Service',
  'wof': 'WOF',
  'rego': 'Registration',
  'ruc': 'Road user charges',
  'insurance': 'Insurance',
  'tyres': 'Tyres',
  'toll': 'Toll',
  'parking': 'Parking',
  'repair': 'Repair',
  'other': 'Other',
};

String expenseKindLabel(String k) => _expenseKinds[k] ?? (k.isEmpty ? 'Other' : '${k[0].toUpperCase()}${k.substring(1)}');

String expensesCsv(List<Expense> expenses, Map<String, String> vehicleNames, {DateWindow window = DateWindow.all, Set<String> withDocs = const {}, Map<String, String> kindLabels = const {}}) {
  final list = expenses.where((e) => window.has(e.at)).toList()..sort((a, b) => a.at.compareTo(b.at));
  return toCsv([
    ['Vehicle', 'Date', 'Type', 'Cost category', 'Description', 'Cost \$', 'Odometer km', 'Location', 'Notes', 'Has documents', 'Source'],
    for (final e in list)
      [
        vehicleNames[e.vehicleId] ?? '',
        _date.format(e.at),
        kindLabels[e.kind] ?? expenseKindLabel(e.kind),
        costLabel(categoryForExpense(e.kind)),
        e.description,
        _n(e.cost, 2),
        _n(e.odometerKm, 1),
        e.location,
        e.notes,
        withDocs.contains(e.id) ? 'Yes' : 'No',
        e.source,
      ],
  ]);
}

/// One row per finished trip with the stats the app worked out.
String tripsCsv(List<Trip> trips, Map<String, String> vehicleNames, {DateWindow window = DateWindow.all}) {
  final list = trips.where((t) => t.status != 'recording' && window.has(t.startAt)).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
  return toCsv([
    [
      'Vehicle', 'Name', 'Date', 'Start', 'End', 'Distance km', 'Duration min', 'Moving min', 'Stopped min', 'Average km/h',
      'Moving average km/h', 'Top speed km/h', 'Short stops', 'Longer stops', 'Climb m', 'Harsh braking', 'Harsh acceleration',
      'Urban km', 'Open road km', 'Motorway speed km', 'Motorway km', 'Highway km', 'Suburban km', 'Local road km',
      'Traffic lights passed', 'Stopped at lights', 'Red phases', 'Wait at lights min', 'Temperature °C', 'Rain mm', 'Weather',
      'Wind km/h', 'Start odometer km', 'End odometer km', 'Started by', 'Notes',
    ],
    for (final t in list) _tripRow(t, vehicleNames[t.vehicleId] ?? ''),
  ]);
}

List<Object?> _tripRow(Trip t, String vehicle) {
  final f = TripFacts.fromJson(t.startAt, t.statsJson);
  final s = f?.stats;
  final r = f?.road;
  final w = f?.weather;
  final km = s != null && s.distanceKm > 0
      ? s.distanceKm
      : t.gpsDistanceKm ?? (t.endOdometerKm != null && t.startOdometerKm != null ? t.endOdometerKm! - t.startOdometerKm! : null);
  return [
    vehicle,
    t.name,
    _date.format(t.startAt),
    _time.format(t.startAt),
    t.endAt == null ? null : _time.format(t.endAt!),
    _n(km, 2),
    s != null ? _min(s.total) : (t.endAt == null ? null : _min(t.endAt!.difference(t.startAt))),
    s == null ? null : _min(s.moving),
    s == null ? null : _min(s.stopped),
    _n(s?.avgKmh, 1),
    _n(s?.movingAvgKmh, 1),
    _n(s?.maxKmh, 0),
    s?.shortStops,
    s?.stops.isNotEmpty == true ? s!.stops.length : _longStops(t.statsJson),
    _n(s?.elevationGainM, 0),
    s?.harshBrakes,
    s?.harshAccels,
    _n(s?.bandKm[SpeedBand.urban], 2),
    _n(s?.bandKm[SpeedBand.openRoad], 2),
    _n(s?.bandKm[SpeedBand.motorway], 2),
    _n(r?.roadKm[RoadClass.motorway], 2),
    _n(r?.roadKm[RoadClass.main], 2),
    _n(r?.roadKm[RoadClass.suburban], 2),
    _n(r?.roadKm[RoadClass.local], 2),
    r?.lightsPassed,
    r?.stoppedAtLights,
    r?.redPhases,
    r == null ? null : _min(r.waitAtLights),
    _n(w?.tempC, 1),
    _n(w?.rainMm, 1),
    w == null ? null : weatherLabel(w.code, w.rainMm),
    _n(w?.windKmh, 0),
    _n(t.startOdometerKm, 1),
    _n(t.endOdometerKm, 1),
    t.startedBy,
    t.notes,
  ];
}

int? _longStops(String? json) {
  final m = RegExp(r'"longStops":(\d+)').firstMatch(json ?? '');
  return m == null ? null : int.parse(m[1]!);
}

/// Running costs per year (or month) and vehicle, by category.
String costsCsv(List<(String vehicle, List<CostPeriod> periods)> vehicles, {Period period = Period.year, DateWindow window = DateWindow.all}) {
  const cats = CostCategory.values;
  final label = period == Period.year ? 'Year' : (period == Period.month ? 'Month' : 'Week starting');
  String when(DateTime d) => switch (period) {
        Period.year => '${d.year}',
        Period.month => DateFormat('yyyy-MM').format(d),
        Period.week => _date.format(d),
      };
  bool inWindow(DateTime start) {
    final end = nextPeriod(start, period).subtract(const Duration(days: 1));
    return (window.from == null || !end.isBefore(window.from!)) && (window.to == null || !start.isAfter(window.to!));
  }

  return toCsv([
    ['Vehicle', label, for (final c in cats) '${costLabel(c)} \$', 'Total \$', 'Running total \$ (no depreciation)', 'Km', 'Cost per km \$', 'Running cost per km \$'],
    for (final (name, periods) in vehicles)
      for (final p in periods)
        if (inWindow(p.start) && (p.total != 0 || p.km > 0))
          [
            name,
            when(p.start),
            for (final c in cats) _n(p.cost[c] ?? 0, 2),
            _n(p.total, 2),
            _n(p.running, 2),
            _n(p.km, 0),
            _n(p.perKm, 3),
            _n(p.runningPerKm, 3),
          ],
  ]);
}

/// Notes and incidents. [fields] are the incident form's (key, label) pairs.
String notesCsv(List<CarNote> notes, Map<String, String> vehicleNames, List<(String, String)> fields,
    {DateWindow window = DateWindow.all, Map<String, String> Function(String? json)? decode, Map<String, int> photos = const {}}) {
  final list = notes.where((n) => window.has(n.at)).toList()..sort((a, b) => a.at.compareTo(b.at));
  return toCsv([
    ['Vehicle', 'Kind', 'Date', 'Time', 'Title', 'Notes', 'Latitude', 'Longitude', 'Accuracy m', 'Photos', for (final (_, l) in fields) l],
    for (final n in list)
      () {
        final f = decode?.call(n.fieldsJson) ?? const <String, String>{};
        return [
          vehicleNames[n.vehicleId] ?? '',
          n.kind == 'incident' ? 'Incident' : 'Note',
          _date.format(n.at),
          _time.format(n.at),
          n.title,
          n.body,
          _n(n.lat, 6),
          _n(n.lon, 6),
          _n(n.accuracyM, 0),
          photos[n.id] ?? 0,
          for (final (k, _) in fields) f[k],
        ];
      }(),
  ]);
}

String _xml(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

/// GPX 1.1 with one track per trip. Opens in Google Earth, Strava, Garmin
/// and most mapping apps.
String tripsGpx(List<(Trip trip, String vehicle, List<TripPoint> points)> trips) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="MileageLog" xmlns="http://www.topografix.com/GPX/1/1">');
  for (final (t, vehicle, points) in trips) {
    if (points.isEmpty) continue;
    b
      ..writeln('  <trk>')
      ..writeln('    <name>${_xml(t.name)}</name>')
      ..writeln('    <desc>${_xml('$vehicle, ${_date.format(t.startAt)} ${_time.format(t.startAt)}')}</desc>')
      ..writeln('    <trkseg>');
    for (final p in points) {
      b.write('      <trkpt lat="${p.lat.toStringAsFixed(6)}" lon="${p.lon.toStringAsFixed(6)}">');
      if (p.altitudeM != null) b.write('<ele>${p.altitudeM!.toStringAsFixed(1)}</ele>');
      b.write('<time>${p.at.toUtc().toIso8601String()}</time>');
      if (p.speedMps != null) b.write('<extensions><speed>${p.speedMps!.toStringAsFixed(2)}</speed></extensions>');
      b.writeln('</trkpt>');
    }
    b
      ..writeln('    </trkseg>')
      ..writeln('  </trk>');
  }
  b.writeln('</gpx>');
  return b.toString();
}

/// A safe file name part from a trip or vehicle name.
String fileSafe(String s) {
  final t = s.replaceAll(RegExp(r'[^A-Za-z0-9 _-]+'), '').trim().replaceAll(RegExp(r'\s+'), '-');
  return t.isEmpty ? 'trip' : (t.length > 40 ? t.substring(0, 40) : t);
}
