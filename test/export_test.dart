import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/export/data_export.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/export_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'driving_insights_test.dart' show sim;
import 'trip_upgrades_test.dart' show saveTrip;

List<List<dynamic>> parse(String csv) {
  expect(csv.startsWith('﻿'), isTrue);
  return const CsvToListConverter(shouldParseNumbers: false).convert(csv.substring(1));
}

Future<String> seed(Repository repo) async {
  final v = await repo.addVehicle('GT86', 'petrol');
  final w = await repo.addVehicle('Loan car', 'petrol');
  Future<void> fill(String id, String vid, DateTime at, double odo, double l, double cost, {bool full = true}) => repo.upsertEvent(
      EnergyEventsCompanion.insert(id: id, vehicleId: vid, at: at, odometerKm: odo, quantity: l, cost: cost, isFull: Value(full), stationName: const Value('Z Somewhere, "Main" St')),
      enqueue: false);
  await fill('f1', v.id, DateTime(2025, 1, 5, 9, 30), 10000, 40, 100);
  await fill('f2', v.id, DateTime(2025, 2, 5, 9, 30), 10500, 40, 110);
  await fill('f3', v.id, DateTime(2026, 1, 5, 9, 30), 11000, 45, 120);
  await fill('g1', w.id, DateTime(2026, 2, 1), 500, 20, 50);
  await repo.upsertExpense(ExpensesCompanion.insert(id: 'x1', vehicleId: v.id, at: DateTime(2025, 6, 1), kind: 'wof', description: 'WOF', cost: 65));
  await repo.upsertExpense(ExpensesCompanion.insert(id: 'x2', vehicleId: v.id, at: DateTime(2026, 3, 1), kind: 'service', description: 'Oil, filter', cost: 300.5));
  await repo.upsertNote(CarNotesCompanion.insert(
    id: 'n1',
    vehicleId: v.id,
    at: DateTime(2026, 4, 1, 17, 5),
    kind: const Value('incident'),
    title: const Value('Car park bump'),
    lat: const Value(-41.25),
    lon: const Value(174.75),
    fieldsJson: Value(jsonEncode({'otherInsurer': 'Some Insurer', 'police': 'P123'})),
  ));
  await saveTrip(repo, v.id, 't1', 'To work & back', sim([('go', 1500), ('stop', 30), ('go', 1500)], start: DateTime(2026, 5, 1, 8)));
  return v.id;
}

void main() {
  test('CSV builders: economy, quoting, date window, costs and notes', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final vid = await seed(repo);
    final names = {for (final v in await repo.vehicles()) v.id: v.name};

    final events = await repo.watchEvents(null, kind: null).first;
    final fills = parse(fillUpsCsv(events, names));
    expect(fills.first.take(4), ['Vehicle', 'Type', 'Date', 'Time']);
    expect(fills.length, 5);
    final f2 = fills.firstWhere((r) => r[2] == '2025-02-05');
    final h = fills.first;
    expect(f2[h.indexOf('L or kWh per 100 km')], '8'); // 40 L over 500 km
    expect(f2[h.indexOf('Km since last')], '500');
    expect(f2[h.indexOf('Price per L or kWh')], '2.75');
    expect(f2[h.indexOf('Station')], 'Z Somewhere, "Main" St'); // commas and quotes survive
    expect(f2[h.indexOf('Time')], '09:30');

    // Only 2026: economy still uses the 2025 fill before it.
    final y26 = parse(fillUpsCsv(events, names, window: DateWindow(from: DateTime(2026), to: DateTime(2026, 12, 31))));
    expect(y26.length, 3);
    expect(y26.firstWhere((r) => r[0] == 'GT86')[h.indexOf('L or kWh per 100 km')], '9');

    final ex = parse(expensesCsv(await repo.watchExpenses(vid).first, names, withDocs: {'x2'}));
    expect(ex.length, 3);
    expect(ex[1].sublist(0, 6), ['GT86', '2025-06-01', 'WOF', 'Servicing & WOF', 'WOF', '65']);
    expect(ex[2][ex.first.indexOf('Has documents')], 'Yes');

    final trips = parse(tripsCsv(await repo.watchTrips(null).first, names));
    expect(trips.length, 2);
    final th = trips.first;
    expect(trips[1][th.indexOf('Name')], 'To work & back');
    expect(double.parse(trips[1][th.indexOf('Distance km')] as String), closeTo(3, 0.3));
    expect(trips[1][th.indexOf('Top speed km/h')], isNot(''));

    final notes = parse(notesCsv(await repo.watchNotes(null).first, names, const [('otherInsurer', 'Their insurer'), ('police', 'Police')],
        decode: (j) => (jsonDecode(j!) as Map).cast<String, String>(), photos: {'n1': 2}));
    expect(notes[1].sublist(0, 5), ['GT86', 'Incident', '2026-04-01', '17:05', 'Car park bump']);
    expect(notes[1].sublist(notes[1].length - 2), ['Some Insurer', 'P123']);
    expect(notes[1][notes.first.indexOf('Photos')], '2');

    final gpx = tripsGpx([( (await repo.trip('t1'))!, 'GT86', await repo.tripPoints('t1'))]);
    expect(gpx, contains('<name>To work &amp; back</name>'));
    expect('<trkpt '.allMatches(gpx).length, (await repo.tripPoints('t1')).length);
    expect(gpx.trim().endsWith('</gpx>'), isTrue);

    expect(fileSafe('Home → Work / 2'), 'Home-Work-2');
    await db.close();
  });

  test('buildExport: one file per choice, costs per vehicle plus all', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final vid = await seed(repo);
    final all = await buildExport(repo, ExportSet.values.toSet(), now: DateTime(2026, 11, 11));
    expect(all.map((f) => f.name.split('_').first), [
      'mileagelog-fillups',
      'mileagelog-expenses',
      'mileagelog-trips',
      'mileagelog-running-costs',
      'mileagelog-notes',
      'mileagelog-routes',
    ]);
    expect(all.first.name, 'mileagelog-fillups_all-vehicles_all.csv');
    final costs = parse(all[3].text);
    final h = costs.first;
    expect(costs.where((r) => r[0] == 'All vehicles').map((r) => r[1]), ['2025', '2026']);
    final gt25 = costs.firstWhere((r) => r[0] == 'GT86' && r[1] == '2025');
    expect(gt25[h.indexOf('Fuel \$')], '210');
    expect(gt25[h.indexOf('Servicing & WOF \$')], '65');

    final one = await buildExport(repo, {ExportSet.fills, ExportSet.gpx}, vehicleId: vid, window: DateWindow(from: DateTime(2026)));
    expect(one.map((f) => f.name), ['mileagelog-fillups_GT86_2026-01-01_to_now.csv', 'mileagelog-routes_GT86_2026-01-01_to_now.gpx']);
    expect(parse(one.first.text).length, 2); // only the GT86's 2026 fill

    final none = await buildExport(repo, {ExportSet.gpx}, window: DateWindow(to: DateTime(2020)));
    expect(none, isEmpty);

    final zip = ZipDecoder().decodeBytes(zipFiles(all));
    expect(zip.files.length, 6);
    expect(zip.files.first.content as List<int>, utf8.encode(all.first.text));
    await db.close();
  });

  testWidgets('export page shares and saves the chosen files', (tester) async {
    Future<void> io([int n = 10]) async {
      for (var i = 0; i < n; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final vid = (await tester.runAsync(() => seed(repo)))!;
    await settings.setActiveVehicleId(vid);
    List<String>? shared;
    String? savedName;
    Uint8List? savedBytes;
    shareExport = (files, subject) async => shared = [for (final f in files) f.uri.pathSegments.last];
    final tmp = Directory.systemTemp.createTempSync('export');
    exportTempDir = () async => tmp;
    saveExport = (name, bytes) async {
      savedName = name;
      savedBytes = bytes;
      return '/saved/$name';
    };
    await tester.binding.setSurfaceSize(const Size(380, 1400));
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: ExportPage())));
    await io();
    expect(find.text('GT86'), findsOneWidget); // this-vehicle segment
    await tester.ensureVisible(find.text('Share'));
    await tester.pump();
    await tester.tap(find.text('Share'));
    await io(60);
    expect(shared, ['mileagelog-fillups_GT86_all.csv', 'mileagelog-expenses_GT86_all.csv', 'mileagelog-trips_GT86_all.csv', 'mileagelog-running-costs_GT86_all.csv']);

    await tester.tap(find.text('All vehicles'));
    await tester.pump();
    await tester.tap(find.text('Save to phone'));
    await io(60);
    expect(savedName, startsWith('mileagelog-export_'));
    expect(ZipDecoder().decodeBytes(savedBytes!).files.map((f) => f.name), contains('mileagelog-fillups_all-vehicles_all.csv'));

    // Only one file: saved as it is, not zipped.
    for (final t in ['Expenses', 'Trips with their stats', 'Running costs by year']) {
      await tester.tap(find.text(t));
    }
    await tester.pump();
    await tester.tap(find.text('Save to phone'));
    await io(60);
    expect(savedName, 'mileagelog-fillups_all-vehicles_all.csv');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.binding.setSurfaceSize(null);
    await tester.runAsync(() => db.close());
  });
}
